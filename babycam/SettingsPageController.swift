import UIKit

class SettingsPageController: UIViewController {
  @IBAction func onBackClick(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onAboutClick(_ sender: Any) {
    performSegue(withIdentifier: "showAbout", sender: self)
  }
}
