//
//  Post.swift
//  BeReal
//
//  Created by Edom Belayneh on 9/30/25.
//

import Foundation
import ParseSwift

struct Comment: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var text: String?
    var post: Post?
    var user: User?
    var commentDate: Date?
}
