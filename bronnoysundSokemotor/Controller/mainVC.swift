import UIKit

class mainVC: UIViewController,UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var advancedSearchBtn: UIBarButtonItem!
    @IBOutlet weak var advancedView: UIView!
    @IBOutlet weak var employeeTxtField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    var areInCache:Bool!
    var isAdvanceSearching: Bool!
    var nameSearchSelected:Bool!
    var dataStorageVar:dataStorage!
    var searchTextFinal:String!
    
    override func viewDidLoad() {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "srcResCell", for: indexPath) as? srcResCell {
            //Check cache for stored values.
            if let name = dataStorage.nameCache.object(forKey: "\(searchTextFinal)\(indexPath.row)" as NSString) {
                //Pass value to the configureCell where the magic happens.
                cell.configureCell(nameInput: name as String)
                return cell
            }
            //If the we don't get a value from cache.
            else {
                //Pass in an empty string to the configureCell function.
                cell.configureCell(nameInput: "")
                return cell
            }
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Use indexPath.row combined with searchTextFinal to get the correct key.
        if let nameSelected = dataStorage.nameCache.object(forKey: "\(searchTextFinal)\(indexPath.row)" as NSString) {
            //Pass on the organisation name to detailsVC class.
            performSegue(withIdentifier: "detailsVC", sender: nameSelected as String)
            //The row will be deselected when user goes back to mainVC.
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    //Hide keyboard when scrolling table view.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    //Update SearchResults when user switch vc's to refill cache.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        updateSearchResults(text: searchBar.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Check if ID, destination and sender is correct, then pass to detailsVC.
        if segue.identifier == "detailsVC" {
            if let detailsVC = segue.destination as? detailsVC {
                if let name = sender as? String {
                    detailsVC.cellName = name
                }
            }
        }
    }
    
    //Pass in searchBar text to updateSearchResult when text changes.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(text: searchText)
    }
    
    //Hide keyboard when search bar button is tapped.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    //User can search for orgNumber or orgName.
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        //When selecting Segment 0 user can search for org name.
        if segmentController.selectedSegmentIndex == 0 {
            advancedSearchBtn.isEnabled = true
            nameSearchSelected = true
            view.endEditing(true)
            searchBar.placeholder = "Søk på navn..."
            searchBar.keyboardType = .asciiCapable
            endAdvanceView()
        }
        //When selecting Segment 1 user can search for org number.
        else {
            advancedSearchBtn.isEnabled = false
            nameSearchSelected = false
            view.endEditing(true)
            searchBar.placeholder = "Søk på organisasjonsnummer..."
            searchBar.keyboardType = .numberPad
            endAdvanceView()
        }
    }
    
    //Hide keyboard when return button is tapped.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Store value from search bar, then pass this on to updateSearchResult.
        if let txt = searchBar.text {
            updateSearchResults(text: txt)
            //Hide keyboard.
            textField.resignFirstResponder()
        }
        return true
    }
    
    //Run when user taps the searchModeBtn.
    @IBAction func searchModeBtn(_ sender: UIBarButtonItem) {
        //End advance view if user is already in it.
        if isAdvanceSearching == true {
            endAdvanceView()
        }
        //Start advance view if user is not in it.
        else {
            advancedSearchBtn.title = "Vanlig søk"
            advancedView.isHidden = false
        }
    }

    //Run when user switches VC's or searchmode, searchBar text changes, on return tap.
    func updateSearchResults(text:String) {
        //Replace spaces in text field value with + to avoid URL fails.
        let searchTextEdit = text.replacingOccurrences(of: " ", with: "+")
        let searchTextFinalOrg = text.replacingOccurrences(of: " ", with: "+")
        
        //Combine searchTextEdit with extra string format we got from bronnoysund.no
        searchTextFinal = ".json?page=0&size=10&$filter=startswith(navn,'\(searchTextEdit)')"
        
        //Using advance search amount of employees, we add additional string filter.
        if let employee = employeeTxtField.text {
            if employee != "" {
                searchTextFinal = "\(searchTextFinal!)+and+antallAnsatte+ge+\(employee)"
            }
        }
        
        //Using advance search place of organisation, we add additional string filter.
        if let place = placeTextField.text {
            if place != "" {
                searchTextFinal = "\(searchTextFinal!)+and+forretningsadresse/poststed+eq+'\(place)'"
            }
        }
        
        //Check if user searches with orgNumber or orgName.
        switch nameSearchSelected {
        //User is searching with orgNumber.
        case false:
            dataStorageVar = dataStorage(searchText: searchTextFinalOrg, nameSearch: false)
            searchTextFinal = searchTextFinalOrg
            cacheTester()
        default:
        //User is searching with orgName.
            dataStorageVar = dataStorage(searchText: searchTextFinal, nameSearch: true)
            cacheTester()
        }
    }
    
    func cacheTester() {
        //The data is cached, we do not need to download again, just reload tableview.
        if let isCached = dataStorage.nameCache.object(forKey: "\(searchTextFinal)0" as NSString) {
            print("mainVC: We will retrieve data from cache, tested with \(isCached)")
            self.tableView.reloadData()
        }
            
        //The data is not cached, we need to download.
        else {
            print("mainVC: No data found in cache, start download and store data.")
            
            //Store in cache after data is downloaded.
            dataStorageVar.downloadData {
                //Use counter at the end to distiguish between the keys.
                var count = 0
                //In this moment the searchTextFinal will have the same value.
                for obj in self.dataStorageVar.nameArray {
                    //We use searchTextFinal + count as key for easy retrieve later.
                    dataStorage.nameCache.setObject(obj as NSString, forKey: "\(self.searchTextFinal)\(count)" as NSString)
                    count += 1
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //Clean up when user switches searchMode.
    func endAdvanceView() {
        searchBar.text?.removeAll()
        isAdvanceSearching = false
        advancedSearchBtn.title = "Avansert søk"
        advancedView.isHidden = true
        employeeTxtField.text?.removeAll()
        placeTextField.text?.removeAll()
        if let txt = searchBar.text {
            updateSearchResults(text: txt)
        }
    }
}

