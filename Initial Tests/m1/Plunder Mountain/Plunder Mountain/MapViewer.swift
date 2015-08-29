//
//  Map.swift
//  Plunder Mountain
//
//  Created by Alicia Cicon on 8/24/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

class MapViewer
{
    let xChunkSize = 4
    let yChunkSize = 4
    
    var xChunkStart:Int
    var yChunkStart:Int
    var xChunks:Int
    var yChunks:Int
    var grid:ChunkArray2D
    
    init(xChunkStart:Int, yChunkStart:Int, xChunks:Int, yChunks:Int)
    {
        self.xChunkStart = xChunkStart
        self.yChunkStart = yChunkStart
        self.xChunks = xChunks
        self.yChunks = yChunks
        grid = ChunkArray2D(x:xChunks, y:yChunks)
        
        reloadChunks()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Depth and Position
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func chunkDepth(chunk_x:Int, chunk_y:Int) -> Int
    {
        let relativeChunk_x = chunk_x - xChunkStart
        let relativeChunk_y = chunk_y - yChunkStart
        
        return relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y)
    }
    
    func relativeChunkDepth(relativeChunk_x:Int, relativeChunk_y:Int) -> Int
    {
        return relativeChunk_y*xChunks + relativeChunk_x
    }
    
    func tilePosInChunk(chunk_x:Int, chunk_y:Int, tile_x:Int, tile_y:Int) -> DiscretePosition
    {
        return DiscretePosition(x:4*chunk_x + tile_x, y:4*chunk_y + tile_y)
    }
    
    func tileDepth(tile_x:Int, tile_y:Int) -> Int
    {
        return tile_y*yChunkSize + tile_x
    }
    
    func screenPosForChunk(chunk_x:Int, chunk_y:Int, cameraPosition:Coord, tileWidth:CGFloat, tileHeight:CGFloat) -> CGPoint
    {
        let chunkCenter = tilePosInChunk(chunk_x, chunk_y:chunk_y, tile_x:Int(xChunkSize/2), tile_y:Int(yChunkSize))
        let chunkPosition = screenPosForTilePos(Coord(x:Double(chunkCenter.x), y:Double(chunkCenter.y), z:0), cameraPos:cameraPosition, tileWidth:tileWidth, tileHeight:tileHeight)
        return chunkPosition.toPoint()
    }
    
