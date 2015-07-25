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

    @NSManaged var file: PFFile?
    @NSManaged var parent: PostManager?
    @NSManaged var tags: NSArray?
    @NSManaged var type: NSNumber?
    @NSManaged var user: UserManager?
}