//
//  ViewController.swift
//  KDCircularProgressExample
//
//  Created by Kaan Dedeoglu on 2/12/15.
//  Copyright (c) 2015 Kaan Dedeoglu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var progress: KDCircularProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.22, alpha: 1)
        
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.6
        progress.clockwise = true
        progress.gradientRotateSpeed = 0
        progress.roundedCorners = true
        progress.glowMode = .NoGlow
        progress.glowAmount = 0
        progress.repeatColors = false
        progress.updateColors([UIColor.yellowColor() , UIColor.redColor(), UIColor.blueColor()])
        progress.center = CGPoint(x: view.center.x, y: view.center.y + 25)
        view.addSubview(progress)
    }
    
    @IBAction func sliderDidChangeValue(sender: UISlider) {
        progress.angle = Int(sender.value)
    }
    
    @IBAction func animateButtonTapped(sender: UIButton) {
        progress.animateToAngle(360, animateDuration: 5) { completed in
            if completed {
                println("animation stopped, completed")
            } else {
                println("animation stopped, was interrupted")
            }
        }
    }
}

