//
//  Space.swift
//  Space Buddy Beta
//
//  Created by Ido Tamir on 1/30/17.
//  Copyright © 2017 Ido Tamir. All rights reserved.
//

import Foundation

class Space{
    static let G: Double = 6.67408 * pow(10, -11);
    static let SECONDS: Double = 5;
    var bodies: Set<Body> = [];
    
    func addBody(body: Body){
        bodies.insert(body)
    }
    
    func remove(body: Body){
        bodies.remove(body)
    }
    
    func accelerationAt(position: Vector2D, on body1: Body, causedBy body2: Body) -> Vector2D{
        guard body1 != body2 else {return Vector2D()}
        let d = body2.position - position
        let totalDistance = d.hypotenuse;
        let gravityConstant = Space.G * body2.mass / (totalDistance * totalDistance * totalDistance)
        let acceleration = Vector2D(x: d.x * gravityConstant, y: d.y * gravityConstant)
        return acceleration;
    }
    
    func accelerationAt(position: Vector2D, on body: Body) -> Vector2D {
        let acc = bodies.reduce(Vector2D(), {$0 + accelerationAt(position: position, on: body, causedBy: $1)})
        return acc;
    }
    
    func updateAcceleration(planet: Body){
        let acc = bodies.reduce(Vector2D(), {$0 + planet.acceleration(causedBy: $1)})
        planet.acceleration = acc;
    }
    
    func initialDerivative(planet: Body) -> Derivative{
        updateAcceleration(planet: planet)
        return Derivative(velocity: planet.velocity, acc: planet.acceleration)
    }
    
    func nextDerivative(planet: Body, currentState state: CurrentState, derivative: Derivative, dt: Double) -> Derivative {
        let nextPosition = state.position + derivative.velocity * dt
        let nextVelocity = state.velocity + derivative.acc * dt
        let nextAcceleration = accelerationAt(position: nextPosition, on: planet)
        return Derivative(velocity: nextVelocity, acc: nextAcceleration)
    }
    
    func updatePlanet(_ body: Body, time dt: Double){
        let state = body.currentState;
        let k1 = initialDerivative(planet: body)
        let k2 = nextDerivative(planet: body, currentState: state, derivative: k1, dt: dt / 2)
        let k3 = nextDerivative(planet: body, currentState: state, derivative: k2, dt: dt / 2)
        let k4 = nextDerivative(planet: body, currentState: state, derivative: k3, dt: dt)
        
        let dpdt = (k1.velocity + (k2.velocity + k3.velocity) * 2.0 + k4.velocity) * (1.0 / 6.0)
        let dvdt = (k1.acc + (k2.acc + k3.acc) * 2.0 + k4.acc) * (1.0 / 6.0)
        
        body.position += dpdt * dt
        body.velocity += dvdt * dt
    }
    
    func otherUpdate(time dt: Double){
        for body in bodies{
            updatePlanet(body, time: dt)
        }
    }
    
    func update(time dt: Double){
        for body in bodies{
            let acc = bodies.reduce(Vector2D(), {$0 + body.acceleration(causedBy: $1)})
            body.acceleration = acc;
        }
        for body in bodies{
            body.move(seconds: dt);
        }
    }
    
    func remove(at: Vector2D){
        bodies = Set(bodies.filter{abs(($0.position - at).hypotenuse) > $0.radius})
    }
    
}

class Body: Equatable, Hashable {
    static var TOTALID = 0
    let ID: Int;
    let mass: Double;
    var currentState: CurrentState;
    var position: Vector2D {
        get {return currentState.position}
        set(newPosition) {currentState.position = newPosition}}
    var velocity: Vector2D{
        get {return currentState.velocity}
        set(newVelocity) {currentState.velocity = newVelocity}}
    var acceleration: Vector2D;
    var radius: Double
    
    var hashValue: Int{return ID}
    
    init(mass: Double, position: Vector2D, velocity: Vector2D, radius: Double){
        ID = Body.TOTALID;
        Body.TOTALID += 1;
        self.mass = mass
        currentState = CurrentState()
        acceleration = Vector2D();
        self.radius = radius;
        self.position = position;
        self.velocity = velocity;
    }
    
    func acceleration(causedBy body: Body) -> Vector2D{
        guard self != body else {return Vector2D()}
        let d = distance(to: body);
        let totalDistance = d.hypotenuse;
        let gravityConstant = Space.G * body.mass / (totalDistance * totalDistance * totalDistance)
        let acceleration = Vector2D(x: d.x * gravityConstant, y: d.y * gravityConstant)
        return acceleration;
    }
    
    func distance(to body: Body) -> Vector2D{
        return body.position - self.position
    }
    
    //mutating
    func move(seconds dt: Double){
        position += velocity * dt + acceleration * 0.5 * dt * dt;
        velocity += acceleration * dt
    }
    
    static func == (left: Body, right: Body) -> Bool {
        return (left.ID == right.ID)
    }
    
}

enum CollisionType {
    case INELASTIC, SEMIELASTIC, ABSOPRTION
}

enum BodyType{
    case STAR, PLANET, BLACKHOLE, ASTROID
}
