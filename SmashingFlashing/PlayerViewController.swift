//
//  PlayerViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 04.11.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos
class PlayerViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    var mediaUrl: URL?
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var asset: PHAsset?
    var isVideoPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = mediaUrl else {
            //show alert with invalid url
            print("NO URL - CRASH")
            return
        }
        //let url = URL(string: "file:///Users/Nechaev/Library/Developer/CoreSimulator/Devices/4D4CCF19-A478-4884-B610-ACE5C3C455F1/data/Media/DCIM/100APPLE/IMG_0006.MOV")!
        playButton.isEnabled = true
        timeSlider.value = 0
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        player.currentItem?.addObserver(self, forKeyPath:"duration", options: [.new, .initial], context: nil)
        addTimeObserver()
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        /*videoView.addConstraint(NSLayoutConstraint(item: videoView,
                                                   attribute: .width,
                                                   relatedBy: .equal,
                                                   toItem: videoView,
                                                   attribute: .height,
                                                   multiplier: 9.0/16.0,//getMultiplierValue(from: url),
                                                   constant: 0))*/
        //NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        if isVideoPlaying {
            player.pause()
            sender.setTitle("Play", for: .normal)
        } else {
            player.play()
            sender.setTitle("Pause", for: .normal)
        }
        isVideoPlaying = !isVideoPlaying
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(Int64(sender.value*1000), 1000))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationLabel.text = player.currentItem?.duration.timeString
        }
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let queue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text? = currentItem.currentTime().timeString
            //self?.durationLabel.text = self?.getTimeString(from: currentItem.duration - currentItem.currentTime())
        })
    }
    
    func getMultiplierValue(from url: URL) -> CGFloat {
        let sizeOfVideo = AVAsset(url: url).tracks(withMediaType: AVMediaType.video)[0].naturalSize
        if sizeOfVideo.height / sizeOfVideo.width > 1 {
            return sizeOfVideo.height / sizeOfVideo.width
        } else {
            return sizeOfVideo.width / sizeOfVideo.height
        }
    }
}

extension CMTime {
    public var timeString: String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format:"%i:%02i:%02i", arguments: [hours, minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, seconds])
        }
    }
}
