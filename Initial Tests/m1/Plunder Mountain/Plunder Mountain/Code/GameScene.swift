//
//  GameScene.swift
//  Plunder Mountain
//
//  Created by Alicia Cicon on 8/24/15.
//  Copyright (c) 2015 Runemark. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EXTENSION SUPPORT GUIDE:
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ASSUMED ANGLE: anywhere where the camera's angle is assumed to be facing the SOUTHEAST. Marks code that will need to be altered when multiple angles are supported
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import SpriteKit

class GameScene: SKScene
{
    var window:CGSize = CGSize(width:0, height:0)
    var center:CGPoint = CGPoint(x:0, y:0)
    var corners = (topleft:CGPointZero, topright:CGPointZero, bottomleft:CGPointZero, bottomright:CGPointZero)
    
    var mapViewer:MapViewer?
    
    var cameraPosition = Coord(x:0, y:0, z:0)
    var cameraVelocity = CGPointZero
    var tileWidth = CGFloat(0.0)
    var tileHeight = CGFloat(0.0)
    
    var pretendTileWidth = CGFloat(0.0)
    var pretendTileHeight = CGFloat(0.0)
    
    var background:SKSpriteNode?
    var mapNode = SKSpriteNode()
    
    var tileAtlas = SKTextureAtlas(named:"Tiles")
    
    override func didMoveToView(view: SKView)
    {
        self.size = view.bounds.size
        
        window = UIScreen.mainScreen().bounds.size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        corners = (topleft:CGPoint(x:0.0, y:window.height), topright:CGPoint(x:window.width, y:window.height), bottomleft:CGPoint(x:0.0, y:0.0), bottomright:CGPoint(x:window.width, y:0.0))
        
        // Background Layer
        background = SKSpriteNode(imageNamed:"background.png")
        background?.resizeNode(window.width, y:window.height)
        background?.position = center
        self.addChild(background!)
        
        // Map Time
        mapNode.position = CGPointZero + CGPointMake(0.0, window.height*0.075)
        self.addChild(mapNode)
        
        tileWidth = CGFloat(70.0)
        tileHeight = CGFloat(70.0)
        
        pretendTileWidth = 70.0
        pretendTileHeight = 70.0
        
        // MAP DATA requires some info: {MAX_TILEPOS (x,y), CAMERA_POS (x,y), }
        
        cameraPosition = Coord(x:0, y:0, z:0)
        
        let chunkBounds = chunkBoundaries()
        
        let x_chunkCount = chunkBounds.end.x - chunkBounds.start.x + 1
        let y_chunkCount = chunkBounds.end.y - chunkBounds.start.y + 1
        
        mapViewer = MapViewer(xChunkStart:chunkBounds.start.x, yChunkStart:chunkBounds.start.y, xChunks:x_chunkCount, yChunks:y_chunkCount)
        
        redrawGrid()
        
        // Gloom
        let effectsNode = SKSpriteNode()
        effectsNode.position = CGPointZero
        effectsNode.zPosition = 1000
        self.addChild(effectsNode)
        
        let fogofwar = SKSpriteNode(imageNamed:"gradientoverlay.png")
        fogofwar.resizeNode(window.width, y:window.height)
        fogofwar.position = center
        fogofwar.color = UIColor.blackColor()
        fogofwar.colorBlendFactor = 1.0
        fogofwar.alpha = 0.95
        effectsNode.addChild(fogofwar)
    }
    
    func chunkBoundaries() -> (start:DiscretePosition, end:DiscretePosition)
    {
        // ASSUMED ANGLE
        // First, determine the TILE position of the corners
        let northCorner = tilePosForScreenPos(corners.bottomleft, center:center, cameraPos:cameraPosition, tileWidth:tileWidth, tileHeight:tileHeight)
        let eastCorner = tilePosForScreenPos(corners.topleft, center:center, cameraPos:cameraPosition, tileWidth:tileWidth, tileHeight:tileHeight)
        let southCorner = tilePosForScreenPos(corners.topright, center:center, cameraPos:cameraPosition, tileWidth:tileWidth, tileHeight:tileHeight)
        let westCorner = tilePosForScreenPos(corners.bottomright, center:center, cameraPos:cameraPosition, tileWidth:tileWidth, tileHeight:tileHeight)
        
        let northEdge = Int(ceil(northCorner.y))
        let eastEdge = Int(floor(eastCorner.x))
        let southEdge = Int(floor(southCorner.y))
        let westEdge = Int(ceil(westCorner.x))
        
        let startChunk = chunkForTile(DiscretePosition(x:eastEdge, y:southEdge))
        let endChunk = chunkForTile(DiscretePosition(x:westEdge, y:northEdge))
        
        return (start:startChunk, end:endChunk)
    }
    
