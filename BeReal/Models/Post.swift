//
//  Post.swift
//  BeReal
//
//  Created by Edom Belayneh on 9/30/25.
//

import Foundation
import ParseSwift

struct Post: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var caption: String?
    var location: String?
    var user: User?
    var imageFile: ParseFile?
    var dateTaken: Date?
    var latitude: Double?
    var longitude: Double?
}
