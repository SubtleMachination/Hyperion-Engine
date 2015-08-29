//
//  Array2D.swift
//  Created by Martin Mumford on 3/10/15

import Foundation

public class Array2D<T>
{
    var xMax:Int = 0
    var yMax:Int = 0
    var matrix:[T]
    
    var fillerValue:T
    
    convenience init(filler:T)
    {
        self.init(x:0, y:0, filler:filler)
    }
    
    // max x (rows), max y (cols)
    init(x:Int, y:Int, filler:T) {
        
        self.xMax = x
        self.yMax = y
        self.fillerValue = filler
        matrix = Array<T>(count:xMax*yMax, repeatedValue:filler)
    }
    
    subscript(x:Int, y:Int) -> T {
        get
        {
            return matrix[yMax * x + y]
        }
        set
        {
            matrix[yMax * x + y] = newValue
        }
    }
    
    func fill(value:T)
    {
        for x in 0..<xMax
        {
            for y in 0..<yMax
            {
                matrix[yMax*x + y] = value
            }
        }
    }
    
    func withinBounds(x:Int, y:Int) -> Bool
    {
        return (x >= 0 && y >= 0 && x < xMax && y < yMax)
    }
    
    func toVector() -> [T]
    {
        return matrix
    }
}
