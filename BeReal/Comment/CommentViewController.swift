//
//  CommentViewController.swift
//  BeReal
//
//  Created by Edom Belayneh on 10/3/25.
//

import UIKit

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comment[indexPath.row])
        return cell
    }
    
    var comment = [Comment]() {
        didSet {
            tableView.reloadData()
        }
    }
    var fromPost: Post!
    
    @IBOutlet weak var commentTextfield: UITextField!
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryComments()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func addCommentTapped(_ sender: UIButton) {
        guard let post = fromPost else {
            print("❌ No post found for comment")
            return
        }

        var comment = Comment()
        comment.commentDate = Date()
        comment.user = User.current
        comment.text = commentTextfield.text
        comment.post = post

        comment.save { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedComment):
                    print("✅ Comment saved successfully: \(savedComment)")

                    // ✅ Step 1: Add comment to post's array
                    var updatedPost = post
                    if updatedPost.comments == nil {
                        updatedPost.comments = [savedComment]
                    } else {
                        updatedPost.comments?.append(savedComment)
                    }

                    // ✅ Step 2: Save updated post
                    updatedPost.save { postResult in
                        switch postResult {
                        case .success(let updatedPost):
                            print("✅ Post updated with new comment: \(updatedPost)")
                        case .failure(let error):
                            print("❌ Failed to update post with comment: \(error.localizedDescription)")
                        }
                    }

                    // ✅ Step 3: Update tableView & clear text field
                    self?.comment.append(savedComment)
                    self?.commentTextfield.text = ""
                    self?.tableView.reloadData()

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }
    
    private func queryComments() {
        let query = Comment.query()
            .include("user")
            .order([.descending("commentDate")])
            

        // Fetch objects (posts) defined in query (async)
        query.find { [weak self] result in
            switch result {
            case .success(let comment):
                // Update local posts property with fetched posts
                self?.comment = comment
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }

    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    

}
