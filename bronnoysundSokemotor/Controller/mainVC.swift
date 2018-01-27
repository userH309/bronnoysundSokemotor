import UIKit

class mainVC: UIViewController,UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    var dataStorageVar:dataStorage!
    var nameSearchSelected:Bool!
    static var nameCache:NSCache<NSString, NSArray> = NSCache()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        dataStorageVar = dataStorage(searchText: "", nameSearch: true)
        dataStorageVar.nameArray = [""]
        nameSearchSelected = true
        searchBar.placeholder = "Søk på navn..."
        searchBar.returnKeyType = .done
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
        return dataStorageVar.nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "srcResCell", for: indexPath) as? srcResCell
        {
            let nameArray = dataStorageVar.nameArray[indexPath.row]
            cell.configureCell(nameInput: nameArray)
            return cell
        }
        else
        {
            return UITableViewCell()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let downloadedDataDict : Dictionary <String,String>!
        
        //Add to downloadDataDict
        downloadedDataDict = ["name":(dataStorageVar.nameArray[indexPath.row]),"orgNumber":(dataStorageVar.orgNumberArray[indexPath.row]),"startupDate":(dataStorageVar.startupDateArray[indexPath.row]),"webpage":(dataStorageVar.webpageArray[indexPath.row]),"about":(dataStorageVar.aboutArray[indexPath.row]),"street":(dataStorageVar.streetArray[indexPath.row]),"postalCode":(dataStorageVar.postalCodeArray[indexPath.row]),"city":(dataStorageVar.cityArray[indexPath.row])]

        let transferDict = downloadedDataDict
        performSegue(withIdentifier: "detailsVC", sender: transferDict)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "detailsVC"
        {
            if let detailsVC = segue.destination as? detailsVC
            {
                if let transferTemp = sender as? Dictionary<String,String>
                {
                    detailsVC.dataInput = transferTemp
                }
            }
        }
    }
    
    //Kjør hvis teksten i søkefeltet endrer seg
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        switch nameSearchSelected
        {
        case false:
            //hvis søke teksten finne som cache key, så lagre array fra cache in i en variabel.
            if let cacheArray = mainVC.nameCache.object(forKey: searchText as NSString)
            {
                dataStorageVar.nameArray = cacheArray as! [String]
                self.tableView.reloadData()
            }
            else
            {
                //Initialiser dataStorage med verdien til teksten i søkefeltet.
                dataStorageVar = dataStorage(searchText: searchText, nameSearch: false)
                //Start funksjonen downloadData
                dataStorageVar.downloadData
               {
                        //HER BURDE DET CACHES
                        mainVC.nameCache.setObject(self.dataStorageVar.nameArray as NSArray, forKey: searchText as NSString)
                        self.tableView.reloadData()
                }
            }
        default:
            //hvis søke teksten finne som cache key, så lagre array fra cache in i en variabel.
            if let cacheArray = mainVC.nameCache.object(forKey: searchText as NSString)
            {
                dataStorageVar.nameArray = cacheArray as! [String]
                self.tableView.reloadData()
            }
            else
            {
                //Initialiser dataStorage med verdien til teksten i søkefeltet.
                dataStorageVar = dataStorage(searchText: searchText, nameSearch: true)
                //Start funksjonen downloadData
                dataStorageVar.downloadData
                    {
                        //HER BURDE DET CACHES
                        mainVC.nameCache.setObject(self.dataStorageVar.nameArray as NSArray, forKey: searchText as NSString)
                        self.tableView.reloadData()
                }
            }
    }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        view.endEditing(true)
    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl)
    {
        if segmentController.selectedSegmentIndex == 0
        {
            nameSearchSelected = true
            view.endEditing(true)
            searchBar.placeholder = "Søk på navn..."
            searchBar.keyboardType = .asciiCapable
            searchBar.text?.removeAll()
        }
        else
        {
            nameSearchSelected = false
            view.endEditing(true)
            searchBar.placeholder = "Søk på organisasjonsnummer..."
            searchBar.keyboardType = .numberPad
            searchBar.text?.removeAll()
        }
    }
}
