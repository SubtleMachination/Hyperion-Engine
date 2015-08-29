//
//  Chunk.swift
//  Plunder Mountain
//
//  Created by Alicia Cicon on 8/24/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

// Chunks are 4x4x4

class Chunk
{
    var live:Bool
    var tiles:Array2D<Int>
    
    convenience init()
    {
        self.init(live:true)
    }
    
    init(live:Bool)
    {
        self.live = live
        
        if (live)
        {
            tiles = Array2D<Int>(x:4, y:4, filler:0)
        }
        else
        {
            tiles = Array2D<Int>(x:0, y:0, filler:0)
        }
    }
    
    func deepCopy() -> Chunk
    {
        let newChunk = Chunk(live:self.live)
        
        for x in 0..<4
        {
            for y in 0..<4
            {
                newChunk.tiles[x,y] = self.tiles[x,y]
            }
        }
        
        return newChunk
    }
}