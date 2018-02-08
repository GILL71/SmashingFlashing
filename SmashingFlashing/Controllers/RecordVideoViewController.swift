//
//  RecordVideoViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 09.01.18.
//  Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class RecordVideoViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cameraButtonAction(_ sender: UIButton) {
        startCameraFromViewController(viewController: self, withDelegate: self)
    }
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [(kUTTypeMovie as NSString) as String]
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        
        present(cameraController, animated: true, completion: nil)
        return true
    }

    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        var title = "Success"
        var message = "Video is saved"
        if let _ = error {
            title = "Error"
            message = "Video failed to save"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - UIImagePickerControllerDelegate
extension RecordVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String else { return }
        picker.dismiss(animated: true)
        
        if mediaType == UIImagePickerController.availableMediaTypes(for: picker.sourceType)?.last {
            guard let path = (info[UIImagePickerControllerMediaURL] as? URL)?.path else { return }
            
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path,
                                                    self,
                                                    #selector(video(_:didFinishSavingWithError:contextInfo:)),
                                                    nil)
            }
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension RecordVideoViewController: UINavigationControllerDelegate {
}

