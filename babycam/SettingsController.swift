import UIKit

class SettingsController: UITableViewController {
  let EXAMPLE_ADDR = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
  let player = VideoPlayer.shared

  @IBOutlet weak var rtspAddr: UITextField!
  @IBOutlet weak var autoReconnect: UISwitch!
  
  @IBAction func rtspEditDone(_ sender: UITextField) {
    if rtspAddr.text != "" {
      player.addr = rtspAddr.text
    } else {
      player.addr = nil
    }
  }
  
  @IBAction func onUseExample(_ sender: Any) {
    rtspAddr.text = EXAMPLE_ADDR
    player.addr = EXAMPLE_ADDR
  }
  
  @IBAction func toggleAutoReconnect(_ sender: UISwitch) {
    player.autoReconnect = sender.isOn
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if let t = autoReconnect {
      t.isOn = player.autoReconnect
    }
    if let t = rtspAddr {
      t.text = player.addr
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    rtspEditDone(rtspAddr)
  }
}
