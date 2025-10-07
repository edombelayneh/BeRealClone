//
//  FeedViewController.swift
//  BeReal
//
//  Created by Edom Belayneh on 9/30/25.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var post = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    @IBOutlet weak var tableView: UITableView!
        
    @IBAction func onLogOutTapped(_ sender: UIButton) {
        showConfirmLogoutAlert()
        print("Logout tapped")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCommentsSegue" {
            let destinationVC = segue.destination as! CommentViewController
            
            // If segue was triggered from a button inside the cell
            if let button = sender as? UIButton {
                // Find the cell the button belongs to
                if let cell = button.superview?.superview as? PostCell,
                   let indexPath = tableView.indexPath(for: cell) {
                    let selectedPost = post[indexPath.row]
                    destinationVC.fromPost = selectedPost
                    print("✅ Passing post to CommentVC via button: \(selectedPost)")
                }
            }
            // If segue triggered by tapping the entire cell
            else if let indexPath = tableView.indexPathForSelectedRow {
                let selectedPost = post[indexPath.row]
                destinationVC.fromPost = selectedPost
                print("✅ Passing post to CommentVC via cell tap: \(selectedPost)")
            }
        }
    }



    private func queryPosts() {
        // 1. Create a query to fetch Posts
        // 2. Any properties that are Parse objects are stored by reference in Parse DB and as such need to explicitly use `include_:)` to be included in query results.
        // 3. Sort the posts by descending order based on the created at date
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate)
            .limit(10)
            

        // Fetch objects (posts) defined in query (async)
        query.find { [weak self] result in
            switch result {
            case .success(let post):
                // Update local posts property with fetched posts
                self?.post = post
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: post[indexPath.row])
        return cell
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
