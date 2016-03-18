//
//  SidebarTableViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/1/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

internal protocol SidebarDelegate : ColorCategorySelectionDelegate {
    func colorChosen(sender: AnyObject, color:Color)
}

private let brandHeaderIdentifier = "BrandHeader"
private let brandCellIdentifier = "BrandCell"

class BrandTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
}

private let searchCellIdentifier = "SearchCell"
class SearchResult: UITableViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorNameLabel: UILabel!
}

class SidebarTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    weak internal var delegate: SidebarDelegate?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var allBrands : NSArray!
    
    var searchResults : NSArray!
    
    private var searchController : UISearchController!;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        allBrands = Brand.allBrands()

        self.tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: brandHeaderIdentifier)
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (!self.isSearching) {
            return allBrands.count
        }
        return 1 //self.searchResults.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!self.isSearching) {
            return allBrands[section].categories!.count
        } else {
            return self.searchResults.count
        }
    }
    
    func categoryForIndexPath(indexPath: NSIndexPath) -> ColorCategory! {
        let brand = allBrands[indexPath.section] as? Brand
        let categories = (brand?.categories)! as NSSet //.allObjects[indexPath.section] as? ColorCategory
        
        let category = categories.allObjects[indexPath.row] as? ColorCategory
        
        return category
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //tableView.dequeueReusableCellWithIdentifier(brandCellIdentifier, forIndexPath: indexPath)
        if (!self.isSearching) {
            guard let cell = tableView.dequeueReusableCellWithIdentifier(brandCellIdentifier) as? BrandTableViewCell else { fatalError("Expected to display a BrandTableViewCell") }
            
            let category = categoryForIndexPath(indexPath)
            
            cell.headingLabel.text = category?.name
            cell.icon.image = category?.brand.iconImage
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCellWithIdentifier(searchCellIdentifier) as? SearchResult else { fatalError("Expected to display a SearchCell") }
            
            let searchResult = self.searchResults.objectAtIndex(indexPath.row) as? Color
        
            cell.colorNameLabel.text = searchResult?.name
            cell.colorView.backgroundColor = searchResult?.uiColor
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (!self.isSearching) {
            let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(brandHeaderIdentifier)! as UITableViewHeaderFooterView
            
            let brand = allBrands[section] as? Brand
            headerView.textLabel!.text = brand?.name
            
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (!self.isSearching) {
            if let category = categoryForIndexPath(indexPath) as ColorCategory! {
                self.delegate?.categorySelected(self, category: category)
            }
        } else {
            //color selected
            self.searchBar.resignFirstResponder()
            let searchResult = self.searchResults.objectAtIndex(indexPath.row) as? Color
            self.delegate?.colorChosen(self, color: searchResult!)

            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.isSearching = false
            }
        }
    }
    
    // MARK: - Search Controller
    var isSearching:Bool = false {
        didSet {
            if (!self.isSearching) {
                self.searchBar.text = nil
                self.searchBar.resignFirstResponder()
                self.tableView.userInteractionEnabled = true
                tableView.reloadData()
            } else {
                reloadSearchData()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.isSearching = true
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.reloadSearchData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isSearching = false
    }
    
    func reloadSearchData() {
        self.tableView.userInteractionEnabled = false
        
        if (self.searchBar.text!.characters.count < 3) {
            self.searchResults = []
            self.tableView.reloadData()
            return
        }
        //get results
        let numbers = NSCharacterSet(charactersInString: "0123456789")
        let numberScanner = NSScanner(string: self.searchBar.text!)
        // Throw away characters before the first number.
        numberScanner.scanUpToCharactersFromSet(numbers, intoString:nil)
        
        // Collect numbers.
        var numberString: NSString? = ""
        numberScanner.scanCharactersFromSet(numbers, intoString: &numberString)
        
        CBThreading.performBlock({ () -> Void in
            let query = numberString!.length > 0 ? "(code CONTAINS[cd] %@)" : "(name CONTAINS[cd] %@)"
            let predicate = NSPredicate(format: query, self.searchBar.text!)
            self.searchResults = CBCoreData.sharedInstance().getRecordsForClass(Color.classForCoder(), predicate: predicate, sortedBy: nil, context: nil)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.tableView.userInteractionEnabled = true
            })
        }, onQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), withIdentifier: "SearchColors")
    }

}
