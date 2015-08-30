//
//  PMTicker.swift
//  Plunder Mountain
//
//  Created by Alicia Cicon on 8/29/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

protocol PMTickable
{
    func tick(interval:NSTimeInterval)
}

class PMTicker
{
    var previous:NSTimeInterval = 0
    var tickables:[PMTickable]
    
    init()
    {
        tickables = [PMTickable]()
    }
    
    func addTickable(tickable:PMTickable)
    {
        tickables.append(tickable)
    }
    
    func update(current:NSTimeInterval)
    {
        if (previous == 0)
        {
            previous = current
        }
        
        let delta = current - previous
        
        for tickable in tickables
        {
            tickable.tick(delta)
        }
    }
}