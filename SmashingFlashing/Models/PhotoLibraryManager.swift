//
//  PhotoLibraryManager.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 07.01.18.
//  Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import Foundation
import Photos

class PhotoLibraryManager {
    static func exportToPhotoLibraryAssetWith(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (saved, error) in
            if saved {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                    Helper().removeFileAtURLIfExists(url: url)
                })
            }
        }
    }
}
