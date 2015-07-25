//
//  UserManager.swift
//  Duvidei
//
//  Created by Matheus Frozzi Alberton on 25/07/15.
//  Copyright (c) 2015 Moisés Pio. All rights reserved.
//

import UIKit

class UserManager: PFUser, PFSubclassing {
    //    override class func initialize() {
    //        self.registerSubclass()
    //    }
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    @NSManaged var fullName: String?
    @NSManaged var facebookId: String?
    @NSManaged var location: PFGeoPoint?
}
