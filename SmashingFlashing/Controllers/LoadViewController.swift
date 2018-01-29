//
//  LoadViewController.swift
//  SmashingFlashing
//
//  Created by Михаил Нечаев on 17.01.18.
//  Copyright © 2018 Михаил Нечаев. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {

    @IBOutlet weak var startImage: UIImageView!
    @IBOutlet weak var rotateImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //startImage.image = UIImage(contentsOfFile: "start.png")
        //rotateImage.image = UIImage(contentsOfFile: "chelk.png")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    func startAnimation() {
        setAnchorPoint(anchorPoint: CGPoint(x: 0.0,y: 1.0), view: rotateImage)
        //rotateImage.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        //rotateImage.layer.position = CGPoint(x: 150.0, y: 300.0)
        UIView.animate(withDuration: 4.5) {
            self.rotateImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            //self.rotateImage.transform = CGAffineTransform(
        }
        delay(10.00) {
            self.changeRootViewController()
        }
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, view: UIView) {
        var newPoint = CGPoint(x:view.bounds.size.width * anchorPoint.x, y:view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x:view.bounds.size.width * view.layer.anchorPoint.x, y:view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position : CGPoint = view.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        view.layer.position = position;
        view.layer.anchorPoint = anchorPoint;
    }
    
    func changeRootViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav =  storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        self.present(nav, animated: true, completion: nil)
    }
    
    public func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
