import UIKit

public extension CGPoint {
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    static func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    func distance(to other: CGPoint) -> CGFloat {
        return hypot(other.x - self.x, other.y - self.y)
    }
    
    var absolute: CGPoint {
        return CGPoint(x: abs(x), y: abs(y))
    }
    
}

public extension UIView {
    var origin: CGPoint {
        get { frame.origin }
        set {
            var f = self.frame
            f.origin = newValue
            self.frame = f
        }
    }
}
