import Foundation
import SpriteKit

//////////////////////////////////////////////////////////////////////////////////////////
// Handy CGPoint Arithmatic
//////////////////////////////////////////////////////////////////////////////////////////

func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPointMake(lhs.x + rhs.x, lhs.y + rhs.y)
}

//////////////////////////////////////////////////////////////////////////////////////////
// 2D Screen Coordinates
//////////////////////////////////////////////////////////////////////////////////////////

struct Position
{
    var x:Double
    var y:Double
    
    func details() -> String
    {
        return "\(x),\(y)"
    }
    
    func toPoint() -> CGPoint
    {
        return CGPoint(x:CGFloat(x), y:CGFloat(y))
    }
    
    func roundDown() -> DiscretePosition
    {
        return DiscretePosition(x:Int(floor(x)), y:Int(floor(y)))
    }
}

struct DiscretePosition
{
    var x:Int
    var y:Int
    
    func details() -> String
    {
        return "\(x).\(y)"
    }
    
    mutating func shiftBy(other:DiscretePosition)
    {
        x += other.x
        y += other.y
    }
    
    func toPosition() -> Position
    {
        return Position(x:Double(x), y:Double(y))
    }
}

extension DiscretePosition : Hashable
{
    var hashValue:Int
        {
            return "\(x),\(y)".hashValue
    }
}

// EQUATABLE
func ==(lhs:DiscretePosition, rhs:DiscretePosition) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func !=(lhs:DiscretePosition, rhs:DiscretePosition) -> Bool {
    return !(lhs == rhs)
}

//////////////////////////////////////////////////////////////////////////////////////////
// 3D Tile Coordinates
//////////////////////////////////////////////////////////////////////////////////////////

struct DiscreteCoord
{
    var x:Int
    var y:Int
    var z:Int
    
    func details() -> String
    {
        return "\(x),\(y),\(z)"
    }
    
    func north() -> DiscreteCoord
    {
        return DiscreteCoord(x:x, y:y+1, z:z)
    }
    
    func east() -> DiscreteCoord
    {
        return DiscreteCoord(x:x-1, y:y, z:z)
    }
    
    func south() -> DiscreteCoord
    {
        return DiscreteCoord(x:x, y:y-1, z:z)
    }
    
    func west() -> DiscreteCoord
    {
        return DiscreteCoord(x:x+1, y:y, z:z)
    }
    
    func up() -> DiscreteCoord
    {
        return DiscreteCoord(x:x, y:y, z:z+1)
    }
    
    func down() -> DiscreteCoord
    {
        return DiscreteCoord(x:x, y:y, z:z-1)
    }
}

// HASHABLE
extension DiscreteCoord : Hashable
{
    var hashValue:Int
        {
            return "\(x),\(y),\(z)".hashValue
    }
}

// EQUATABLE
func ==(lhs:DiscreteCoord, rhs:DiscreteCoord) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

struct Coord
{
    var x:Double
    var y:Double
    var z:Double
    
    func details() -> String
    {
        return "\(x),\(y),\(z)"
    }
    
    func roundDown() -> DiscreteCoord
    {
        return DiscreteCoord(x:Int(floor(x)), y:Int(floor(y)), z:Int(floor(z)))
    }
}

// HASHABLE
extension Coord: Hashable
{
    var hashValue:Int
        {
            return "\(x),\(y),\(z)".hashValue
    }
}

// EQUATABLE
func ==(lhs:Coord, rhs:Coord) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

func += (inout lhs:Coord, rhs:Coord)  {
    
    lhs.x = lhs.x+rhs.x
    lhs.y = lhs.y+rhs.y
    lhs.z = lhs.z+rhs.z
}


//////////////////////////////////////////////////////////////////////////////////////////
// Screen-Tile Tile-Screen Conversion
//////////////////////////////////////////////////////////////////////////////////////////

func screenUnitForTileUnit(delta_x:Double, delta_y:Double, tileWidth:CGFloat, tileHeight:CGFloat) -> Position
{
    let width = Double(tileWidth)
    let height = Double(tileHeight)
    
    let screen_x = (delta_x*(0.5*width)) + (delta_y*(-0.5*width))
    let screen_y = (delta_x*(-0.25*height)) + (delta_y*(-0.25*height))
    
    return Position(x:screen_x, y:screen_y)
}

func screenPosForTilePos(tilePos:Coord, cameraPos:Coord, tileWidth:CGFloat, tileHeight:CGFloat) -> Position
{
    let delta_x = tilePos.x - cameraPos.x
    let delta_y = tilePos.y - cameraPos.y
    let delta_z = tilePos.z - cameraPos.z
    
    let width = Double(tileWidth)
    let height = Double(tileHeight)
    
    let screen_x = (delta_x*(0.5*width)) + (delta_y*(-0.5*width))
    let screen_y = (delta_x*(-0.25*height)) + (delta_y*(-0.25*height)) + (delta_z*(0.5*height))
    
    return Position(x:screen_x, y:screen_y)
}

// Returns a coordinate ON THE SAME PLANE AS THE CAMERA
func tilePosForScreenPos(screenPos:CGPoint, center:CGPoint, cameraPos:Coord, tileWidth:CGFloat, tileHeight:CGFloat) -> Coord
{
    let delta_x = Double(screenPos.x) - Double(center.x)
    let delta_y = Double(screenPos.y) - Double(center.y)
    
    let width = Double(tileWidth)
    let height = Double(tileHeight)
    
    let tile_x = (delta_x/width) - ((2*delta_y)/height) + cameraPos.x
    let tile_y = (-1*(delta_x/width)) - ((2*delta_y)/height) + cameraPos.y
    
    return Coord(x:tile_x, y:tile_y, z:cameraPos.z)
}

// Returns delta screen coordinates relative to the CENTER of the chunk (2,2)
func screenPosForRelativeChunkTilePos(relativeTilePos:Coord, tileWidth:CGFloat, tileHeight:CGFloat) -> Position
{
    let chunkCenter = Coord(x:2.0, y:2.0, z:0.0)
    
    let delta_x = relativeTilePos.x - chunkCenter.x
    let delta_y = relativeTilePos.y - chunkCenter.y
    let delta_z = relativeTilePos.z - chunkCenter.z
    
    let width = Double(tileWidth)
    let height = Double(tileHeight)
    
    let screen_x = (delta_x*(0.5*width)) + (delta_y*(-0.5*width))
    let screen_y = (delta_x*(-0.25*height)) + (delta_y*(-0.25*height)) + (delta_z*(0.5*height))
    
    return Position(x:screen_x, y:screen_y)
}

// WARXING: does not support depth (ignores z)
func chunkForTile(tile:DiscretePosition) -> DiscretePosition
{
    let chunk_x = Int(floor(Double(tile.x)/4.0))
    let chunk_y = Int(floor(Double(tile.y)/4.0))
    
    return DiscretePosition(x:chunk_x, y:chunk_y)
}