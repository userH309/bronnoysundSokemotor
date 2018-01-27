import UIKit

class detailsVC: UIViewController
{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var orgNumber: UILabel!
    @IBOutlet weak var street: UILabel!
    @IBOutlet weak var postCode: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var about: UITextView!
    @IBOutlet weak var startupDate: UILabel!
    @IBOutlet weak var webpageButton: UIButton!
    @IBOutlet weak var fullAddress: UIButton!
    
    var dataInput:Dictionary<String,String>!
    var url:URL!
    var mapURL:URL!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        webpageButton.isHidden = true
        self.name.text = dataInput["name"]
        self.orgNumber.text = dataInput["orgNumber"]
        self.startupDate.text = dataInput["startupDate"]
        self.fullAddress.setTitle("\(dataInput["street"]!.capitalized), \(dataInput["postalCode"]!) \(dataInput["city"]!.capitalized)", for: .normal)
        if let webpage = dataInput["webpage"]
        {
            if webpage != ""
            {
                webpageButton.isHidden = false
                url = URL(string: webpage)
            }
        }
        if let map = URL(string: "http://maps.apple.com/?address=\(dataInput["postalCode"]!),\(dataInput["street"]!.replacingOccurrences(of: " ", with: ".,"))")
        {
            mapURL = map
        }
        self.about.text = dataInput["about"]
        self.street.text = dataInput["street"]
        self.postCode.text = dataInput["postalCode"]
        self.city.text = dataInput["city"]
    }
    @IBAction func webpageTapped(_ sender: UIButton)
    {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    @IBAction func openMapsTapped(_ sender: UIButton)
    {
        UIApplication.shared.open(mapURL, options: [:], completionHandler: nil)
    }
}
