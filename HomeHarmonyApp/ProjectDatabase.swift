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
    var createDate: Date;
    var modifiedDate: Date;
    
    init(projectID:String, name:String) {
        self.projectID = projectID
        self.name = name
        self.createDate = Date()
        self.modifiedDate = Date()
    }
    
    required init(coder aDecoder: NSCoder) {
        projectID = aDecoder.decodeObject(forKey: "projectID") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        createDate = aDecoder.decodeObject(forKey: "createDate") as! Date
        modifiedDate = aDecoder.decodeObject(forKey: "modifiedDate") as! Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(projectID, forKey: "projectID")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(modifiedDate, forKey: "modifiedDate")
    }
    
    var path: String {
        return ProjectDatabase.getProjectPath(projectID)
    }
    
    var previewImage: UIImage {
        return CBImage.getPreview(self.path)
    }
}

class ProjectDatabase: NSMutableDictionary {
    
    fileprivate var database: NSMutableDictionary!
    
    static var singleton : ProjectDatabase!
    
    internal class func sharedDatabase() -> ProjectDatabase {
        if (singleton == nil) {
            singleton = ProjectDatabase()
            let prefs = UserDefaults.standard;
            
            if let db = prefs.object(forKey: "projects") as? Data {
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
        prefs.set(archivedObject, forKey: "projects")
        
        UserDefaults.standard.synchronize()
    }
    
    func cloneProject(_ projectID: String, newName:String) -> String {

        let newProjectID = CBImagePainter.cloneProject(ProjectDatabase.getProjectPath(), projectID: projectID)
        
        //meta data
        let path = ProjectDatabase.getProjectPath(projectID)
        var metaData = CBImage.getUserData(path)

        metaData?["name"] = newName;
        metaData?["create_date"] = Date();
        metaData?["modified_date"] = Date();
        
        CBImage.setUserData(metaData, path: path)
        
        database[newProjectID] = Project(projectID: newProjectID!, name:newName)
        save()
        
        return newProjectID!
    }
    
    func saveProject(_ painter: CBImagePainter, name:String) {
        painter.stillImage.userData["name"] = name
        
        if (nil == painter.stillImage.userData.object(forKey: "create_date")) {
            painter.stillImage.userData["create_date"] = Date();
        }
        
        painter.stillImage.userData["modified_date"] = Date();
        
        let projectID = painter.saveProject(toDirectory: ProjectDatabase.getProjectPath(), saveState: false)
        
        if let existingProject = database[projectID] as? Project {
            existingProject.name = name
            existingProject.modifiedDate = Date()
        } else {
            database[projectID] = Project(projectID:projectID!, name:name)
        }
        save()
    }
    
    func removeProject(_ projectID: String) {
        removeObject(forKey: projectID)
        
        CBImage.removeProjectDirectory(ProjectDatabase.getProjectPath(projectID))
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
            if let projectA = database[(objectA as? String)!] as? Project {
                if let projectB = database[(objectB as? String)!] as? Project {
                    return projectA.modifiedDate.compare(projectB.modifiedDate) == ComparisonResult.orderedDescending
                }
            }
            return false;
        }
        return sortedKeys as [AnyObject]
    }
    
    internal class func getProjectPath(_ projectID:String?=nil) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        if (projectID == nil) {
            return documentsPath + "/projects"
        } else {
            return documentsPath + "/projects/" + projectID!
        }
    }
    
    func getProjectMetaData(_ projectID:String!) -> NSDictionary! {
        let path = ProjectDatabase.getProjectPath(projectID)
        return CBImage.getUserData(path) as NSDictionary!
    }
}
