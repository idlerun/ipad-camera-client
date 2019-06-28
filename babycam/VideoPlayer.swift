//
//  VideoPlayer.swift
//  babycam
//
//  Created by user on 2019-05-09.
//  Copyright © 2019 idle. All rights reserved.
//

import Foundation

extension Notification.Name {
  static let onNoURL = Notification.Name("on-no-url")
  static let onFrame = Notification.Name("on-frame")
  static let onAddrChange = Notification.Name("on-addr-change")
  static let onMissedFrameWarning = Notification.Name("on-missed-frame-warning")
  static let onMissedFrameRestart = Notification.Name("on-missed-frame-restart")
}

class VideoPlayer {

  static let shared = VideoPlayer()


  let defaults = UserDefaults.standard
  let DEFAULT_KEY_RTSPADDR = "rtspAddr"
  let DEFAULT_KEY_AUTORECONNECT = "autoReconnect"
  let WARNING_TIME_BETWEEN_FRAMES = 10.0
  let MAX_TIME_BETWEEN_FRAMES = 30.0
  
  var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
  var timer: Timer?
  var lastFrameTC: NSNumber?
  var lastFrameClock: Double?
  var paused = false
  
  var autoReconnect: Bool {
    get {
      return defaults.bool(forKey: DEFAULT_KEY_AUTORECONNECT)
    }
    set(b) {
      defaults.set(b, forKey: DEFAULT_KEY_AUTORECONNECT)
    }
  }

  var addr: String? {
    get {
      if let m = mediaPlayer.media {
        return m.url.absoluteString
      } else {
        return nil
      }
    }
    
    set(newaddr) {
      let url = addr
      if url == newaddr {
        return
      }
      if let a = newaddr {
        defaults.set(a, forKey: DEFAULT_KEY_RTSPADDR)
      } else {
        defaults.removeObject(forKey: DEFAULT_KEY_RTSPADDR)
      }
      updateMediaUrl()
    }
  }
  
  private func getMediaUrl() -> String? {
    let saved = defaults.string(forKey: DEFAULT_KEY_RTSPADDR)
    if let s = saved {
      if s != "" {
        return s
      }
    }
    return nil
  }
  
  private func updateMediaUrl() {
    let url = getMediaUrl()
    if let u = url {
      NSLog("Updating to url \(u)")
      let media = VLCMedia(url: URL(string: u)!)
      // https://wiki.videolan.org/VLC_command-line_help
      media.addOptions([
        "network-caching": 300
        ])
      NotificationCenter.default.post(name: .onAddrChange, object: nil)
      mediaPlayer.media = media
      if !paused {
        resume()
      }
    } else {
      pause()
      mediaPlayer.media = nil
      NotificationCenter.default.post(name: .onNoURL, object: nil)
    }
  }
  
  var secondsSinceLastFrame: Double {
    get {
      let now = CACurrentMediaTime()
      if let last = lastFrameClock {
        return now - last
      }
      return 0
    }
  }
  
  func pause() {
    paused = true
    mediaPlayer.stop()
    if let t = timer {
      t.invalidate()
      timer = nil
    }
  }
  
  func resume() {
    NSLog("Resume")
    paused = false
    if timer == nil {
      timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.checkReceivingFrames), userInfo: nil, repeats: true)
    }
    lastFrameClock = CACurrentMediaTime();
    mediaPlayer.stop()
    mediaPlayer.play()
  }
  
  
  @objc func checkReceivingFrames(){
    if mediaPlayer.time != nil {
      if let t = mediaPlayer.time.value {
        if (lastFrameTC == nil || t != lastFrameTC) {
          lastFrameTC = t
          lastFrameClock = CACurrentMediaTime();
          if mediaPlayer.videoSize.width != 0 {
            // broadcast receivedFrame event
            NotificationCenter.default.post(name: .onFrame, object: nil)
          }
          return
        }
      }
    }
    
    // check if too much time has passed between receiving frame
    let elapsed = secondsSinceLastFrame
    if (elapsed > 1.0) {
      NSLog("Elapsed since frame %f", elapsed)
    }
    if (elapsed > WARNING_TIME_BETWEEN_FRAMES) {
      NotificationCenter.default.post(name: .onMissedFrameWarning, object: nil)
    }
    if (elapsed > MAX_TIME_BETWEEN_FRAMES) {
      if autoReconnect {
        NotificationCenter.default.post(name: .onMissedFrameRestart, object: nil)
        resume()
      }
    }
  }
  
  private init() {
    mediaPlayer.adjustFilterEnabled = true
    mediaPlayer.gamma = 1
    updateMediaUrl()
  }
}
