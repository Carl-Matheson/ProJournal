//
//  FirstViewController.swift
//  ProJournal
//
//  Created by hanif on 4/8/17.]
//

import UIKit
import CoreGraphics

class JournalsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate {
    
    // Constants
    
    let journalsCellIdentifier = "journalCell"
    
    // Variables
    
    private var colourCache:[Int32:UIImage]!
    internal var searchController:UISearchController!
    
    internal var filteredResults:[JournalItem]!
    
    override var isEditing: Bool {
        willSet(newVal) {
            print(newVal)
        }
    }
    
    @IBOutlet weak var journalsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSearchController();
        loadData()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: journalsTableView)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func initSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation=false
        searchController.searchResultsUpdater=self
        definesPresentationContext=true
        journalsTableView.tableHeaderView=searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // PRAGMA MARK: Loading / Adding Journal items
    
    func loadData() {
        self.colourCache = [:]
        for i in 1...2 {
            let journalItem = JournalItem(name: "Journal #\(i)", colour: Utilities.generateRandomColour(), dateCreated: Date())
            Journals.instance.add(item: journalItem)
        }
    }
    
    func addJournal(name:String, colour:Int32=Utilities.generateRandomColour()) {
        let journalItem = JournalItem(name: name, colour: colour, dateCreated: Date())
        journalsTableView.beginUpdates()
        Journals.instance.add(item: journalItem, at: 0) // add the new item to the top
        journalsTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .left)
        journalsTableView.endUpdates()
    }
    
    func selectedJournalItem()->JournalItem {
        return get(index: journalsTableView.indexPathForSelectedRow!)!
    }
    
    
    // PRAGMA MARK: UITableView data source
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: journalsCellIdentifier) as? JournalsTableCell
        let item = get(index: indexPath)
        
        // Check if the journal item colour is available, if not generate it and store it to cache for future use
        if colourCache[(item?.colour)!] == nil {
            colourCache[(item?.colour)!] = createImage(width: 50, height: 50,
                                                       color: UIColor(red: CGFloat((item!.colour >> 16) & 0xff)/255.0, green: CGFloat((item!.colour >> 8) & 0xff)/255.0,
                                                                      blue: CGFloat(item!.colour & 0xff)/255.0, alpha: 1.0))
            print("Generated image cache for colour = \(item!.colour)")
        }
        
        cell?.cellIcon.image = colourCache[(item?.colour)!]
        cell?.cellText.text = item?.name
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func createImage(width:Int, height:Int, color:UIColor)->UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    // PRAGMA MARK: UITableView delegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            return
        }
        
    }
    
    // PRAGMA MARK: Storyboard segues
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !isEditing;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEntry" {
            let dest:JournalEntriesTableViewController = segue.destination as! JournalEntriesTableViewController
            dest.journalItem = selectedJournalItem()
        }
    }
    
    // PRAGMA MARK: 3DTouch delegates
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = journalsTableView?.indexPathForRow(at: location),
            let cell = journalsTableView?.cellForRow(at: indexPath),
            let controller = storyboard?.instantiateViewController(withIdentifier: "JournalEntriesView") as? JournalEntriesTableViewController else {
                return nil
        }
        previewingContext.sourceRect = cell.frame
        controller.journalItem = get(index: indexPath)
        return controller
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let controller = viewControllerToCommit as? JournalEntriesTableViewController else {
            return
        }
        show(controller, sender: self)
    }
    // PRAGMA MARK: Actions
    
    @IBAction func addAction(_ sender: Any) {
        let inputController = UIAlertController(title: "New Journal", message: nil, preferredStyle: .alert)
        inputController.addTextField() {
            textField -> Void in
            textField.placeholder="Journal name"
        }
        let addButton = UIAlertAction(title: "Add", style: .default) {
            _ in
            let nameField = inputController.textFields?.first!
            guard let text = nameField?.text, !(nameField?.text?.isEmpty)! else {
                return
            }
            self.addJournal(name: text)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        inputController.addAction(addButton)
        inputController.addAction(cancelButton)
        present(inputController, animated: true)
    }
}

// Class extension that handles the delegation of search data retrieval
extension JournalsViewController : RetrievableProtocol {
    
    func get(_ index:Int)->JournalItem? {
        return isSearching() ? filteredResults[index] : Journals.instance.get(index)
    }
    func get(index:IndexPath?)->JournalItem? {
        return isSearching() ? filteredResults[(index?.row)!] : Journals.instance.get(index: index)
    }
    var count:Int {
        return isSearching() ? filteredResults.count : Journals.instance.count
    }
}

extension JournalsViewController : UISearchResultsUpdating, UISearchControllerDelegate {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else {
            return
        }
        filteredResults = Journals.instance.filter(query)
        journalsTableView.reloadData()
    }
    
    public func isSearching()->Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
}

class JournalsTableCell : UITableViewCell {
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellIcon: UIImageView!
    
}

