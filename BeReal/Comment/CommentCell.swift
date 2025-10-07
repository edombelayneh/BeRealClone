//
//  PostCell.swift
//  BeReal
//
//  Created by Edom Belayneh on 9/30/25.
//
import Alamofire
import AlamofireImage
import UIKit
import ParseSwift

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    func configure(with comment: Comment?) {
        usernameLabel.text = comment?.user?.username ?? "Unknown"
        commentLabel.text = comment?.text ?? ""
        
        if let date = comment?.commentDate {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        }
    }

}
