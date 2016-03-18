//
//  Project.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/25/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class Favorite: NSObject, NSCoding {
    var objectID: NSURL;
    var createDate: NSDate;
    
    init(favorite:NSManagedObject) {
        self.objectID = favorite.objectID.URIRepresentation()
        self.createDate = NSDate()
    }
    
    required init(coder aDecoder: NSCoder) {
        objectID = aDecoder.decodeObjectForKey("objectID") as! NSURL
        createDate = aDecoder.decodeObjectForKey("createDate") as! NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objectID, forKey: "objectID")
        aCoder.encodeObject(createDate, forKey: "createDate")
    }
    
    func getObject() -> NSManagedObject! {
        if let favorite = CBCoreData.sharedInstance().getObjectWithUrl(self.objectID) as? NSManagedObject {
            return favorite
        }
        return nil
    }
}

class FavoritesDatabase: NSMutableDictionary {
    
    private var database: NSMutableDictionary!
    
    static var singleton : FavoritesDatabase!
    
    internal class func sharedDatabase() -> FavoritesDatabase {
        if (singleton == nil) {
            singleton = FavoritesDatabase()
            let prefs = NSUserDefaults.standardUserDefaults();
            
            if let db = prefs.objectForKey("favorites") as? NSData {
                if let unarchived = NSKeyedUnarchiver.unarchiveObjectWithData(db) as? NSDictionary {
                    singleton.database = unarchived.mutableCopy() as? NSMutableDictionary
                }
            } else {
                singleton.database = NSMutableDictionary()
            }
        }
        return singleton
    }
    
    func save() {
        let prefs = NSUserDefaults.standardUserDefaults();
        
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(database)
        prefs.setObject(archivedObject, forKey: "favorites")
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func isFavorite(favorite:NSManagedObject) -> Bool {
        return database[favorite.objectID.URIRepresentation()] != nil
    }
    
    func addFavorite(favorite:NSManagedObject) {
        //print("favorite=\(favorite.objectID.URIRepresentation())");
        
        database[favorite.objectID.URIRepresentation()] = Favorite(favorite: favorite)
        save()
    }
    
    func removeFavorite(favorite:NSManagedObject) {
        removeObjectForKey(favorite.objectID.URIRepresentation())
        save()
    }
    
    override func removeObjectForKey(aKey: AnyObject) {
        database.removeObjectForKey(aKey)
    }
    
    override func setObject(anObject: AnyObject, forKey aKey: NSCopying) {
        database.setObject(anObject, forKey: aKey)
    }
    
    override var count: Int {
        get{
            return database.count
        }
    }
    
    override func objectForKey(aKey: AnyObject) -> AnyObject? {
        return database.objectForKey(aKey)
    }
    
    override func keyEnumerator() -> NSEnumerator {
        return database.keyEnumerator()
    }
    
    var sortedKeys: [AnyObject] {
        let sortedKeys = database.allKeys.sort { (objectA, objectB) -> Bool in
            if let favoriteA = database[(objectA as? NSURL)!] as? Favorite {
                if let favoriteB = database[(objectB as? NSURL)!] as? Favorite {
                    //return projectA.modifiedDate.timeIntervalSince1970 < projectB.modifiedDate.timeIntervalSince1970
                    return favoriteA.createDate.compare(favoriteB.createDate) == NSComparisonResult.OrderedDescending
                }
            }
            return false;
        }
        return sortedKeys
    }
}