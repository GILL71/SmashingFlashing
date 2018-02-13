//
//  TrueMerger.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 11.01.18.
//  Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import Foundation
import AVFoundation
import RealmSwift
import Photos

class TrueMerger {
    var audioUrl: URL
    let videoUrl: URL
    var reducedAudioUrl: URL?
    private var storage = RecordRealmDataSource()
    
    struct TrimError: Error {
        let description: String
        let underlyingError: Error?
        init(_ description: String, underlyingError: Error? = nil) {
            self.description = "TrimVideo: " + description
            self.underlyingError = underlyingError
        }
    }
    
    init(audio: String, video: URL) {
        audioUrl = DocsDirectory.path.appendingPathComponent(audio)!
        videoUrl = video
    }
    
    func audioTrackReduction(completion: @escaping () -> Void) -> URL? {
        var mergeAudioURL: URL?
        let composition = AVMutableComposition()
        let fileName = "merged\(arc4random_uniform(1000)).m4a"
        
        let docsURL = DocsDirectory.path
        audioUrl = docsURL.appendingPathComponent(audioUrl.lastPathComponent)!
        
        let assetAudio = AVURLAsset(url: audioUrl)
        let assetVideo = AVURLAsset(url: videoUrl)
        let trackAudio = assetAudio.tracks(withMediaType: AVMediaType.audio)[0]
        let trackVideo = assetVideo.tracks(withMediaType: AVMediaType.video)[0]
        
        let inputAudioDuration = Double(CMTimeGetSeconds(trackAudio.timeRange.duration))
        let inputVideoDuration = Double(CMTimeGetSeconds(trackVideo.timeRange.duration))
        
        if inputAudioDuration == inputVideoDuration {
            //сразуналожение
            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
            let timeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: trackAudio.timeRange.duration)
            try! compositionAudioTrack.insertTimeRange(timeRange, of: trackAudio, at: composition.duration)
        } else if inputAudioDuration > inputVideoDuration {
            //обрезать до времени видео
            do {
                let asset = try assetByTrimming(timeOffStart: inputVideoDuration, track: trackAudio)
                let trackAudioTrimmed = asset.tracks(withMediaType: AVMediaType.audio)[0]
                
                let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
                let timeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: trackAudioTrimmed.timeRange.duration)
                try! compositionAudioTrack.insertTimeRange(timeRange, of: trackAudioTrimmed, at: composition.duration)
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            //зациклить по вермени видео
            let timeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: trackAudio.timeRange.duration)
            for _ in 0..<Int((inputVideoDuration / inputAudioDuration).rounded(.down)) {
                let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
                try! compositionAudioTrack.insertTimeRange(timeRange, of: trackAudio, at: composition.duration)
            }
            let trimmedDuration = inputVideoDuration - Double(CMTimeGetSeconds(composition.duration))
            do {
                let asset = try assetByTrimming(timeOffStart: trimmedDuration, track: trackAudio)
                let trackAudioTrimmed = asset.tracks(withMediaType: AVMediaType.audio)[0]
                
                let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
                let timeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: trackAudioTrimmed.timeRange.duration)
                try! compositionAudioTrack.insertTimeRange(timeRange, of: trackAudioTrimmed, at: composition.duration)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        mergeAudioURL = docsURL.appendingPathComponent(fileName)! as URL
        //exportAudio(mergeAudioURL: mergeAudioURL!, composition: composition)
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileType.m4a
        assetExport?.outputURL = mergeAudioURL
        print("export start")
        assetExport?.exportAsynchronously(completionHandler:
            {
                switch assetExport!.status
                {
                case AVAssetExportSessionStatus.failed:
                    print("failed \(String(describing: assetExport?.error))")
                case AVAssetExportSessionStatus.cancelled:
                    print("cancelled \(String(describing: assetExport?.error))")
                case AVAssetExportSessionStatus.unknown:
                    print("unknown\(String(describing: assetExport?.error))")
                case AVAssetExportSessionStatus.waiting:
                    print("waiting\(String(describing: assetExport?.error))")
                case AVAssetExportSessionStatus.exporting:
                    print("exporting\(String(describing: assetExport?.error))")
                default:
                    print("-----Merge audio exportation complete.\(String(describing: mergeAudioURL))")
                    completion()
                }
        })
        //saveDataToToLocalStorage(url: url, fileName: fileName)
        return mergeAudioURL
    }
    
    //    func saveDataToToLocalStorage(url: URL, fileName: String) {
    //        do {
    //            let audioData = try Data(contentsOf: url)
    //            storage.insert(item: Record(audio: audioData,
    //                                        name: fileName,
    //                                        urlString: String(describing: url),
    //                                        duration: Double(CMTimeGetSeconds((AVURLAsset(url: url).duration)))))
    //        } catch {
    //            print(error.localizedDescription)
    //        }
    //    }
    
    func assetByTrimming(timeOffStart: Double, track: AVAssetTrack) throws -> AVAsset {
        let duration = CMTime(seconds: timeOffStart, preferredTimescale: 1)
        let timeRange = CMTimeRange(start: kCMTimeZero, duration: duration)
        let composition = AVMutableComposition()
        do {
            let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
            try compositionTrack?.insertTimeRange(timeRange, of: track, at: kCMTimeZero)
        } catch let error {
            throw error//TrimError("error during composition", underlyingError: error)
        }
        return composition
    }
    
    func mergeMutableVideoWithAudio(completion: @escaping () -> Void) -> URL? {
        //let myGroup = DispatchGroup()
        //myGroup.enter()
        let semaphore = DispatchSemaphore(value: 0)
        guard let url = audioTrackReduction(completion: {
            //myGroup.leave()
            semaphore.signal()
            print("dozhdalasya")
        }) else {
            return nil
        }
        
        semaphore.wait(timeout: DispatchTime.now() + .seconds(10))
        //myGroup.notify(queue: .main) {
        //    print("Finished all export.")
        //}
        //let docsRL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        //reducedAudioUrl = docsRL.appendingPathComponent("merged377.m4a")! as URL
        reducedAudioUrl = url
        
        var mergedAudioVideoUrl: URL?
        let mixComposition = AVMutableComposition()
        
        let aVideoAsset = AVURLAsset(url: videoUrl)
        let aAudioAsset = AVURLAsset(url: reducedAudioUrl!)
        
        let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try videoTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAsset.duration),
                                            of: aVideoAsset.tracks(withMediaType: AVMediaType.video)[0],
                                            at: kCMTimeZero)
        } catch _ {
            print("Failed to load Video track")
        }
        let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
        do {
            //падение
            try audioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAsset.duration),
                                            of: aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0] ,
                                            at: kCMTimeZero)
        } catch _ {
            print("Failed to load Audio track")
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, aVideoAsset.duration)
        
        // 2.2
        let firstInstruction = videoCompositionInstructionForTrack(track: videoTrack!, asset: aVideoAsset)
        firstInstruction.setOpacity(0.0, at: aVideoAsset.duration)
        
        // 2.3
        mainInstruction.layerInstructions = [firstInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        //
        let docsURL = DocsDirectory.path
        mergedAudioVideoUrl = docsURL.appendingPathComponent("video_\(arc4random_uniform(1000)).mov")! as URL
        //export
        guard let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return nil }
        assetExport.outputFileType = AVFileType.mov
        assetExport.outputURL = mergedAudioVideoUrl!
        assetExport.videoComposition = mainComposition//
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case AVAssetExportSessionStatus.completed:
                print("-----Merge mutable video with trimmed audio exportation complete.\(String(describing: mergedAudioVideoUrl))")
                PhotoLibraryManager.exportToPhotoLibraryAssetWith(url: mergedAudioVideoUrl!)
                Helper().removeFileAtURLIfExists(url: self.reducedAudioUrl!)
                completion()
            case  AVAssetExportSessionStatus.failed:
                print("failed \(String(describing: assetExport.error))")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("complete")
                print("\(String(describing: mergedAudioVideoUrl))")
            }
        }
        return mergedAudioVideoUrl
    }
    
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                     at: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat.pi)
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        return instruction
    }
}
