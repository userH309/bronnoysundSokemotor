import UIKit

class detailsVC: UIViewController,UINavigationBarDelegate
{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var orgNumber: UILabel!
    @IBOutlet weak var about: UITextView!
    @IBOutlet weak var startupDate: UILabel!
    @IBOutlet weak var webpageButton: UIButton!
    @IBOutlet weak var fullAddress: UIButton!
    @IBOutlet weak var numberEmployees: UILabel!
    
    var city:String!
    var street:String!
    var postalcode:String!
    var cellName:String!
    var url:URL!
    var mapURL = URL(string: "")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI()
    {
        webpageButton.isHidden = true
        self.name.text = cellName
        
        //Set the orgNumber label
        if let orgnumber = dataStorage.orgNumbeCache.object(forKey: cellName as NSString)
        {
            orgNumber.text = orgnumber as String
        }
        
        //Set the startup date label, n/a if it don't exist.
        if var startup = dataStorage.startupCache.object(forKey: cellName as NSString)
        {
            if startup == ""
            {
                startup = "n/a"
            }
            startupDate.text = startup as String
        }
        
        //Set the about textfield text.
        if let aboutOrg = dataStorage.aboutCache.object(forKey: cellName as NSString)
        {
            about.text = aboutOrg as String
        }
        
        //Set the number of employees label.
        if let numEmployees = dataStorage.numEmployeesCache.object(forKey: cellName as NSString)
        {
            numberEmployees.text = numEmployees as String
        }
        
        if let streetTemp = dataStorage.streetCache.object(forKey: cellName as NSString)
        {
            street = streetTemp.capitalized as String
        }
        else
        {
            street = ""
        }
        
        if let postalCodeTemp = dataStorage.postalCache.object(forKey: cellName as NSString)
        {
            postalcode = postalCodeTemp as String
        }
        else
        {
            postalcode = ""
        }
        
        if let cityTemp = dataStorage.cityCache.object(forKey: cellName as NSString)
        {
            city = cityTemp.capitalized as String
        }
        else
        {
            city = ""
        }
        
        //Change button name to address.
        fullAddress.setTitle("\(street!), \(postalcode!) \(city!)", for: .normal)
    
        //Prepare webpage button.
        if let webpage = dataStorage.webpageCache.object(forKey: cellName as NSString)
        {
            if webpage != ""
            {
                let urlStringWeb = "http://\(webpage)"
                url = URL(string: urlStringWeb)
                print("detailsVC: mapURL:\(url!)")
                webpageButton.setTitle(urlStringWeb, for: .normal)
                webpageButton.isHidden = false
            }
        }

        
        let urlStringMap = "http://maps.apple.com/?address=\(postalcode!),\(street!.replacingOccurrences(of: " ", with: ".,"))"
        mapURL = URL(string: urlStringMap)
    }
    
    //Run if webpage button is tapped, make sure we can open webpage, then open.
    @IBAction func webpageTapped(_ sender: UIButton)
    {
        if url != nil
        {
            if UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url, options: [:], completionHandler:
                {
                    (success) in
                    print("detailsVC: Open webpage success : \(success).")
                })
            }
        }
        else
        {
            print("detailsVC: Failed to webpage.")
        }
        
    //Run if address button is tapped, make sure we can open webpage, then open.
    }
    @IBAction func openMapsTapped(_ sender: UIButton)
    {
        if mapURL != nil
        {
            if UIApplication.shared.canOpenURL(mapURL!)
            {
                UIApplication.shared.open(mapURL!, options: [:], completionHandler:
                {
                    (success) in
                    print("detailsVC: Open map success : \(success).")
                })
            }
        }
        else
        {
            print("detailsVC: Failed to open map.")
        }
    }
    
}
