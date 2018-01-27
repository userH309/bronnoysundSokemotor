import Foundation
import Alamofire

class dataStorage
{
    var nameSearchStatus:Bool!
    
    private var _URL:String!
    private var _searchText:String!
    
    var nameArray = [String]()
    var orgNumberArray = [String]()
    var startupDateArray = [String]()
    var aboutArray = [String]()
    var streetArray = [String]()
    var postalCodeArray = [String]()
    var cityArray = [String]()
    var webpageArray = [String]()
    
    init(searchText:String, nameSearch:Bool)
    {
        switch nameSearch
        {
        case false:
            nameSearchStatus = false
            let searchTextEdit = searchText.replacingOccurrences(of: " ", with: "+")
            self._searchText = "\(BASE_URL)/\(searchTextEdit).json"
        default:
            nameSearchStatus = true
            let searchTextEdit = searchText.replacingOccurrences(of: " ", with: "+")
            self._searchText = "\(BASE_URL).json?page=0&size=10&$filter=startswith(navn,'\(searchTextEdit)')"
        }
        
    }
    
    //Last ned data og marker som ferdig med completed().
    func downloadData(completed: @escaping downloadComplete)
    {
        print("URL: \(_searchText)")
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
    
    //Funksjon får å hente spesifikk data.
    func pickData(obj:Dictionary<String,AnyObject>)
    {
        //Hent navnet på organisasjonen.
        if let navn = obj["navn"] as? String
        {
            self.nameArray.append(navn)
        }
        //Hent organisasjonsnummer.
        if let organisasjonsnummer = obj["organisasjonsnummer"] as? Int
        {
            self.orgNumberArray.append("\(organisasjonsnummer)")
        }
        else
        {
            self.orgNumberArray.append("")
        }
        //Hent oppstartsdato.
        if let startDate = obj["stiftelsesdato"] as? String
        {
            self.startupDateArray.append(startDate)
        }
        else
        {
            self.startupDateArray.append("")
        }
        //Hent eventuell hjemmeside.
        if let webpage = obj["hjemmeside"] as? String
        {
            self.webpageArray.append("http://\(webpage)")
        }
        else
        {
            self.webpageArray.append("")
        }
        //Hent beskrivelse av organisasjonen.
        if let naeringskode1 = obj["naeringskode1"] as? Dictionary<String,AnyObject>
        {
            if let beskrivelse = naeringskode1["beskrivelse"] as? String
            {
                self.aboutArray.append(beskrivelse)
            }
            else
            {
                self.aboutArray.append("")
            }
        }
        //Hent detaljer om adressen.
        if let forretningsadresse = obj["forretningsadresse"] as? Dictionary<String,AnyObject>
        {
            if let adresse = forretningsadresse["adresse"] as? String
            {
                self.streetArray.append(adresse)
            }
            else
            {
                self.streetArray.append("")
            }
            if let postnummer = forretningsadresse["postnummer"] as? String
            {
                self.postalCodeArray.append(postnummer)
            }
            else
            {
                self.postalCodeArray.append("")
            }
            if let poststed = forretningsadresse["poststed"] as? String
            {
                self.cityArray.append(poststed)
            }
            else
            {
                self.cityArray.append("")
            }
        }
    }
}
