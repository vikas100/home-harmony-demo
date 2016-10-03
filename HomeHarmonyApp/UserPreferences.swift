//
//  UserPreferences.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/15/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class UserPreferences {
    fileprivate static var singleton : UserPreferences!
    
    internal class func sharedPreferences() -> UserPreferences {
        if (singleton == nil) {
            singleton = UserPreferences()
        }
        return singleton
    }
    
    var hasSeenLandingInstructions:Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: "hasSeenLandingInstructions") as? Bool {
                return value
            }
            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenLandingInstructions")
            UserDefaults.standard.synchronize()
        }
    }
    
    var hasSeenColorInstructions:Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: "hasSeenColorInstructions") as? Bool {
                return value
            }
            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenColorInstructions")
            UserDefaults.standard.synchronize()
        }
    }
    
    var hasSeenTouchInstructions:Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: "hasSeenTouchInstructions") as? Bool {
                return value
            }
            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenTouchInstructions")
            UserDefaults.standard.synchronize()
        }
    }
    
    var hasSeenStillFinalInstructions:Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: "hasSeenStillFinalInstructions") as? Bool {
                return value
            }
            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenStillFinalInstructions")
            UserDefaults.standard.synchronize()
        }
    }
}
