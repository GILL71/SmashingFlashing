//
//  WalkmanViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 31.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import Foundation
class WalkmanViewController: UIViewController {
    
    @IBOutlet var recordName: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var volume: UISlider!
    
    var storage = RecordRealmDataSource()
    @objc lazy var customPlayer = Player()
    var recordFlag = true
    var sendedIndex = 0
    
    let records: Results<RealmRecord> = {
        let realm = try! Realm()
        return realm.objects(RealmRecord.self).sorted(byKeyPath: "urlString", ascending: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver(self, forKeyPath: #keyPath(customPlayer.currentTrack), options: [.old, .new], context: nil)
        volume.minimumValue = 0.0
        volume.maximumValue = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customPlayer.prepareForPlay(fromRepo: records, from: sendedIndex)
    }
    
    @IBAction func volumeChange(_ sender: UISlider) {
        customPlayer.changeVolume(with: sender.value)
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        if recordFlag {
            playButton.setImage(UIImage(named: "Play"), for: .normal)
            recordFlag = false
            customPlayer.player.pause()
        } else {
            recordFlag = true
            playButton.setImage(UIImage(named: "Stop"), for: .normal)
            customPlayer.player.play()
        }
    }
    @IBAction func nextRecordAction(_ sender: UIButton) {
        customPlayer.nextTrack()
    }
    @IBAction func previousRecordAction(_ sender: UIButton) {
        customPlayer.previousTrack()
    }
    
    // MARK: - Key-Value Observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(customPlayer.currentTrack) {
            recordName.text = records[customPlayer.currentTrack].name
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObserver(self, forKeyPath: #keyPath(customPlayer.currentTrack))
    }
}
