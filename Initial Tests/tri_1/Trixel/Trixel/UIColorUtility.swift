//
//  UIColorUtilit.swift
//  Trixel
//
//  Created by Alicia Cicon on 8/30/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import SpriteKit

extension UIColor
{
    public class func randomColor() -> UIColor
    {
        let randomRed = CGFloat(randNormalDouble())
        let randomGreen = CGFloat(randNormalDouble())
        let randomBlue = CGFloat(randNormalDouble())
        
        return UIColor(red:randomRed, green:randomGreen, blue:randomBlue, alpha:1.0)
    }
    
    public class func randomGreyscale() -> UIColor
    {
        let randomValue = CGFloat(randNormalDouble())
        
        return UIColor(red:randomValue, green:randomValue, blue:randomValue, alpha:1.0)
    }
}