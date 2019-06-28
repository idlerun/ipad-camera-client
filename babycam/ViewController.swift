import UIKit

class ViewController: UIViewController, VLCMediaPlayerDelegate {

  let player = VideoPlayer.shared
  let notify = NotificationCenter.default
  var firstAppearance = true
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var movieView: UIView!
  @IBOutlet weak var statusLabel: UILabel!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBAction func onClickSettings(_ sender: Any) {
    player.pause()
    performSegue(withIdentifier: "showSettings", sender: self)
  }
  
  override func viewDidLoad() {
    NSLog("viewDidLoad")
    super.viewDidLoad()
    notify.addObserver(self, selector: #selector(onActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    notify.addObserver(self, selector: #selector(onInactive), name: UIApplication.willResignActiveNotification, object: nil)
    notify.addObserver(self, selector: #selector(onFrame), name: .onFrame, object: nil)
    notify.addObserver(self, selector: #selector(onMissedFrameWarning), name: .onMissedFrameWarning, object: nil)
    notify.addObserver(self, selector: #selector(onMissedFrameRestart), name: .onMissedFrameRestart, object: nil)
    notify.addObserver(self, selector: #selector(onAddrChange), name: .onAddrChange, object: nil)
    notify.addObserver(self, selector: #selector(onNoURL), name: .onNoURL, object: nil)
    
    if player.addr != nil {
      statusLabel.text = "Connecting.."
    }
  }
  
  @objc func onFrame(){
    //NSLog("onFrame")
    statusLabel.text = ""
  }
  
  @objc func onNoURL(){
    //NSLog("onFrame")
    if let s = statusLabel {
      s.text = "No address is configured"
    }
  }
  
  @objc func onAddrChange(){
    NSLog("onAddrChange")
    statusLabel.text = "Connecting.."
  }
  
  @objc func onMissedFrameWarning(){
    NSLog("onMissedFrameWarning")
    statusLabel.text = "Warning: Last frame received \(Int(round(player.secondsSinceLastFrame)))s ago"
  }
  
  @objc func onMissedFrameRestart(){
    NSLog("onMissedFrameRestart")
    statusLabel.text = "Frames have stopped. Reconnecting.."
  }
  
  
  @objc func onActive(){
    NSLog("onActive")
    if player.paused {
      if player.addr != nil {
        player.resume()
        if let s = statusLabel {
          s.text = "Resuming.."
        }
      } else {
        onNoURL()
      }
    }
  }
  
  @objc func onInactive(){
    NSLog("onInactive")
    player.pause()
    statusLabel.text = "Paused"
  }

  override func viewDidAppear(_ animated: Bool) {
    NSLog("viewDidAppear")
    scrollView.minimumZoomScale = 1
    scrollView.maximumZoomScale = 4
    scrollView.zoomScale = 1
    player.mediaPlayer.delegate = self
    player.mediaPlayer.drawable = self.movieView
    
    if player.addr != nil {
      player.resume()
    } else if (firstAppearance) {
      performSegue(withIdentifier: "showSettings", sender: self)
    }
    firstAppearance = false
  }
}

extension ViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return movieView
  }
}