    func checkEdges()
    {
        // We go off of the START chunk (no others)
        let chunkBounds = chunkBoundaries()
        // How does it compare to the current corners in the mapViewer?
        let newStartChunk = chunkBounds.start
        let oldStartChunk = DiscretePosition(x:mapViewer!.xChunkStart, y:mapViewer!.yChunkStart)
        
        if (newStartChunk != oldStartChunk)
        {
            // Calculate the chunk difference
            let x_chunkDelta = newStartChunk.x - oldStartChunk.x
            let y_chunkDelta = newStartChunk.y - oldStartChunk.y
            
//            print("DIFF: \(x_chunkDelta), \(y_chunkDelta)")
            
            // if the chunkDeltas exceed the number of chunks, we just unload and reload the entire viewer with the new position
            
            // STEP 1: SET THE NEW CHUNK START
            mapViewer!.xChunkStart = newStartChunk.x
            mapViewer!.yChunkStart = newStartChunk.y
            
            // STEP 2: PUSH or RELOAD?
            if (x_chunkDelta >= mapViewer!.xChunks || y_chunkDelta >= mapViewer!.yChunks)
            {
                // COMPLETE REFRESH REQUIRED
                mapViewer!.unloadChunks()
                mapViewer!.reloadChunks()
            }
            else
            {
                // PUSH REQUIRED: Which direction, and how many?
                mapViewer!.xShiftBy(x_chunkDelta)
                mapViewer!.yShiftBy(y_chunkDelta)
                
                redrawGrid()
                
//                yShiftBy(y_chunkDelta)
//                adjustDepths()
//                xShiftBy(x_chunkDelta)
//                adjustDepths()
                
            }
        }
    }
    
    func adjustDepths()
    {
        for (childIndex, chunk) in (mapNode.children).enumerate()
        {
            chunk.zPosition = CGFloat(childIndex)
        }
    }
    
