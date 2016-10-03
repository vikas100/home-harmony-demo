//
//  SidebarTableViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 12/1/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit

internal protocol SidebarDelegate : ColorCategorySelectionDelegate {
    func colorChosen(_ sender: AnyObject, color:Color)
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
    
    fileprivate var searchController : UISearchController!;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        allBrands = Brand.allBrands() as NSArray!

        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: brandHeaderIdentifier)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        if (!self.isSearching) {
            return allBrands.count
        }
        return 1 //self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!self.isSearching) {
            return (allBrands[section] as AnyObject).categories!.count
        } else {
            return self.searchResults.count
        }
    }
    
    func categoryForIndexPath(_ indexPath: IndexPath) -> ColorCategory! {
        let brand = allBrands[(indexPath as NSIndexPath).section] as? Brand
        let categories = (brand?.categories)! as NSSet //.allObjects[indexPath.section] as? ColorCategory
        
        let category = categories.allObjects[(indexPath as NSIndexPath).row] as? ColorCategory
        
        return category
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //tableView.dequeueReusableCellWithIdentifier(brandCellIdentifier, forIndexPath: indexPath)
        if (!self.isSearching) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: brandCellIdentifier) as? BrandTableViewCell else { fatalError("Expected to display a BrandTableViewCell") }
            
            let category = categoryForIndexPath(indexPath)
            
            cell.headingLabel.text = category?.name
            cell.icon.image = category?.brand.iconImage
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: searchCellIdentifier) as? SearchResult else { fatalError("Expected to display a SearchCell") }
            
            let searchResult = self.searchResults.object(at: (indexPath as NSIndexPath).row) as? Color
        
            cell.colorNameLabel.text = searchResult?.name
            cell.colorView.backgroundColor = searchResult?.uiColor
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (!self.isSearching) {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: brandHeaderIdentifier)! as UITableViewHeaderFooterView
            
            let brand = allBrands[section] as? Brand
            headerView.textLabel!.text = brand?.name
            
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!self.isSearching) {
            if let category = categoryForIndexPath(indexPath) as ColorCategory! {
                self.delegate?.categorySelected(self, category: category)
            }
        } else {
            //color selected
            self.searchBar.resignFirstResponder()
            let searchResult = self.searchResults.object(at: (indexPath as NSIndexPath).row) as? Color
            self.delegate?.colorChosen(self, color: searchResult!)

            let delayTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
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
                self.tableView.isUserInteractionEnabled = true
                tableView.reloadData()
            } else {
                reloadSearchData()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearching = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.reloadSearchData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
    }
    
    func reloadSearchData() {
        self.tableView.isUserInteractionEnabled = false
        
        if (self.searchBar.text!.characters.count < 3) {
            self.searchResults = []
            self.tableView.reloadData()
            return
        }
        //get results
        let numbers = CharacterSet(charactersIn: "0123456789")
        let numberScanner = Scanner(string: self.searchBar.text!)
        // Throw away characters before the first number.
        numberScanner.scanUpToCharacters(from: numbers, into:nil)
        
        // Collect numbers.
        var numberString: NSString? = ""
        numberScanner.scanCharacters(from: numbers, into: &numberString)
        
        CBThreading.perform({ () -> Void in
            let query = numberString!.length > 0 ? "(code CONTAINS[cd] %@)" : "(name CONTAINS[cd] %@)"
            let predicate = NSPredicate(format: query, self.searchBar.text!)
            //self.searchResults = (CBCoreData.sharedInstance() as AnyObject).getRecordsFor(Color.classForCoder(), predicate: predicate, sortedBy: nil, context: nil)
            //TODO: broken
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                self.tableView.isUserInteractionEnabled = true
            })
        }, on: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), withIdentifier: "SearchColors")
    }

}
