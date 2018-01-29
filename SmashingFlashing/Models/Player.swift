//
//  Player.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 30.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import Foundation
import AVFoundation
import RealmSwift

class Player: NSObject {
    let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    let player = AVPlayer()
    var playerItems = [AVPlayerItem]()
    @objc dynamic var currentTrack = 0
    
    func previousTrack() {
        playerItems[currentTrack].seek(to: kCMTimeZero, completionHandler: nil)
        if currentTrack - 1 < 0 {
            currentTrack = (playerItems.count - 1) < 0 ? 0 : (playerItems.count - 1)
        } else {
            currentTrack -= 1
        }
        playTrack()
    }
    
    func nextTrack() {
        playerItems[currentTrack].seek(to: kCMTimeZero, completionHandler: nil)
        if currentTrack + 1 >= playerItems.count {
            currentTrack = 0
        } else {
            currentTrack += 1
        }
        playTrack()
    }
    
    func playTrack() {
        if playerItems.count > 0 {
            player.replaceCurrentItem(with: playerItems[currentTrack])
            player.play()
        }
    }
    
    func prepareForPlay(fromRepo records: Results<RealmRecord>, from index: Int) {
        playerItems.removeAll()
        currentTrack = index
        var urlString = "file:"
        for record in records {
            urlString = urlString.appending(docsDir.appending("/" + record.name))
            let item = AVPlayerItem(url: URL(string: urlString)!)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.finishedPlaying(myNotification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: item)
            playerItems.append(item)
            urlString = "file:"
        }
        playTrack()
    }
    
    func changeVolume(with value: Float) {
        player.volume = value
    }
    
    func changeProgressWith(value: Float) {
        
    }
    
    @objc func finishedPlaying(myNotification: Notification) {
        let stopedPlayerItem: AVPlayerItem = myNotification.object as! AVPlayerItem
        stopedPlayerItem.seek(to: kCMTimeZero, completionHandler: nil)
        nextTrack()
    }
}
