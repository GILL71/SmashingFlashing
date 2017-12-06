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

class StuffViewController: UICollectionViewController {

    var videos: PHFetchResult<PHAsset>?
    var urls = [URL]()
    
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
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let playerVC = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
//        let asset = videos!.object(at: indexPath.row)
//        playerVC.asset = asset
//        guard (asset.mediaType == PHAssetMediaType.video)   else {
//            print("Not a valid video media type")
//            return
//        }
//        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
//            let asset = asset as! AVURLAsset
//            print(asset.url) // Here is video URL
//            playerVC.mediaUrl = asset.url
//            self.performSegue(withIdentifier: "player_segue", sender: nil)
//        })
//    }
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//          //self.performSegue(withIdentifier: "player_segue", sender: collectionView.cellForItem(at: indexPath))
//            let playerVC = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
//            let asset = videos!.object(at: indexPath.row)
//            playerVC.asset = asset
//            guard (asset.mediaType == PHAssetMediaType.video)   else {
//                print("Not a valid video media type")
//                return
//            }
//            let resultHandler = {[weak self](asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
//                DispatchQueue.main.async {
//                    let asset = asset as! AVURLAsset
//                    print("closure")
//                    print(asset.url)
//                    print("closure")
//                    playerVC.mediaUrl = asset.url
//                    self?.present(playerVC, animated: true, completion: nil)
//                }
//            }
//            PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: resultHandler)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue")
        if segue.identifier == "player_segue" {
            if let playerVC = segue.destination as? PlayerViewController {
                let asset = videos!.object(at: (self.collectionView?.indexPath(for: sender as! UICollectionViewCell)?.row)!)
                playerVC.asset = asset
                guard (asset.mediaType == PHAssetMediaType.video)   else {
                    print("Not a valid video media type")
                    return
                }
//                let resultHandler = {[weak playerVC] (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
//                    DispatchQueue.main.async {
//                        let asset = asset as! AVURLAsset
//                        print("closure")
//                        print(asset.url)
//                        print("closure")
//                        playerVC?.mediaUrl = asset.url
//                    }
//                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let downloadGroup = DispatchGroup()
                    downloadGroup.enter() // 3
                    PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
                            let asset = asset as! AVURLAsset
                            print("closure")
                            print(asset.url)
                            print("closure")
                            playerVC.mediaUrl = asset.url
                            downloadGroup.leave() //4
                    })
                    
                    downloadGroup.wait() // 5
                    DispatchQueue.main.async { // 6
                        
                    }
                }
//                PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: resultHandler)
            }
        }
    }

}
