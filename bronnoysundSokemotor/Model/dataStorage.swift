import Foundation
import Alamofire

class dataStorage
{
    var nameSearchStatus:Bool!
    var nameArray = [String]()
    
    private var _URL:String!
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
    
    init(searchText:String, nameSearch:Bool)
    {
        switch nameSearch
        {
        case false:
            nameSearchStatus = false
            self._searchText = "\(BASE_URL)/\(searchText).json"
        default:
            nameSearchStatus = true
            self._searchText = "\(BASE_URL)\(searchText)"
        }
    }
    
    //Start retrieving data from api, sort it and store in cache. Mark as complete when done.
    func downloadData(completed: @escaping downloadComplete)
    {
        Alamofire.request(_searchText).responseJSON
            {
                response in
                if let dict = response.result.value as? Dictionary<String,AnyObject>
                {
                    if self.nameSearchStatus == true
                    {
                        if let data = dict["data"] as? [Dictionary<String,AnyObject>]
                        {
                            for obj in data
                            {
                                self.pickData(obj: obj)
                                
                            }
                            
                        }
                        
                    }
                    else
                    {
                        self.pickData(obj: dict)
                        
                    }
                    
                }
                completed()
            }
            
        }
    
    //Get the specific data.
    func pickData(obj:Dictionary<String,AnyObject>)
    {
        var name:String!
        
        //Get the name.
        if let navn = obj["navn"] as? String
        {
            name = navn
            dataStorage.nameCache.setObject(navn as NSString, forKey: name as NSString)
            nameArray.append(name)
        }
        
        //Get org number.
        if let organisasjonsnummer = obj["organisasjonsnummer"] as? Int
        {
            dataStorage.orgNumbeCache.setObject("\(organisasjonsnummer)" as NSString, forKey: name as NSString)
        }
        
        //Get startup date.
        if let stiftelsesdato = obj["stiftelsesdato"] as? String
        {
            dataStorage.startupCache.setObject(stiftelsesdato as NSString, forKey: name as NSString)
        }
        
        //Get the number of employess
        if let antallAnsatte = obj["antallAnsatte"] as? Int
        {
            dataStorage.numEmployeesCache.setObject("\(antallAnsatte)" as NSString, forKey: name as NSString)
        }
        
        //Get homepage.
        if let hjemmeside = obj["hjemmeside"] as? String
        {
            dataStorage.webpageCache.setObject("\(hjemmeside)" as NSString, forKey: name as NSString)
        }
        
        //Get description.
        if let naeringskode1 = obj["naeringskode1"] as? Dictionary<String,AnyObject>
        {
            if let beskrivelse = naeringskode1["beskrivelse"] as? String
            {
                dataStorage.aboutCache.setObject(beskrivelse as NSString, forKey: name as NSString)
            }
        }
        
        //Enter the address dictionary.
        if let forretningsadresse = obj["forretningsadresse"] as? Dictionary<String,AnyObject>
        {
            //Get street address.
            if let adresse = forretningsadresse["adresse"] as? String
            {
                dataStorage.streetCache.setObject(adresse as NSString, forKey: name as NSString)
            }
            //Get postal code.
            if let postnummer = forretningsadresse["postnummer"] as? String
            {
                dataStorage.postalCache.setObject(postnummer as NSString, forKey: name as NSString)
            }
            if let poststed = forretningsadresse["poststed"] as? String
            {
                dataStorage.cityCache.setObject(poststed as NSString, forKey: name as NSString)
            }
        }
    }
}
