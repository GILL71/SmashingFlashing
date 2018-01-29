//
//  Recorder.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 30.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import Foundation

import Foundation
import AVFoundation
import UIKit

class Recorder: NSObject, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var settings = [String : Int]()
    var storage = RecordRealmDataSource()
    let documentsDirectory = DocsDirectory.path
    
    override init() {
        recordingSession = AVAudioSession.sharedInstance()
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    func recordOr(_ resume: Bool) {
        if resume {
            audioRecorder.record()
        } else if audioRecorder == nil {
            startRecording()
        }
    }
    
    func pause() {
        audioRecorder.pause()
    }
    
    func prepareForRecording() {
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Allow")
                    } else {
                        print("Dont Allow")
                    }
                }
            }
        } catch {
            print("failed to record!")
        }
    }
    
    func startRecording() {
        prepareForRecording()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: documentsDirectory.appendingPathComponent("123456789.m4a")!,
                                                settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            finishRecording(success: false, name: "")
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {
        }
    }
    
    func finishRecording(success: Bool, name: String) {
        if success {
            print(success)
            
            var resourceValues = URLResourceValues.init()
            resourceValues.name = name
            var url = audioRecorder.url
            do {
                try url.setResourceValues(resourceValues)
            } catch {
                print(error.localizedDescription)
            }
            //var urlString = "file:"
            //urlString = urlString.appending((documentsDirectory.path?.appending("/" + name))!)
            let docsRL = DocsDirectory.path
            let urlString = docsRL.appendingPathComponent(name)! as URL
            do {
                let audioData = try Data(contentsOf: urlString)
                storage.insert(item: Record(audio: audioData,
                                            name: name,
                                            urlString: String(describing: urlString),
                                            duration: Double(CMTimeGetSeconds((AVURLAsset(url: urlString)).duration))))
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("Somthing Wrong.")
        }
        audioRecorder = nil
    }
    
    func cancelRecording() {
        do {
            try FileManager().removeItem(at: audioRecorder.url)
            audioRecorder = nil
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false, name: "")
        }
    }
    
    func duration(for resource: String) -> Double {
        let asset = AVURLAsset(url: URL(fileURLWithPath: resource))
        //let asset = AVURLAsset(url: resource)
        print(asset.duration)
        return Double(CMTimeGetSeconds(asset.duration))
    }
}
