//
//  Array2D.swift
//  Created by Martin Mumford on 3/10/15

import Foundation

public class ChunkArray2D
{
    var xMax:Int = 0
    var yMax:Int = 0
    var matrix:[Chunk]
    
    // max x (rows), max y (cols)
    init(x:Int, y:Int) {
        
        self.xMax = x
        self.yMax = y
        matrix = Array(count:xMax*yMax, repeatedValue:Chunk(live:false))
        
        // Fill the matrix with empty live chunks
        for x in 0..<xMax
        {
            for y in 0..<yMax
            {
                matrix[yMax * x + y] = Chunk()
            }
        }
    }
    
    subscript(x:Int, y:Int) -> Chunk {
        get
        {
            return matrix[yMax * x + y]
        }
        set
        {
            matrix[yMax * x + y] = newValue
        }
    }
    
    func withinBounds(x:Int, y:Int) -> Bool
    {
        return (x >= 0 && y >= 0 && x < xMax && y < yMax)
    }
    
    func toVector() -> [Chunk]
    {
        return matrix
    }
}
