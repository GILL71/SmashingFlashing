//
//  ClownViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 04.11.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import UIKit
import AVFoundation

class ClownViewController: UIViewController {
//здесь надо написать кастомный записыватель видео, без использования стандартных средств чего-то там сервиса мобайл
    @IBOutlet var previewView: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        captureSession = AVCaptureSession()
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession?.addInput(input)
        } catch {
            print(error)
        }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
    }
}
