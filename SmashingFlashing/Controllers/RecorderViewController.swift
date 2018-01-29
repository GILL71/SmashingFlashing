//
//  RecorderViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 30.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class RecorderViewController: UIViewController {
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var timer: UILabel!
    var myTimer: Timer?
    
    var recorder = Recorder()
    let fileName = FileName()
    var recordFlag = false
    var resume = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    @IBAction func saveRecord(_ sender: UIBarButtonItem) {
        if recorder.audioRecorder == nil {
            print("Nothing to save")
        } else {
            
            let actionSheetController = UIAlertController(title: "",
                                                          message: "Input file name:",
                                                          preferredStyle: .alert)
            
            actionSheetController.addTextField(configurationHandler: self.configurationTextField)
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { action -> Void in
                var name = actionSheetController.textFields?[0].text
                switch self.fileName.checkNewFile(name: &name) {
                case .finish:
                    self.recorder.finishRecording(success: true, name: name!)
                case .cancel:
                    self.recorder.cancelRecording()
                case .symbolValidation:
                    let alert = UIAlertController(title: "Error: please enter name using latin characters!",
                                                  message: "Filename contains invalid characters",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            actionSheetController.addAction(saveAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                self.recorder.cancelRecording()
            }
            actionSheetController.addAction(cancelAction)
            
            self.present(actionSheetController, animated: true, completion: nil)
            
            resume = false
        }
    }
    
    @IBAction func click_AudioRecord(_ sender: UIButton) {
        if recordFlag {
            startStopButton.setImage(UIImage(named: "Record"), for: .normal)
            recordFlag = false
            recorder.pause()
        } else {
            recordFlag = true
            startStopButton.setImage(UIImage(named: "Pause"), for: .normal)
            recorder.recordOr(resume)
            resume = true
        }
    }
    
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "File name"
    }
    
    @objc func setProgress() {
        guard let currentRecorder = recorder.audioRecorder else {
            return
        }
        let time = String(format: "%0.0f sec", currentRecorder.currentTime)
        timer.text = time
    }
}

