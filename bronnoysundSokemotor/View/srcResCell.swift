import UIKit

class srcResCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    func configureCell(nameInput:String) {
        self.name.text = nameInput
    }
}
