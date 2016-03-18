//
//  Project.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/25/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation

class Project: NSObject, NSCoding {
    var projectID: String;
    var name: String;
    var createDate: NSDate;
    var modifiedDate: NSDate;
    
    init(projectID:String, name:String) {
        self.projectID = projectID
        self.name = name
        self.createDate = NSDate()
        self.modifiedDate = NSDate()
    }
    
    required init(coder aDecoder: NSCoder) {
        projectID = aDecoder.decodeObjectForKey("projectID") as! String
        name = aDecoder.decodeObjectForKey("name") as! String
        createDate = aDecoder.decodeObjectForKey("createDate") as! NSDate
        modifiedDate = aDecoder.decodeObjectForKey("modifiedDate") as! NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(projectID, forKey: "projectID")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(createDate, forKey: "createDate")
        aCoder.encodeObject(modifiedDate, forKey: "modifiedDate")
    }
    
    var path: String {
        return ProjectDatabase.getProjectPath(projectID)
    }
    
    var previewImage: UIImage {
        return CBImage.getPreview(self.path)
    }
}

class ProjectDatabase: NSMutableDictionary {
    
    private var database: NSMutableDictionary!
    
    static var singleton : ProjectDatabase!
    
    internal class func sharedDatabase() -> ProjectDatabase {
        if (singleton == nil) {
            singleton = ProjectDatabase()
            let prefs = NSUserDefaults.standardUserDefaults();
            
            if let db = prefs.objectForKey("projects") as? NSData {
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
        prefs.setObject(archivedObject, forKey: "projects")
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func cloneProject(projectID: String, newName:String) -> String {

        let newProjectID = CBImagePainter.cloneProject(ProjectDatabase.getProjectPath(), projectID: projectID)
        
        //meta data
        let path = ProjectDatabase.getProjectPath(projectID)
        var metaData = CBImage.getUserData(path)

        metaData["name"] = newName;
        metaData["create_date"] = NSDate();
        metaData["modified_date"] = NSDate();
        
        CBImage.setUserData(metaData, path: path)
        
        database[newProjectID] = Project(projectID: newProjectID, name:newName)
        save()
        
        return newProjectID
    }
    
    func saveProject(painter: CBImagePainter, name:String) {
        painter.stillImage.userData["name"] = name
        
        if (nil == painter.stillImage.userData.objectForKey("create_date")) {
            painter.stillImage.userData["create_date"] = NSDate();
        }
        
        painter.stillImage.userData["modified_date"] = NSDate();
        
        let projectID = painter.saveProjectToDirectory(ProjectDatabase.getProjectPath(), saveState: false)
        
        if let existingProject = database[projectID] as? Project {
            existingProject.name = name
            existingProject.modifiedDate = NSDate()
        } else {
            database[projectID] = Project(projectID:projectID, name:name)
        }
        save()
    }
    
    func removeProject(projectID: String) {
        removeObjectForKey(projectID)
        
        CBImage.removeProjectDirectory(ProjectDatabase.getProjectPath(projectID))
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
            if let projectA = database[(objectA as? String)!] as? Project {
                if let projectB = database[(objectB as? String)!] as? Project {
                    return projectA.modifiedDate.compare(projectB.modifiedDate) == NSComparisonResult.OrderedDescending
                }
            }
            return false;
        }
        return sortedKeys
    }
    
    internal class func getProjectPath(projectID:String?=nil) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        if (projectID == nil) {
            return documentsPath + "/projects"
        } else {
            return documentsPath + "/projects/" + projectID!
        }
    }
    
    func getProjectMetaData(projectID:String!) -> NSDictionary! {
        let path = ProjectDatabase.getProjectPath(projectID)
        return CBImage.getUserData(path)
    }
}