    func screenPosForRelativeChunk(relativeChunk_x:Int, relativeChunk_y:Int, cameraPosition:Coord, tileWidth:CGFloat, tileHeight:CGFloat) -> CGPoint
    {
        let absolute_x = relativeChunk_x + xChunkStart
        let absolute_y = relativeChunk_y + yChunkStart
        
        return screenPosForChunk(absolute_x, chunk_y:absolute_y, cameraPosition:cameraPosition, tileWidth:tileWidth, tileHeight:tileHeight)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Grid Shifting
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func xShiftBy(offset:Int)
    {
        if (offset == 0)
        {
            // Do nothing (no push needed)
        }
        else if (offset > 0)
        {
            // Unload chunks at x = 0 (relative)
            for relativeChunk_y in 0..<yChunks
            {
                unloadRelativeChunk(0, relativeChunk_y:relativeChunk_y)
            }
            
            // Shift all chunks down on the x axis
            for relativeChunk_x in 0..<xChunks-1
            {
                for relativeChunk_y in 0..<yChunks
                {
                    let nextChunkData = getRelativeChunk(relativeChunk_x+1, relativeChunk_y:relativeChunk_y)!.deepCopy()
                    assignRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, chunkData:nextChunkData)
                }
            }
            
            // Load chunks at x = last (relative)
            for relativeChunk_y in 0..<yChunks
            {
                loadRelativeChunk(xChunks-1, relativeChunk_y:relativeChunk_y)
            }
        }
        else if (offset < 0)
        {
            // Unload chunks at x = last (relative)
            for relativeChunk_y in 0..<yChunks
            {
                unloadRelativeChunk(xChunks-1, relativeChunk_y:relativeChunk_y)
            }
            
            // Shift all chunks up on the x axis
            for relativeChunk_x in (1..<xChunks).reverse()
            {
                for relativeChunk_y in 0..<yChunks
                {
                    let nextChunkData = getRelativeChunk(relativeChunk_x-1, relativeChunk_y:relativeChunk_y)!.deepCopy()
                    assignRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, chunkData:nextChunkData)
                }
            }
            
            // Load chunks at y = 0
            for relativeChunk_y in 0..<yChunks
            {
                loadRelativeChunk(0, relativeChunk_y:relativeChunk_y)
            }
        }
    }
    
    func yShiftBy(offset:Int)
    {
        if (offset == 0)
        {
            // Do nothing (no push needed)
        }
        else if (offset > 0)
        {
            for _ in 0..<offset
            {
                // Unload chunks at y = 0 (relative)
                for relativeChunk_x in 0..<xChunks
                {
                    unloadRelativeChunk(relativeChunk_x, relativeChunk_y:0)
                }
                
                // Shift all chunks down on the y axis
                for relativeChunk_y in 0..<yChunks-1
                {
                    for relativeChunk_x in 0..<xChunks
                    {
                        let nextChunkUp = getRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y+1)!.deepCopy()
                        assignRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, chunkData:nextChunkUp)
                    }
                }
                
                // Load chunks at y = last (relative)
                for relativeChunk_x in 0..<xChunks
                {
                    loadRelativeChunk(relativeChunk_x, relativeChunk_y:yChunks-1)
                }
            }
        }
        else if (offset < 0)
        {
            for _ in 0..<(-1*offset)
            {
                // Unload chunks at y = last (relative)
                for relativeChunk_x in 0..<xChunks
                {
                    unloadRelativeChunk(relativeChunk_x, relativeChunk_y:yChunks-1)
                }
                
                // Shift all chunks up on the y axis
                for relativeChunk_y in (1..<yChunks).reverse()
                {
                    for relativeChunk_x in 0..<xChunks
                    {
                        let nextChunkUp = getRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y-1)!.deepCopy()
                        assignRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, chunkData:nextChunkUp)
                    }
                }
                
                // Load chunks at y = 0
                for relativeChunk_x in 0..<xChunks
                {
                    loadRelativeChunk(relativeChunk_x, relativeChunk_y:0)
                }
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Load / Unload
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func reloadChunks()
    {
        for chunk_x in xChunkStart..<xChunkStart+xChunks
        {
            for chunk_y in yChunkStart..<yChunkStart+yChunks
            {
                loadChunk(chunk_x, chunk_y:chunk_y)
            }
        }
    }
    
    func unloadChunks()
    {
        for chunk_x in xChunkStart..<xChunkStart+xChunks
        {
            for chunk_y in yChunkStart..<yChunkStart+yChunks
            {
                unloadChunk(chunk_x, chunk_y:chunk_y)
            }
        }
    }
    
    // Can only load chunks into existing slots
    func loadChunk(chunk_x:Int, chunk_y:Int)
    {
        if (withinBounds(chunk_x, chunk_y:chunk_y))
        {
            // Randomly fill the chunk (for now, we don't actually read chunks in from disk)
            for tile_x in 0..<xChunkSize
            {
                for tile_y in 0..<yChunkSize
                {
                    if (coinFlip())
                    {
                        getChunk(chunk_x, chunk_y:chunk_y)!.tiles[tile_x,tile_y] = 1
                    }
                }
            }
        }
    }
    
    func loadRelativeChunk(relativeChunk_x:Int, relativeChunk_y:Int)
    {
        if (withinRelativeBounds(relativeChunk_x, relativeChunk_y:relativeChunk_y))
        {
            
            let chunkData = getRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y)!
            // STEP 1: Wipe chunk of previous data
            for tile_x in 0..<xChunkSize
            {
                for tile_y in 0..<yChunkSize
                {
                    chunkData.tiles[tile_x,tile_y] = 0
                }
            }
            
            // STEP 2: Randomly fill the chunk (for now, we don't actually read chunks in from disk)
            for tile_x in 0..<xChunkSize
            {
                for tile_y in 0..<yChunkSize
                {
                    if (coinFlip())
                    {
                        chunkData.tiles[tile_x,tile_y] = 1
                    }
                }
            }
        }
    }
    
    // Can only unload chunks which already exist
    func unloadChunk(chunk_x:Int, chunk_y:Int)
    {
        if (withinBounds(chunk_x, chunk_y:chunk_y))
        {
            // Do nothing until we're actually saving files out
        }
    }
    
    func unloadRelativeChunk(relativeChunk_x:Int, relativeChunk_y:Int)
    {
        if (withinRelativeBounds(relativeChunk_x, relativeChunk_y:relativeChunk_y))
        {
            // Do nothing until we're actually saving files out
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Grid Access
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func getChunk(chunk_x:Int, chunk_y:Int) -> Chunk?
    {
        let relativeChunk_x = chunk_x - xChunkStart
        let relativeChunk_y = chunk_y - yChunkStart
        
        return getRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y)
    }
    
    func getRelativeChunk(relativeChunk_x:Int, relativeChunk_y:Int) -> Chunk?
    {
        var chunk:Chunk?
        
        if (withinRelativeBounds(relativeChunk_x, relativeChunk_y:relativeChunk_y))
        {
            chunk = grid[relativeChunk_x, relativeChunk_y]
        }
        
        return chunk
    }
    
    func assignChunk(chunk_x:Int, chunk_y:Int, chunkData:Chunk)
    {
        let relativeChunk_x = chunk_x - xChunkStart
        let relativeChunk_y = chunk_y - yChunkStart
        
        assignRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, chunkData:chunkData)
    }
    
    func assignRelativeChunk(relativeChunk_x:Int, relativeChunk_y:Int, chunkData:Chunk)
    {
        if (withinRelativeBounds(relativeChunk_x, relativeChunk_y:relativeChunk_y))
        {
            grid[relativeChunk_x, relativeChunk_y] = chunkData
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Verification
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func withinBounds(chunk_x:Int, chunk_y:Int) -> Bool
    {
        let relativeChunk_x = chunk_x - xChunkStart
        let relativeChunk_y = chunk_y - yChunkStart
        
        return withinRelativeBounds(relativeChunk_x, relativeChunk_y:relativeChunk_y)
    }
    
    func withinRelativeBounds(relativeChunk_x:Int, relativeChunk_y:Int) -> Bool
    {
        return (relativeChunk_x >= 0 && relativeChunk_x < grid.xMax && relativeChunk_y >= 0 && relativeChunk_y < grid.yMax)
    }
}