//
//  PlayerViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 04.11.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import RealmSwift

class PlayerViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    //@IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var editPanelView: UIView!
    @IBOutlet weak var timeItem: UINavigationItem!
    @IBOutlet weak var timeSlider: UISlider!
    
    var mediaUrl: URL?
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isVideoPlaying = false
    var merger: TrueMerger?
    var storage = RecordRealmDataSource()
    
    weak var addAlertSaveAction: UIAlertAction?
    weak var cutAlertOkAction: UIAlertAction?
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    let records: Results<RealmRecord> = {
        let realm = try! Realm()
        return realm.objects(RealmRecord.self).sorted(byKeyPath: "urlString", ascending: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoUrl = mediaUrl else {
            //show alert with invalid url
            print("NO URL - CRASH")
            return
        }
        print("video:")
        print(videoUrl)
        print("/video|")
        self.tabBarController?.tabBar.isHidden = true
        playButton.isEnabled = true
        timeSlider.value = 0
        player = AVPlayer(url: videoUrl)
        playerLayer = AVPlayerLayer(player: player)
        player.currentItem?.addObserver(self, forKeyPath:"duration", options: [.new, .initial], context: nil)
        addTimeObserver()
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
        videoView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.currentItem?.removeObserver(self, forKeyPath: "duration")
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func cutAction(_ sender: UIButton) {
        let alertController = AlertManager().getCutterAlert(mediaUrl: mediaUrl!)
        self.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(Int64(sender.value*1000), 1000))
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        //alert - input name
        let alertController = UIAlertController(title: "Choose audio", message: "Input audio name for merging", preferredStyle: .alert)
        alertController.addTextField { textField in
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldTextDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.removeTextFieldObserver(alertController: alertController)
        }
        let chooseAction = UIAlertAction(title: "Choose", style: .default) { action in
            let audioName = String(describing: alertController.textFields![0].text!) + ".m4a"
            self.removeTextFieldObserver(alertController: alertController)
            if self.storage.checkBy(name: audioName) {
                let alert = UIAlertController(title: "Error", message: "No audio with input name", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.merger = TrueMerger(audio: audioName, video: self.mediaUrl!)
                self.showActivityIndicator()
                guard let resultVideoUrl = self.merger?.mergeMutableVideoWithAudio(completion: {
                    self.hideActivityIndicator()
                }) else {
                    print("bad try for video merging")
                    return
                }
                print(resultVideoUrl)
            }
            
//            if let audioUrl = self.storage.getUrlByName(name: lastComponent) {
//                self.removeTextFieldObserver(alertController: alertController)
//                self.merger = TrueMerger(audio: URL(string: audioUrl)!, video: self.mediaUrl!)
//                self.showActivityIndicator()
//                guard let resultVideoUrl = self.merger?.mergeMutableVideoWithAudio(completion: {
//                     self.hideActivityIndicator()
//                }) else {
//                    print("bad try for video merging")
//                    return
//                }
//                print(resultVideoUrl)
//            } else {
//                self.removeTextFieldObserver(alertController: alertController)
//                let alert = UIAlertController(title: "Error", message: "No audio with input name", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
        }
        chooseAction.isEnabled = false
        addAlertSaveAction = chooseAction
        alertController.addAction(cancelAction)
        alertController.addAction(chooseAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            //self.durationLabel.text = player.currentItem?.duration.timeString
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
            //
            self?.timeItem.title = currentItem.currentTime().timeString
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
    
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "Name"
    }
    
    @objc func handleTextFieldTextDidChangeNotification(sender: NSNotification) {
        let textField = sender.object as! UITextField
        addAlertSaveAction!.isEnabled = (textField.text?.count)! > 0
    }
    
    @objc func handleTextFieldTextForTimeDidChangeNotification(sender: NSNotification) {
        let textField = sender.object as! UITextField
        cutAlertOkAction!.isEnabled = (textField.text?.isNumeric)!
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1)
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.spinner)
            self.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
    
    func removeTextFieldObserver(alertController: UIAlertController) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alertController.textFields?[0])
    }
    
    func removeTextFieldTimeObserver(alertController: UIAlertController) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alertController.textFields?[0])
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alertController.textFields?[1])
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
