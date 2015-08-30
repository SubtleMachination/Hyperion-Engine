//
//  PMView.swift
//  Plunder Mountain
//
//  Created by Alicia Cicon on 8/29/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import SpriteKit

class PMView : SKView
{
    init(superview:UIView)
    {
        super.init(frame:superview.bounds)
        self.setupProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupProperties()
    {
        self.showsFPS = true
        self.showsNodeCount = true
        self.showsDrawCount = true
        self.ignoresSiblingOrder = true
        self.asynchronous = true
        self.opaque = true
    }
}