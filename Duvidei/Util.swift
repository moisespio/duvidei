//
//  Util.swift
//  Duvidei
//
//  Created by Matheus Frozzi Alberton on 25/07/15.
//  Copyright (c) 2015 Moisés Pio. All rights reserved.
//

//
//  Util.swift
//  flockr
//
//  Created by Matheus Frozzi Alberton on 20/07/15.
//  Copyright (c) 2015 flockr. All rights reserved.
//

import UIKit

class Util {
    static func roundedView(view: CALayer!, border: Bool, colorHex: String?, borderSize: CGFloat?, radius: CGFloat) {
        if(border == true) {
            view.borderWidth = borderSize!
            view.borderColor = hexStringToUIColor(colorHex!).CGColor
        }
        view.cornerRadius = radius
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func blueColor() -> UIColor {
        return UIColor(
            red: 255.0,
            green: 255.0,
            blue: 255.0,
            alpha: 1.0
        )
    }

    static func registerClasses() {
        UserManager.registerSubclass()
        LikeManager.registerSubclass()
        PostManager.registerSubclass()
    }

    static func howLongTime (date: NSDate) -> String {
        var messageAgo = ""
        
        let dateNow = NSDate()
        let userCalendar = NSCalendar.currentCalendar()
        
        let dayCalendarUnit = NSCalendarUnit(UInt.max)
        
        let dateAgo = userCalendar.components(
            dayCalendarUnit,
            fromDate: date,
            toDate: dateNow,
            options: nil)
        
        if(dateAgo.year > 0) {
            messageAgo = String(dateAgo.year) + "a"
        } else if(dateAgo.month > 0) {
            messageAgo = String(dateAgo.month) + "mês"
        } else if(dateAgo.weekOfYear > 0) {
            messageAgo = String(dateAgo.weekOfYear) + "sem"
        } else if(dateAgo.day > 0) {
            messageAgo = String(dateAgo.day) + "d"
        } else if(dateAgo.hour > 0) {
            messageAgo = String(dateAgo.hour) + "h"
        } else if(dateAgo.minute > 0) {
            messageAgo = String(dateAgo.minute) + "m"
        } else if(dateAgo.second > 0) {
            messageAgo = String(dateAgo.second) + "s"
        } else {
            messageAgo = "agora"
        }
        
        return messageAgo
    }
    
    static func showAlert(title : String, message: String, buttonOption1: String?, buttonOption2: String?) -> UIAlertController{
        
        var decision = Bool()
        var alert = UIAlertController()
        
        if buttonOption1!.isEmpty {
            // NADA
        } else {
            alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: buttonOption1!, style: UIAlertActionStyle.Default){ (action) -> Void in
                decision = true
                })
        }
        
        if buttonOption2!.isEmpty {
            // NADA
        } else {
            alert.addAction(UIAlertAction(title: buttonOption2!, style: UIAlertActionStyle.Default){ (action) -> Void in
                decision = false
                })
        }
        
        return alert
    }
    
}
