//
//  Project.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/25/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class Favorite: NSObject, NSCoding {
    var objectID: URL;
    var createDate: Date;
    
    init(favorite:NSManagedObject) {
        self.objectID = favorite.objectID.uriRepresentation()
        self.createDate = Date()
    }
    
    required init(coder aDecoder: NSCoder) {
        objectID = aDecoder.decodeObject(forKey: "objectID") as! URL
        createDate = aDecoder.decodeObject(forKey: "createDate") as! Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(objectID, forKey: "objectID")
        aCoder.encode(createDate, forKey: "createDate")
    }
    
    func getObject() -> NSManagedObject! {
        if let favorite = (CBCoreData.sharedInstance() as AnyObject).getObjectWith(self.objectID) as? NSManagedObject {
            return favorite
        }
        return nil
    }
}

class FavoritesDatabase: NSMutableDictionary {
    
    fileprivate var database: NSMutableDictionary!
    
    static var singleton : FavoritesDatabase!
    
    internal class func sharedDatabase() -> FavoritesDatabase {
        if (singleton == nil) {
            singleton = FavoritesDatabase()
            let prefs = UserDefaults.standard;
            
            if let db = prefs.object(forKey: "favorites") as? Data {
                if let unarchived = NSKeyedUnarchiver.unarchiveObject(with: db) as? NSDictionary {
                    singleton.database = unarchived.mutableCopy() as? NSMutableDictionary
                }
            } else {
                singleton.database = NSMutableDictionary()
            }
        }
        return singleton
    }
    
    func save() {
        let prefs = UserDefaults.standard;
        
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: database)
        prefs.set(archivedObject, forKey: "favorites")
        
        UserDefaults.standard.synchronize()
    }
    
    func isFavorite(_ favorite:NSManagedObject) -> Bool {
        return database[favorite.objectID.uriRepresentation()] != nil
    }
    
    func addFavorite(_ favorite:NSManagedObject) {
        //print("favorite=\(favorite.objectID.URIRepresentation())");
        
        database[favorite.objectID.uriRepresentation()] = Favorite(favorite: favorite)
        save()
    }
    
    func removeFavorite(_ favorite:NSManagedObject) {
        removeObject(forKey: favorite.objectID.uriRepresentation())
        save()
    }
    
    override func removeObject(forKey aKey: Any) {
        database.removeObject(forKey: aKey)
    }
    
    override func setObject(_ anObject: Any, forKey aKey: NSCopying) {
        database.setObject(anObject, forKey: aKey)
    }
    
    override var count: Int {
        get{
            return database.count
        }
    }
    
    override func object(forKey aKey: Any) -> Any? {
        return database.object(forKey: aKey)
    }
    
    override func keyEnumerator() -> NSEnumerator {
        return database.keyEnumerator()
    }
    
    var sortedKeys: [AnyObject] {
        let sortedKeys = database.allKeys.sorted { (objectA, objectB) -> Bool in
            if let favoriteA = database[(objectA as? URL)!] as? Favorite {
                if let favoriteB = database[(objectB as? URL)!] as? Favorite {
                    //return projectA.modifiedDate.timeIntervalSince1970 < projectB.modifiedDate.timeIntervalSince1970
                    return favoriteA.createDate.compare(favoriteB.createDate) == ComparisonResult.orderedDescending
                }
            }
            return false;
        }
        return sortedKeys as [AnyObject]
    }
}
