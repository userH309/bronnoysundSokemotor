import UIKit

class mainVC: UIViewController,UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate
{
    //Connecting outlets.
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var advancedSearchBtn: UIBarButtonItem!
    @IBOutlet weak var advancedView: UIView!
    @IBOutlet weak var employeeTxtField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    
    var areInCache:Bool!
    var nameSearchSelected:Bool!
    var dataStorageVar:dataStorage!
    var searchTextFinal:String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController!.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        employeeTxtField.delegate = self
        placeTextField.delegate = self
        dataStorageVar = dataStorage(searchText: "", nameSearch: true)
        dataStorageVar.nameArray = [""]
        nameSearchSelected = true
 
        searchBar.placeholder = "Søk på navn..."
        
        searchBar.returnKeyType = .done
        employeeTxtField.returnKeyType = .search
        placeTextField.returnKeyType = .search
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //Check if reusable cell is a srcResCell.
        if let cell = tableView.dequeueReusableCell(withIdentifier: "srcResCell", for: indexPath) as? srcResCell
        {
            //Check for data in name cache.
            if let name = dataStorage.nameCache.object(forKey: "\(searchTextFinal)\(indexPath.row)" as NSString)
            {
                //Pass in name to configure cell function.
                cell.configureCell(nameInput: name as String)
                return cell
            }
            else
            {
                //Set to empty string if we don't get data.
                cell.configureCell(nameInput: "")
                return cell
            }
        }
        else
        {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //Check for data in name cache.
        if let nameSelected = dataStorage.nameCache.object(forKey: "\(searchTextFinal)\(indexPath.row)" as NSString)
        {
            //Segue to detailsVC and send the name selected.
            performSegue(withIdentifier: "detailsVC", sender: nameSelected as String)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        //Hide keyboard when scrolling.
        view.endEditing(true)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)
    {
        updateSearchResults(text: searchBar.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //Check if ID is detailsVC.
        if segue.identifier == "detailsVC"
        {
            //Make sure destination is correct.
            if let detailsVC = segue.destination as? detailsVC
            {
                if let name = sender as? String
                {
                    detailsVC.cellName = name
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        //Pass in searchBar text to updateSearchResult every time text changes.
        updateSearchResults(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        view.endEditing(true)
    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl)
    {
        //Run if name search is tapped.
        if segmentController.selectedSegmentIndex == 0
        {
            advancedSearchBtn.isEnabled = true
            nameSearchSelected = true
            view.endEditing(true)
            searchBar.placeholder = "Søk på navn..."
            searchBar.keyboardType = .asciiCapable
            advancedSearchBtn.isEnabled = true
            endAdvanceView()
        }
        //Run if org number is tapped.
        else
        {
            advancedSearchBtn.isEnabled = false
            nameSearchSelected = false
            view.endEditing(true)
            searchBar.placeholder = "Søk på organisasjonsnummer..."
            searchBar.keyboardType = .numberPad
            endAdvanceView()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let txt = searchBar.text
        {
            updateSearchResults(text: txt)
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func advancedSearchTapped(_ sender: UIBarButtonItem)
    {
        if advancedSearchBtn.title == "Vanlig søk"
        {
            endAdvanceView()
        }
        else
        {
            advancedSearchBtn.title = "Vanlig søk"
            advancedView.isHidden = false
        }
    }
    
    //Edit the input text and add the correct formatting.
    func updateSearchResults(text:String)
    {
        let searchTextEdit = text.replacingOccurrences(of: " ", with: "+")
        let searchTextFinalOrg = text.replacingOccurrences(of: " ", with: "+")
        
        searchTextFinal = ".json?page=0&size=10&$filter=startswith(navn,'\(searchTextEdit)')"
        
        if let employee = employeeTxtField.text
        {
            if employee != ""
            {
                searchTextFinal = "\(searchTextFinal!)+and+antallAnsatte+ge+\(employee)"
            }
        }
        
        if let place = placeTextField.text
        {
            if place != ""
            {
                searchTextFinal = "\(searchTextFinal!)+and+forretningsadresse/poststed+eq+'\(place)'"
            }
        }
        
        switch nameSearchSelected
        {
        case false:
                dataStorageVar = dataStorage(searchText: searchTextFinalOrg, nameSearch: false)
                searchTextFinal = searchTextFinalOrg
                cacheTester()
        default:
                dataStorageVar = dataStorage(searchText: searchTextFinal, nameSearch: true)
                cacheTester()
        }
    }
    
    //Run when the advance view is untapped.
    func endAdvanceView()
    {
        searchBar.text?.removeAll()
        advancedSearchBtn.title = "Avansert søk"
        advancedView.isHidden = true
        employeeTxtField.text?.removeAll()
        placeTextField.text?.removeAll()
        if let txt = searchBar.text
        {
            updateSearchResults(text: txt)
        }
    }
    
    //Check if we have data stored in cache. If yes load from cache, if no download then store in cache.
    func cacheTester()
    {
        if let isCached = dataStorage.nameCache.object(forKey: "\(searchTextFinal)0" as NSString)
        {
            print("mainVC: We will retrieve data from cache, tested with \(isCached)")
            self.tableView.reloadData()
        }
            
        else
        {
            print("mainVC: No data found in cache, start download and store data.")
            dataStorageVar.downloadData
            {
                var count = 0
                for obj in self.dataStorageVar.nameArray
                {
                        dataStorage.nameCache.setObject(obj as NSString, forKey: "\(self.searchTextFinal)\(count)" as NSString)
                        count += 1
                }
                self.tableView.reloadData()
            }
        }
    }
}

