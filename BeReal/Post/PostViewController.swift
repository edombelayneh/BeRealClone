//
//  PostViewController.swift
//  BeReal
//
//  Created by Edom Belayneh on 9/30/25.
//

import UIKit
import PhotosUI
import ParseSwift
import CoreLocation


class PostViewController: UIViewController {

    @IBOutlet weak var openCameraButton: UIButton!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    private var pickedImage: UIImage?
    private var extractedLatitude: Double?
    private var extractedLongitude: Double?
    private var extractedDateTaken: Date?
    private var extractedLocation: String?

    
    private let geocoder = CLGeocoder()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTappedOpenCamera(_ sender: UIButton) {
//        lable on physical iOS device, not available on simulator.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌📷 Camera not available")
            return
        }

        // Instantiate the image picker
        let imagePicker = UIImagePickerController()

        // Shows the camera (vs the photo library)
        imagePicker.sourceType = .camera

        // Allows user to edit image within image picker flow (i.e. crop, etc.)
        // If you don't want to allow editing, you can leave out this line as the default value of `allowsEditing` is false
        imagePicker.allowsEditing = true

        // The image picker (camera in this case) will return captured photos via it's delegate method to it's assigned delegate.
        // Delegate assignee must conform and implement both `UIImagePickerControllerDelegate` and `UINavigationControllerDelegate`
        imagePicker.delegate = self

        // Present the image picker (camera)
        present(imagePicker, animated: true)
    }
    @IBAction func onPickedImageTapped(_ sender: UIButton) {
        // Create a configuration object
        var config = PHPickerConfiguration()

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker
        present(picker, animated: true)
    }
    
    @IBAction func onPostTapped(_ sender: UIButton) {
        // Unwrap optional pickedImage
        guard let image = pickedImage,
              // Create and compress image data (jpeg) from UIImage
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        // Create a Parse File by providing a name and passing in the image data
        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        // Create Post object
        var post = Post()

        // Set properties
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.user = User.current
        
        if let location = extractedLocation {
            post.location = location
        }
        if let lat = extractedLatitude, let lon = extractedLongitude {
            post.latitude = lat
            post.longitude = lon
        }
        if let dateTaken = extractedDateTaken {
            post.dateTaken = dateTaken
        }

        // Save object in background (async)
        post.save { [weak self] result in
            
            // Get the current user
            if var currentUser = User.current {

                // Update the `lastPostedDate` property on the user with the current date.
                currentUser.lastPostedDate = Date()

                // Save updates to the user (async)
                currentUser.save { [weak self] result in
                    switch result {
                    case .success(let user):
                        print("✅ User Saved! \(user)")

                        // Switch to the main thread for any UI updates
                        DispatchQueue.main.async {
                            // Return to previous view controller
                            self?.navigationController?.popViewController(animated: true)
                        }

                    case .failure(let error):
                        self?.showAlert(description: error.localizedDescription)
                    }
                }
            }

            // Switch to the main thread for any UI updates
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")

                    // Return to previous view controller
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { return }

        // Load preview image
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let image = object as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self?.previewImage.image = image
                    self?.pickedImage = image
                }
            }
        }

        // Load EXIF metadata
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                guard let url = url else { return }
                if let data = NSData(contentsOf: url) {
                    let options = [kCGImageSourceShouldCache as String: kCFBooleanFalse]
                    if let imgSrc = CGImageSourceCreateWithData(data, options as CFDictionary),
                       let metadata = CGImageSourceCopyPropertiesAtIndex(imgSrc, 0, options as CFDictionary) as? [CFString: Any] {

                        // GPS
                        if let gps = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any] {
                        if let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
                            let latRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
                            let lon = gps[kCGImagePropertyGPSLongitude] as? Double,
                            let lonRef = gps[kCGImagePropertyGPSLongitudeRef] as? String {
                            
                                var correctedLat = lat
                                var correctedLon = lon

                                // Apply hemisphere correction
                                if latRef == "S" { correctedLat = -correctedLat }
                                if lonRef == "W" { correctedLon = -correctedLon }

                                self?.extractedLatitude = correctedLat
                                self?.extractedLongitude = correctedLon

                                // Now reverse geocode with corrected values
                                let location = CLLocation(latitude: correctedLat, longitude: correctedLon)
                                self?.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                                    if let error = error {
                                        print("❌ Geocoding error: \(error.localizedDescription)")
                                        return
                                    }

                                    if let placemark = placemarks?.first {
                                        let city = placemark.locality ?? ""
                                        let state = placemark.administrativeArea ?? ""
                                        let country = placemark.country ?? ""
                                        let placeString = [city, state, country].filter { !$0.isEmpty }.joined(separator: ", ")

                                        DispatchQueue.main.async {
                                            self?.extractedLocation = placeString
                                            print("✅ Reverse-geocoded location: \(placeString)")
                                        }
                                    }
                                }
                            }
                        }

//                        if let gps = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any] {
//                            self?.extractedLatitude = gps[kCGImagePropertyGPSLatitude] as? Double
//                            self?.extractedLongitude = gps[kCGImagePropertyGPSLongitude] as? Double
                            
//                            // 🔑 Do reverse geocoding here
//                            if let lat = self?.extractedLatitude, let lon = self?.extractedLongitude {
//                                let location = CLLocation(latitude: lat, longitude: lon)
//                                self?.geocoder.reverseGeocodeLocation(location) { placemarks, error in
//                                    if let error = error {
//                                        print("❌ Geocoding error: \(error.localizedDescription)")
//                                        return
//                                    }
//                                    
//                                    if let placemark = placemarks?.first {
//                                        let city = placemark.locality ?? ""
//                                        let state = placemark.administrativeArea ?? ""
//                                        let country = placemark.country ?? ""
//                                        let placeString = [city, state, country].filter { !$0.isEmpty }.joined(separator: ", ")
//                                        
//                                        DispatchQueue.main.async {
//                                            self?.extractedLocation = placeString
//                                            print("✅ Reverse-geocoded location: \(placeString)")
//                                        }
//                                    }
//                                }
//                            }
//                        }

                        // Date Taken
                        if let exif = metadata[kCGImagePropertyExifDictionary] as? [CFString: Any],
                           let dateString = exif[kCGImagePropertyExifDateTimeOriginal] as? String {
                            // Convert "2022:05:26 14:28:29" into Date
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                            self?.extractedDateTaken = formatter.date(from: dateString)
                        }
                    }
                }
            }
        }
    }
}



extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Dismiss the image picker
        picker.dismiss(animated: true)

        // Get the edited image from the info dictionary (if `allowsEditing = true` for image picker config).
        // Alternatively, to get the original image, use the `.originalImage` InfoKey instead.
        guard let image = info[.editedImage] as? UIImage else {
            print("❌📷 Unable to get image")
            return
        }

        // Set image on preview image view
        previewImage.image = image

        // Set image to use when saving post
        pickedImage = image
    }
}
