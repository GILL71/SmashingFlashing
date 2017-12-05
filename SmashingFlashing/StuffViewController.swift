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
import MediaPlayer

private let reuseIdentifier = "Cell"

class StuffViewController: UICollectionViewController {

    var videos: PHFetchResult<PHAsset>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVideoFromCameraRoll()
        collectionView?.delegate = self
        collectionView?.dataSource = self
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
    
    //MARK: -UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("In selection")
        let asset = videos!.object(at: indexPath.row)
        guard (asset.mediaType == PHAssetMediaType.video)   else {
            print("Not a valid video media type")
            return
        }
        
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: /*[NSObject : AnyObject]?)*/ [AnyHashable: Any]?) in
            let asset = asset as! AVURLAsset
            print(asset.url) // Here is video URL
            let player = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            player.mediaUrl = asset.url
            self.present(player, animated: true, completion: nil)
        })
    }

}
