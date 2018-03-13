import Foundation
import Alamofire

class dataStorage {
    var nameSearchStatus:Bool!
    var nameArray = [String]()
    private var _searchText:String!
    static var nameCache:NSCache<NSString, NSString> = NSCache()
    static var orgNumbeCache:NSCache<NSString, NSString> = NSCache()
    static var startupCache:NSCache<NSString, NSString> = NSCache()
    static var aboutCache:NSCache<NSString, NSString> = NSCache()
    static var streetCache:NSCache<NSString, NSString> = NSCache()
    static var postalCache:NSCache<NSString, NSString> = NSCache()
    static var cityCache:NSCache<NSString, NSString> = NSCache()
    static var numEmployeesCache:NSCache<NSString, NSString> = NSCache()
    static var webpageCache:NSCache<NSString, NSString> = NSCache()
    static var searchCache:NSCache<NSString, NSString> = NSCache()
    
    //Check if search is org or namesearch. Store the combined string to _searchText.
    init(searchText:String, nameSearch:Bool) {
        switch nameSearch {
        case false:
            nameSearchStatus = false
            self._searchText = "\(BASE_URL)/\(searchText).json"
        default:
            nameSearchStatus = true
            self._searchText = "\(BASE_URL)\(searchText)"
        }
    }
    
//-------Example of the JSON we will get------
//    {
//    "links":[  ],
//    "data":[
//          {
//          "organisasjonsnummer":818940262,
//           "navn":"FASADEPROSJEKT AS",
//           "stiftelsesdato
    //Start download data asynchronous, then mark as complete after download.
    func downloadData(completed: @escaping downloadComplete) {
        //Request response in JSON.
        Alamofire.request(_searchText).responseJSON { response in
                //Get the entire JSON.
                if let dict = response.result.value as? Dictionary<String,AnyObject> {
                    //If nameSearch, we dig a bit deeper to get the data.
                    if self.nameSearchStatus == true {
                        if let data = dict["data"] as? [Dictionary<String,AnyObject>] {
                            //Getting an array of dictionaries that we have to iterate.
                            for obj in data {
                                self.pickData(obj: obj)
                            }
                        }
                    }
                    //If orgNumber search, we'll have the data we need.
                    else {
                        self.pickData(obj: dict)
                    }
                }
                completed()
        }
    }
    
    //Pick data we need and store in separate caches with respective keys.
    func pickData(obj:Dictionary<String,AnyObject>) {
        var name:String!
        //Get the name.
        if let navn = obj["navn"] as? String {
            name = navn
            dataStorage.nameCache.setObject(navn as NSString, forKey: name as NSString)
            nameArray.append(name)
        }
        //Get org number.
        if let organisasjonsnummer = obj["organisasjonsnummer"] as? Int {
            dataStorage.orgNumbeCache.setObject("\(organisasjonsnummer)" as NSString, forKey: name as NSString)
        }
        //Get startup date.
        if let stiftelsesdato = obj["stiftelsesdato"] as? String {
            dataStorage.startupCache.setObject(stiftelsesdato as NSString, forKey: name as NSString)
        }
        //Get the number of employess
        if let antallAnsatte = obj["antallAnsatte"] as? Int {
            dataStorage.numEmployeesCache.setObject("\(antallAnsatte)" as NSString, forKey: name as NSString)
        }
        //Get homepage.
        if let hjemmeside = obj["hjemmeside"] as? String {
            dataStorage.webpageCache.setObject("\(hjemmeside)" as NSString, forKey: name as NSString)
        }
        //Get description.
        if let naeringskode1 = obj["naeringskode1"] as? Dictionary<String,AnyObject> {
            if let beskrivelse = naeringskode1["beskrivelse"] as? String {
                dataStorage.aboutCache.setObject(beskrivelse as NSString, forKey: name as NSString)
            }
        }
        //Enter the address dictionary.
        if let forretningsadresse = obj["forretningsadresse"] as? Dictionary<String,AnyObject> {
            //Get street address.
            if let adresse = forretningsadresse["adresse"] as? String {
                dataStorage.streetCache.setObject(adresse as NSString, forKey: name as NSString)
            }
            //Get postal code.
            if let postnummer = forretningsadresse["postnummer"] as? String {
                dataStorage.postalCache.setObject(postnummer as NSString, forKey: name as NSString)
            }
            if let poststed = forretningsadresse["poststed"] as? String {
                dataStorage.cityCache.setObject(poststed as NSString, forKey: name as NSString)
            }
        }
    }
}
