//
//  Cutter.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 18.01.18.
//  Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

class Cutter {
    let startTime: CMTime
    let endTime: CMTime
    let sourceURL: URL
    
    init(start: Double, end: Double, url: URL) {
        startTime = CMTime.init(seconds: start, preferredTimescale: 1)
        endTime = CMTime.init(seconds: end, preferredTimescale: 1)
        sourceURL = url
    }
    
    func cutVideo(completion: @escaping () -> Void) {
        let docsURL = DocsDirectory.path
        let destinationURL = docsURL.appendingPathComponent("video_\(arc4random_uniform(1000)).mov")! as URL
        
        let options = [
            AVURLAssetPreferPreciseDurationAndTimingKey: true
        ]
        
        let asset = AVURLAsset(url: sourceURL, options: options)
        let preferredPreset = AVAssetExportPresetPassthrough
        
        if  verifyPresetForAsset(preset: preferredPreset, asset: asset) {
            
            let composition = AVMutableComposition()
            let videoCompTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())
            let audioCompTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
            
            guard let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first else { return }
            guard let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: .audio).first else { return }
            
            var accumulatedTime = kCMTimeZero
            let durationOfCurrentSlice = CMTimeSubtract(endTime, startTime)
            let timeRangeForCurrentSlice = CMTimeRangeMake(startTime, durationOfCurrentSlice)
            
            do {
                try videoCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
                try audioCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
                accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
            }
            catch let compError {
                print("TrimVideo: error during composition: \(compError)")
            }
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset) else { return }
            
            exportSession.outputURL = destinationURL as URL
            exportSession.outputFileType = AVFileType.mov
            exportSession.shouldOptimizeForNetworkUse = true
            
            exportSession.exportAsynchronously { () -> Void in
                switch exportSession.status {
                case AVAssetExportSessionStatus.completed:
                    print("-----Cut video exportation complete.\(String(describing: destinationURL))")
                    PhotoLibraryManager.exportToPhotoLibraryAssetWith(url: destinationURL)
                    Helper().removeFileAtURLIfExists(url: destinationURL)
                    completion()
                case  AVAssetExportSessionStatus.failed:
                    print("failed \(String(describing: exportSession.error))")
                case AVAssetExportSessionStatus.cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                default:
                    print("complete")
                    print("\(String(describing: destinationURL))")
                }
            }
        }
        else {
            print("TrimVideo - Could not find a suitable export preset for the input video")
        }
    }
    
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
    }
}
