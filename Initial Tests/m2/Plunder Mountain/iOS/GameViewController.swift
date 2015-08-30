//
//  GameViewController.swift
//  Plunder Mountain iOS
//
//  Created by Alicia Cicon on 8/28/15.
//  Copyright (c) 2015 Runemark. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = PMView(superview:self.view)
        
        let scene = PMGameScene(size:self.view.bounds.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        
        let skview = self.view as! SKView
        skview.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
