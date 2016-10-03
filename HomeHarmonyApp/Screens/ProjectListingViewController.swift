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
    
    fileprivate var projects: [Project] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ProjectTableViewCell else { fatalError("Expected to display a ProjectTableViewCell") }
        
        let project = self.projects[(indexPath as NSIndexPath).row]
        
        cell.thumbnail.image = project.previewImage
        cell.titleLabel.text = project.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]  {
        
        let project = self.projects[(indexPath as NSIndexPath).row]
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            
            let deleteMenu = UIAlertController(title: nil, message: "Would you like to delete this project?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default,  handler: {
                (alert: UIAlertAction!) -> Void in
                print("Deleted")
                tableView.setEditing(false, animated: true)
                ProjectDatabase.sharedDatabase().removeProject(project.projectID)
                self.reloadTable()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,  handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
                tableView.setEditing(false, animated: true)
            })
            
            deleteMenu.addAction(deleteAction)
            deleteMenu.addAction(cancelAction)
            
            presentActionSheet(deleteMenu, viewController: self)
        })
        deleteAction.backgroundColor = UIColor.red
        
        // 3
        let copyAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Copy" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            tableView.setEditing(false, animated: true)
            
            let newName = "\(project.name) copy"
            
            let chooseNameAlert = UIAlertController(title: "Project Name", message: "Enter a name for this project", preferredStyle: UIAlertControllerStyle.alert)
            //chooseNameAlert.textFields![0].text = newName
            
            chooseNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler:  {
                (alert: UIAlertAction!) -> Void in
                var chosenName = chooseNameAlert.textFields![0].text
                if (chosenName == nil) {
                    chosenName = newName
                }
                
                ProjectDatabase.sharedDatabase().cloneProject(project.projectID, newName: chosenName!)
                self.reloadTable()
            }))
            
            chooseNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            chooseNameAlert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter Project Name:"
                textField.text = newName
            })
            self.present(chooseNameAlert, animated: true, completion: nil)
            
            
        })
        copyAction.backgroundColor = CAMBRIAN_COLOR
        // 5
        return [deleteAction,copyAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = self.projects[(indexPath as NSIndexPath).row]
        self.delegate?.projectSelected(project.path)
    }
}
