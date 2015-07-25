//
//  LikeManager.swift
//  Duvidei
//
//  Created by Matheus Frozzi Alberton on 25/07/15.
//  Copyright (c) 2015 Moisés Pio. All rights reserved.
//

import UIKit

class LikeManager: PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    static func parseClassName() -> String {
        return "Like"
    }

    @NSManaged var post: PostManager?
    @NSManaged var user: UserManager?

    func verifyIfLiked(photoId: String, userId: String, callback: (liked: Bool?, error: NSError?) -> ()) {
        let query = PFQuery(className: LikeManager.parseClassName())
//        query.whereKey("photo", equalTo: PhotoManager(withoutDataWithObjectId: photoId))
//        query.whereKey("profile", equalTo: ProfileManager(withoutDataWithObjectId: userId))
        
        query.countObjectsInBackgroundWithBlock {
            (count, error) -> Void in
            if error == nil && count == 1 {
                callback(liked: true, error: nil)
            } else if error == nil && count == 0 {
                callback(liked: false, error: nil)
            }else {
                callback(liked: false, error: error!)
            }
        }
    }

    func likePost(likeControl: LikeManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className: LikeManager.parseClassName())
        
        query["user"] = PFUser.currentUser()
        query["post"] = likeControl.post!
        
        query.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }

    func unLikePost(likeControl: LikeManager, callback: (error: NSError?) -> ()) {
        let query = LikeManager(withoutDataWithObjectId: likeControl.objectId!)
        
        query.deleteInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }
}