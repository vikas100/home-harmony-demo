//
//  UserPreferences.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/15/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class UserPreferences {
    private static var singleton : UserPreferences!
    
    internal class func sharedPreferences() -> UserPreferences {
        if (singleton == nil) {
            singleton = UserPreferences()
        }
        return singleton
    }
    
    var hasSeenLandingInstructions:Bool {
        get {
            if let value = NSUserDefaults.standardUserDefaults().valueForKey("hasSeenLandingInstructions") as? Bool {
                return value
            }
            return false
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "hasSeenLandingInstructions")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var hasSeenColorInstructions:Bool {
        get {
            if let value = NSUserDefaults.standardUserDefaults().valueForKey("hasSeenColorInstructions") as? Bool {
                return value
            }
            return false
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "hasSeenColorInstructions")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var hasSeenTouchInstructions:Bool {
        get {
            if let value = NSUserDefaults.standardUserDefaults().valueForKey("hasSeenTouchInstructions") as? Bool {
                return value
            }
            return false
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "hasSeenTouchInstructions")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var hasSeenStillFinalInstructions:Bool {
        get {
            if let value = NSUserDefaults.standardUserDefaults().valueForKey("hasSeenStillFinalInstructions") as? Bool {
                return value
            }
            return false
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "hasSeenStillFinalInstructions")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}