//
//  SampleCollectionViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/16/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

class ProjectListingViewController: UITableViewController {
    
    let reuseIdentifier = "ProjectTableCell"
    
    weak internal var delegate: ProjectCellDelegate?
    
    private var projects: [Project] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadTable()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    
    func reloadTable() {
        self.projects.removeAll()

        if let projectIDs = ProjectDatabase.sharedDatabase().sortedKeys as? [String] {
            projectIDs.forEach({ (projectID) -> () in
                if let project = ProjectDatabase.sharedDatabase()[projectID] as? Project {
                    self.projects.append(project)
                }
            })
        }

        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? ProjectTableViewCell else { fatalError("Expected to display a ProjectTableViewCell") }
        
        let project = self.projects[indexPath.row]
        
        cell.thumbnail.image = project.previewImage
        cell.titleLabel.text = project.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]  {
        
        let project = self.projects[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let deleteMenu = UIAlertController(title: nil, message: "Would you like to delete this project?", preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default,  handler: {
                (alert: UIAlertAction!) -> Void in
                print("Deleted")
                tableView.setEditing(false, animated: true)
                ProjectDatabase.sharedDatabase().removeProject(project.projectID)
                self.reloadTable()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel,  handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
                tableView.setEditing(false, animated: true)
            })
            
            deleteMenu.addAction(deleteAction)
            deleteMenu.addAction(cancelAction)
            
            presentActionSheet(deleteMenu, viewController: self)
        })
        deleteAction.backgroundColor = UIColor.redColor()
        
        // 3
        let copyAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Copy" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            tableView.setEditing(false, animated: true)
            
            let newName = "\(project.name) copy"
            
            let chooseNameAlert = UIAlertController(title: "Project Name", message: "Enter a name for this project", preferredStyle: UIAlertControllerStyle.Alert)
            //chooseNameAlert.textFields![0].text = newName
            
            chooseNameAlert.addAction(UIAlertAction(title: "Save", style: .Default, handler:  {
                (alert: UIAlertAction!) -> Void in
                var chosenName = chooseNameAlert.textFields![0].text
                if (chosenName == nil) {
                    chosenName = newName
                }
                
                ProjectDatabase.sharedDatabase().cloneProject(project.projectID, newName: chosenName!)
                self.reloadTable()
            }))
            
            chooseNameAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:nil))
            chooseNameAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Enter Project Name:"
                textField.text = newName
            })
            self.presentViewController(chooseNameAlert, animated: true, completion: nil)
            
            
        })
        copyAction.backgroundColor = CAMBRIAN_COLOR
        // 5
        return [deleteAction,copyAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let project = self.projects[indexPath.row]
        self.delegate?.projectSelected(project.path)
    }
}
