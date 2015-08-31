//
//  GameScene.swift
//  Trixel
//
//  Created by Alicia Cicon on 8/30/15.
//  Copyright (c) 2015 Runemark. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    var window:CGSize = CGSize(width:0, height:0)
    var center:CGPoint = CGPoint(x:0, y:0)
    var texturePack = SKTextureAtlas(named:"Triangles")
    
    override func didMoveToView(view:SKView)
    {
        self.backgroundColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1.0)
        
        self.size = view.bounds.size
        window = view.bounds.size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        let triangleWidth = CGFloat(30)
        let triangleHeight = CGFloat(30)
        
        let triCount_x = Int(ceil(window.width / triangleWidth))
        let triCount_y = Int(ceil(window.height / triangleHeight))
        
        for x in 0..<triCount_x
        {
            for y in 0..<triCount_y
            {
                if (x % 2 == 0)
                {
                    let triangle = SKSpriteNode(texture:texturePack.textureNamed("g1"))
                    triangle.resizeNode(triangleWidth, y:triangleHeight)
                    triangle.position = CGPointMake(CGFloat(x)*triangleWidth + 0.5*triangleWidth, CGFloat(y)*triangleHeight + 0.5*triangleHeight)
                    
                    let triangle_offset = SKSpriteNode(texture:texturePack.textureNamed("g2"))
                    triangle_offset.resizeNode(triangleWidth, y:triangleHeight)
                    triangle_offset.position = CGPointMake(CGFloat(x)*triangleWidth + 0.5*triangleWidth, CGFloat(y)*triangleHeight)
                    
                    self.addChild(triangle)
                    self.addChild(triangle_offset)
                }
                else
                {
                    let triangle = SKSpriteNode(texture:texturePack.textureNamed("g2"))
                    triangle.resizeNode(triangleWidth, y:triangleHeight)
                    triangle.position = CGPointMake(CGFloat(x)*triangleWidth + 0.5*triangleWidth, CGFloat(y)*triangleHeight + 0.5*triangleHeight)
                    
                    let triangle_offset = SKSpriteNode(texture:texturePack.textureNamed("g1"))
                    triangle_offset.resizeNode(triangleWidth, y:triangleHeight)
                    triangle_offset.position = CGPointMake(CGFloat(x)*triangleWidth + 0.5*triangleWidth, CGFloat(y)*triangleHeight)
                    
                    self.addChild(triangle)
                    self.addChild(triangle_offset)
                }
                
                
                
//                if (x % 2 == 0)
//                {
//                    
//                }
//                else
//                {
//                    triangle_offset.xScale = -1*triangle_offset.xScale
//                }
//                
//                triangle.color = UIColor.randomColor()
//                triangle.colorBlendFactor = 1.0
//                
//                triangle_offset.color = UIColor.randomColor()
//                triangle_offset.colorBlendFactor = 1.0
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        // Random static every frame
//        for triangle in self.children
//        {
//            let triangleSprite = triangle as! SKSpriteNode
//            triangleSprite.color = UIColor.randomColor()
//        }
    }
}
