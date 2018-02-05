//
//  LoadViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 17.01.18.
//  Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {

    @IBOutlet weak var transitionView: UIImageView!
    @IBOutlet weak var rotatingView: UIImageView!
    
    let width = 180
    let heightMain = 140
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotatingView.layer.anchorPoint = CGPoint(x: 0.1, y: 0.5)
        
        transitionView.frame = CGRect(x: 0, y: 0, width: width, height: heightMain)
        transitionView.center = self.view.center
        
        rotatingView.frame = CGRect(x: 0, y: 0, width: width, height: heightMain / 7)
        rotatingView.center = CGPoint(x: self.view.center.x - CGFloat(width/2 - 18),y: transitionView.center.y + rotatingView.frame.height / 2 - transitionView.frame.height / 2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rightRotation()
    }
    
    func rightRotation() {
        UIView.animate(withDuration: 1, animations: {
            self.rotatingView.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi / 4)
        }) { yes in
            if yes {
                self.leftRotation()
            }
        }
    }
    
    func leftRotation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.rotatingView.transform = CGAffineTransform.init(rotationAngle: 0)
        }) { yes in
            if yes {
                self.leftOutTransform()
            }
        }
    }
    
    func leftOutTransform() {
        UIView.animate(withDuration: 0.4, animations: {
            self.rotatingView.transform = CGAffineTransform.init(translationX: -300, y: self.rotatingView.layer.bounds.minY)
            self.transitionView.transform = CGAffineTransform.init(translationX: -300, y: self.transitionView.layer.bounds.minY)
        }) { yes in
            if yes {
                self.performSegue(withIdentifier: "startVc", sender: self)
            }
        }
    }
}
