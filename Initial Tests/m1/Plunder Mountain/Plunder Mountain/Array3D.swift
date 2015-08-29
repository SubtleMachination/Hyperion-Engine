import Foundation

class Array3D<T>
{
    var xMax:Int
    var yMax:Int
    var zMax:Int
    var matrix:[T]
    
    init(x:Int, y:Int, z:Int, filler:T)
    {
        self.xMax = x
        self.yMax = y
        self.zMax = z
        matrix = Array<T>(count:(x*y*z), repeatedValue:filler)
    }
    
    subscript(x:Int, y:Int, z:Int) -> T {
        get
        {
            return matrix[(xMax*yMax * z) + (xMax * y) + x]
        }
        set
        {
            matrix[(xMax*yMax * z) + (xMax * y) + x] = newValue
        }
    }
    
    func withinBounds(x:Int, y:Int, z:Int) -> Bool
    {
        return (x >= 0 && y >= 0 && z>=0 && x < xMax && y < yMax && z < zMax)
    }
    
//    func random() -> (x:Int, y:Int, z:Int)
//    {
//        let x_rand = randIntBetween(0, stop:xMax-1)
//        let y_rand = randIntBetween(0, stop:yMax-1)
//        let z_rand = randIntBetween(0, stop:zMax-1)
//        return (x:x_rand, y:y_rand, z:z_rand)
//    }
    
//    func immediateNeighborhood(center:DiscreteCoord) -> Set<DiscreteCoord>
//    {
//        var neighborhoodDiscreteCoordinates = Set<DiscreteCoord>()
//        
//        var uncheckedNeighbors = [DiscreteCoord]()
//        
//        uncheckedNeighbors.append(center.north())
//        uncheckedNeighbors.append(center.east())
//        uncheckedNeighbors.append(center.south())
//        uncheckedNeighbors.append(center.west())
//        uncheckedNeighbors.append(center.up())
//        uncheckedNeighbors.append(center.down())
//        
//        for uncheckedNeighbor in uncheckedNeighbors
//        {
//            if (withinBounds(uncheckedNeighbor))
//            {
//                neighborhoodDiscreteCoordinates.insert(uncheckedNeighbor)
//            }
//        }
//        
//        return neighborhoodDiscreteCoordinates
//    }
//    
//    func neighborhood(center:DiscreteCoord) -> Set<DiscreteCoord>
//    {
//        var neighborhoodDiscreteCoordinates = Set<DiscreteCoord>()
//        
//        for local_x in center.x-1...center.x+1
//        {
//            for local_y in center.y-1...center.y+1
//            {
//                for local_z in center.z-1...center.z+1
//                {
//                    let localDiscreteCoord = DiscreteCoord(x:local_x, y:local_y, z:local_z)
//                    if (withinBounds(localDiscreteCoord) && localDiscreteCoord != center)
//                    {
//                        neighborhoodDiscreteCoordinates.insert(localDiscreteCoord)
//                    }
//                }
//            }
//        }
//        
//        return neighborhoodDiscreteCoordinates
//    }
}