//
//  StuffViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 09.10.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

private let reuseIdentifier = "Cell"

class StuffViewController: UICollectionViewController, PHPhotoLibraryChangeObserver {
    
    var videos: PHFetchResult<PHAsset>?
    var urls = [URL]()
    var sentUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVideoFromCameraRoll()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    @IBAction func refreshCollectionAction(_ sender: Any) {
        getVideoFromCameraRoll()
    }
    
    func getVideoFromCameraRoll() {
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        videos = PHAsset.fetchAssets(with: options)
        collectionView?.reloadData()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let number = videos?.count {
            return number
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let asset = videos!.object(at: indexPath.row)
        let width: CGFloat = 150
        let height: CGFloat = 150
        let size = CGSize(width:width, height:height)
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.lightGray.cgColor
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFit, options: nil)
        {   (image, userInfo) -> Void in
            
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.image = image
            
            let labelView = cell.viewWithTag(2) as! UILabel
            labelView.text = String(format: "%02d:%02d",Int((asset.duration / 60)),Int(asset.duration) % 60)
        }
        return cell
    }
 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rowNum = indexPath.row
        DispatchQueue.global(qos: .userInitiated).async { // 1
            let downloadGroup = DispatchGroup()
            downloadGroup.enter() // 3
            let asset = self.videos!.object(at: rowNum)
            guard (asset.mediaType == PHAssetMediaType.video) else {
                print("Not a valid video media type")
                return
            }
            PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
                let asset = asset as! AVURLAsset
                self.sentUrl = asset.url
                downloadGroup.leave() //4
            })
            downloadGroup.wait() // 5
            DispatchQueue.main.async { // 6
                self.performSegue(withIdentifier: "player_segue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let url = self.sentUrl else {
            print("no url in prepare for segue")
            return
        }
        if let playerVC = segue.destination as? PlayerViewController {
            playerVC.mediaUrl = url
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: videos!) {
                videos = changeDetails.fetchResultAfterChanges
                collectionView?.reloadData()
            }
        }
    }

}
