//
//  AlertManager.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 18.01.18.
//  Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AlertManager {
    
    weak var cutAlertOkAction: UIAlertAction?
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    func getCutterAlert(mediaUrl: URL) -> UIAlertController {
        let videoDuration = Double(CMTimeGetSeconds(AVAsset.init(url: mediaUrl).duration))
        let alertController = UIAlertController(title: "Input parameters", message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "From"
            NotificationCenter.default.addObserver(self, selector:
                #selector(self.handleTextFieldTextForTimeDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
        }
        alertController.addTextField { textField in
            textField.placeholder = "To"
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldTextForTimeDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.removeTextFieldTimeObserver(alertController: alertController)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            guard let start = Double(alertController.textFields![0].text!) else {return}
            guard let end = Double(alertController.textFields![1].text!) else {return}
            self.removeTextFieldTimeObserver(alertController: alertController)
            if start >= end || end >= videoDuration {
                //alert error
                //my expirement
                let alertError = UIAlertController(title: "Error", message: "Invalid input data", preferredStyle: .alert)
                let outAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    //
                })
                alertError.addAction(outAction)
                let controller = self.viewControllerForAlert()
                controller.present(alertError, animated: true, completion: nil)
            } else {
                let cutter = Cutter.init(start: start, end: end, url: mediaUrl)
                self.showActivityIndicator()
                cutter.cutVideo() {
                    self.hideActivityIndicator()
                }
            }
        }
        //NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldTextForTimeDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: alertController)
        
        cutAlertOkAction = okAction
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
//    func getMergerAlert() -> UIAlertController {
//        
//    }
    
    @objc func handleTextFieldTextForTimeDidChangeNotification(sender: NSNotification) {
//        let alert = sender.object as! UIAlertController
//        cutAlertOkAction!.isEnabled = (alert.textFields![0].text?.isNumeric)! && (alert.textFields![1].text?.isNumeric)!
        let textField = sender.object as! UITextField
        cutAlertOkAction!.isEnabled = (textField.text?.isNumeric)!
    }
    
    func removeTextFieldTimeObserver(alertController: UIAlertController) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alertController.textFields?[0])
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alertController.textFields?[1])
    }
    
    func viewControllerForAlert() -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = UIColor.clear
        let window = UIWindow.init(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindowLevelAlert + 1
        window.makeKeyAndVisible()
        window.rootViewController = controller
        return controller
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            let vc = self.viewControllerForAlert()
            
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = vc.view.center
            self.loadingView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1)
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.spinner)
            vc.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
            //удалить прозрачный контроллер и прозрачное окно?
        }
    }
}
