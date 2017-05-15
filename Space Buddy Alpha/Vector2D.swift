//
//  Vector2D.swift
//  Space Buddy Beta
//
//  Created by Ido Tamir on 1/30/17.
//  Copyright © 2017 Ido Tamir. All rights reserved.
//

import Foundation

struct Vector2D {
    var x = 0.0, y = 0.0
    
    var hypotenuse: Double{return sqrt((x * x) + (y * y))}
    
    static func + (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func * (left: Vector2D, right: Double) -> Vector2D{
        return Vector2D(x: left.x * right, y: left.y * right)
    }
    
    static prefix func - (vector: Vector2D) -> Vector2D {
        return Vector2D(x: -vector.x, y: -vector.y)
    }
    
    static func += (left: inout Vector2D, right: Vector2D) {
        left = left + right
    }
    
    static func == (left: Vector2D, right: Vector2D) -> Bool {
        return (left.x == right.x) && (left.y == right.y)
    }
    
    static func != (left: Vector2D, right: Vector2D) -> Bool {
        return !(left == right)
    }
    
}

struct CurrentState {
    var position: Vector2D = Vector2D();
    var velocity: Vector2D = Vector2D();
}

struct Derivative {
    var velocity: Vector2D
    var acc: Vector2D
}