    func xShiftBy(offset:Int)
    {
        if (offset == 0)
        {
            // Do nothing
        }
        else if (offset > 0)
        {
            for _ in 0..<offset
            {
                // STEP 1: Remove chunk nodes at x = 0 (relative)
                var chunksToRemove = [SKNode]()
                for relativeChunk_y in 0..<mapViewer!.yChunks
                {
                    let relativeChunk_x = 0
                    let chunkIndexToRemove = mapViewer!.relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y)
                    let chunkToRemove = mapNode.children[chunkIndexToRemove]
                    chunksToRemove.append(chunkToRemove)
                }
                mapNode.removeChildrenInArray(chunksToRemove)
                
                // STEP 2: Add chunk nodes at x = last (relative)
                for relativeChunk_y in 0..<mapViewer!.yChunks
                {
                    let relativeChunk_x = mapViewer!.xChunks-1
                    
                    let chunkData = mapViewer!.getRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y)!
                    let chunkNode = redrawChunkFromData(chunkData, tWidth:pretendTileHeight, tHeight:pretendTileHeight)
                    chunkNode.position = mapViewer!.screenPosForRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, cameraPosition:cameraPosition, tileWidth:pretendTileWidth, tileHeight:pretendTileHeight) + center
                    chunkNode.zPosition = CGFloat(mapViewer!.relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y))
                    let insertionIndex = mapViewer!.xChunks-1 + (mapViewer!.xChunks)*relativeChunk_y
                    mapNode.insertChild(chunkNode, atIndex:insertionIndex)
                }
            }
        }
        else if (offset < 0)
        {
            for _ in 0..<(-1*offset)
            {
                // STEP 1: Remove chunk nodes at y = last (relative)
                var chunksToRemove = [SKNode]()
                for relativeChunk_y in (0..<mapViewer!.yChunks).reverse()
                {
                    let relativeChunk_x = mapViewer!.xChunks-1
                    let chunkIndexToRemove = mapViewer!.relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y)
                    let chunkToRemove = mapNode.children[chunkIndexToRemove]
                    chunksToRemove.append(chunkToRemove)
                }
                mapNode.removeChildrenInArray(chunksToRemove)
                
                // STEP 2: Add chunk nodes at y = 0 (relative)
                for relativeChunk_y in 0..<mapViewer!.yChunks
                {
                    let relativeChunk_x = 0
                    
                    let chunkData = mapViewer!.getRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y)!
                    let chunkNode = redrawChunkFromData(chunkData, tWidth:pretendTileHeight, tHeight:pretendTileHeight)
                    chunkNode.position = mapViewer!.screenPosForRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, cameraPosition:cameraPosition, tileWidth:pretendTileWidth, tileHeight:pretendTileHeight) + center
                    chunkNode.zPosition = CGFloat(mapViewer!.relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y))
                    let insertionIndex = (mapViewer!.xChunks)*relativeChunk_y
                    mapNode.insertChild(chunkNode, atIndex:insertionIndex)

                }
            }
        }
    }
    
    func yShiftBy(offset:Int)
    {
        if (offset == 0)
        {
            // Do nothing
        }
        else if (offset > 0)
        {
            for _ in 0..<offset
            {
                // STEP 1: Remove chunk nodes at y = 0 (relative)
                var chunksToRemove = [SKNode]()
                for relativeChunk_x in 0..<mapViewer!.xChunks
                {
                    let relativeChunk_y = 0
                    let chunkIndexToRemove = mapViewer!.relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y)
                    let chunkToRemove = mapNode.children[chunkIndexToRemove]
                    chunksToRemove.append(chunkToRemove)
                }
                mapNode.removeChildrenInArray(chunksToRemove)
                
                // STEP 2: Add chunk nodes at y = last (relative)
                for relativeChunk_x in 0..<mapViewer!.xChunks
                {
                    let relativeChunk_y = mapViewer!.yChunks-1
                    
                    let chunkData = mapViewer!.getRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y)!
                    let chunkNode = redrawChunkFromData(chunkData, tWidth:pretendTileWidth, tHeight:pretendTileHeight)
                    
                    chunkNode.position = mapViewer!.screenPosForRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, cameraPosition:cameraPosition, tileWidth:pretendTileWidth, tileHeight:pretendTileHeight) + center
                    chunkNode.zPosition = CGFloat(mapViewer!.relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y))
                    mapNode.addChild(chunkNode)
                }
            }
        }
        else if (offset < 0)
        {
            for _ in 0..<(-1*offset)
            {
                // STEP 1: Remove chunk nodes at y = last (relative)
                var chunksToRemove = [SKNode]()
                for relativeChunk_x in (0..<mapViewer!.xChunks).reverse()
                {
                    let relativeChunk_y = mapViewer!.yChunks-1
                    let chunkIndexToRemove = mapViewer!.relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y)
                    let chunkToRemove = mapNode.children[chunkIndexToRemove]
                    chunksToRemove.append(chunkToRemove)
                }
                mapNode.removeChildrenInArray(chunksToRemove)
                
                // STEP 2: Add chunk nodes at y = 0 (relative)
                for relativeChunk_x in 0..<mapViewer!.xChunks
                {
                    let relativeChunk_y = 0
                    
                    let chunkData = mapViewer!.getRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y)!
                    let chunkNode = redrawChunkFromData(chunkData, tWidth:pretendTileWidth, tHeight:pretendTileHeight)
                    
                    chunkNode.position = mapViewer!.screenPosForRelativeChunk(relativeChunk_x, relativeChunk_y:relativeChunk_y, cameraPosition:cameraPosition, tileWidth:tileWidth, tileHeight:tileHeight)
                    chunkNode.zPosition = CGFloat(mapViewer!.relativeChunkDepth(relativeChunk_x, relativeChunk_y:relativeChunk_y))
                    mapNode.addChild(chunkNode)
                }
            }
        }
    }
    
    func redrawChunkFromData(chunkData:Chunk, tWidth:CGFloat, tHeight:CGFloat) -> SKNode
    {
        let chunkNode = SKNode()
        
        if (chunkData.live)
        {
            for tile_y in 0..<4
            {
                for tile_x in 0..<4
                {
                    if (chunkData.tiles[tile_x, tile_y] > 0)
                    {
                        let tileSprite = SKSpriteNode(texture:tileAtlas.textureNamed("tile0"))
                        tileSprite.resizeNode(tWidth, y:tHeight)
                        let positionInChunk = screenPosForRelativeChunkTilePos(Coord(x:Double(tile_x), y:Double(tile_y), z:0.0), tileWidth:tWidth, tileHeight:tHeight)
                        tileSprite.position = positionInChunk.toPoint()
                        
                        chunkNode.addChild(tileSprite)
                    }
                }
            }
        }
        
        return chunkNode
    }
    
    func redrawGrid()
    {
        mapNode.position = CGPointMake(0.0, 0.0)
        
        mapNode.removeAllChildren()
        
        let x_chunkStart = mapViewer!.xChunkStart
        let y_chunkStart = mapViewer!.yChunkStart
        let x_chunkEnd = x_chunkStart + mapViewer!.xChunks
        let y_chunkEnd = y_chunkStart + mapViewer!.yChunks
        
        for chunk_y in y_chunkStart..<y_chunkEnd
        {
            for chunk_x in x_chunkStart..<x_chunkEnd
            {
                let chunkData = mapViewer!.getChunk(chunk_x, chunk_y:chunk_y)!
                
                // Add a new chunk node
                let chunkNode = redrawChunkFromData(chunkData, tWidth:pretendTileWidth, tHeight:pretendTileHeight)
                chunkNode.position = mapViewer!.screenPosForChunk(chunk_x, chunk_y:chunk_y, cameraPosition:cameraPosition, tileWidth:pretendTileWidth, tileHeight:pretendTileHeight) + center
                chunkNode.zPosition = CGFloat(mapViewer!.chunkDepth(chunk_x, chunk_y:chunk_y))
                mapNode.addChild(chunkNode)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        let isoLocation = tilePosForScreenPos(location, center:center, cameraPos:cameraPosition, tileWidth:pretendTileWidth, tileHeight:pretendTileHeight)
        let iso_delta_x = isoLocation.x - cameraPosition.x
        let iso_delta_y = isoLocation.y - cameraPosition.y
        cameraVelocity.x = CGFloat(-1*iso_delta_x/100.0)
        cameraVelocity.y = CGFloat(-1*iso_delta_y/100.0)
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        let previousCameraPosition = Coord(x:cameraPosition.x, y:cameraPosition.y, z:cameraPosition.z)
        cameraPosition.x = cameraPosition.x + Double(cameraVelocity.x)
        cameraPosition.y = cameraPosition.y + Double(cameraVelocity.y)
        
        if (previousCameraPosition != cameraPosition)
        {
            let delta_iso_x = previousCameraPosition.x - cameraPosition.x
            let delta_iso_y = previousCameraPosition.y - cameraPosition.y
            
            let screenDelta = screenUnitForTileUnit(delta_iso_x, delta_y:delta_iso_y, tileWidth:pretendTileWidth, tileHeight:pretendTileHeight)
//            let screenDeltaPoint = CGPointMake(CGFloat(screenDelta.x), CGFloat(screenDelta.y))
            
            mapNode.position.x += CGFloat(screenDelta.x)
            mapNode.position.y += CGFloat(screenDelta.y)
//            for chunk in mapNode.children
//            {
//                chunk.position = chunk.position + screenDeltaPoint
//            }
        }
        
//         Update logic (if the viewer needs shifting)
        checkEdges()
    }
}
