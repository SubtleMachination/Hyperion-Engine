//
//  PMScene.swift
//  Plunder Mountain
//
//  Created by Alicia Cicon on 8/29/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import SpriteKit

class PMScene : SKScene, PMTickable
{
    let ticker:PMTicker
    
    override init(size:CGSize)
    {
        ticker = PMTicker()
        
        super.init(size:size)
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // REQUIRED when subclassing SKScene. Never called because I instantiate scenes manually.
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder:NSCoder)
    {
        ticker = PMTicker()
        
        super.init(coder:aDecoder)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func addTickable(tickable:PMTickable)
    {
        ticker.addTickable(tickable)
    }
    
    override func update(currentTime:NSTimeInterval)
    {
        ticker.update(currentTime)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // TO OVERRIDE IN SUBCLASSES
    func setup()
    {
        
    }
    
    func tap(point:CGPoint)
    {
        
    }
    
    func tick(interval:NSTimeInterval)
    {
        
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
