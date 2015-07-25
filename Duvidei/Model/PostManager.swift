//
//  PostManager.swift
//  Duvidei
//
//  Created by Matheus Frozzi Alberton on 25/07/15.
//  Copyright (c) 2015 Moisés Pio. All rights reserved.
//

import UIKit

class PostManager: PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Post"
    }

    @NSManaged var caption: String?
    @NSManaged var file: PFFile?
    @NSManaged var parent: PostManager?
    @NSManaged var tag: NSArray?
    @NSManaged var type: NSNumber?
    @NSManaged var user: UserManager?

    func sharePost(postControl: PostManager, callback: (error: NSError?) -> ()) {
        var query = PFObject(className: PostManager.parseClassName())

        query["user"] = PFUser.currentUser()

        if(postControl.parent != nil) {
            query["parent"] = PostManager(withoutDataWithClassName:"Post", objectId: postControl.objectId)
        }

        query.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                callback(error: nil)
            } else {
                callback(error: error)
            }
        }
    }
    
    func getPosts(skip: Int, callback: (allPhotos: NSArray?, error: NSError?) -> ()) {
        let query = PFQuery(className: PostManager.parseClassName())
        
        query.includeKey("user")
        
        query.orderByDescending("createdAt")
        query.limit = 10
        query.skip = skip
        
        var auxPhotos: NSArray!
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                auxPhotos = objects!
                callback(allPhotos: auxPhotos, error: nil)
            } else {
                println("Error: \(error) \(error!.userInfo!)")
                callback(allPhotos: nil, error: error!)
            }
        }
    }
}