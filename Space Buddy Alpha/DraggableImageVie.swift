//
//  DraggableImageVie.swift
//  Space Buddy Alpha
//
//  Created by Ido Tamir on 5/15/17.
//  Copyright © 2017 Ido Tamir. All rights reserved.
//

import Foundation
import UIKit

class DraggableImageView: UIImageView{
    var beginningLocation = CGPoint(x: 0, y: 0)
    var lastLocation = CGPoint(x: 0, y: 0)
    var lastVelocity = Vector2D()
    var lastTime = Date()
    let calender = Calendar.current
    var maxSuperView: UIView {var view: UIView? = self; while (view?.superview != nil) {view = view?.superview}; return view!}
    var original: Bool = true;
    weak var delegate: ViewDragDelegate?
    
    static var IllegalZones: [UIView] = []
    var color = ViewController.pickNextColor()
    override init(image: UIImage?) {
        super.init(image: image)
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(DraggableImageView.detectPan(_:)))
        self.gestureRecognizers = [panRecognizer]
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeCopyImage() {
        let image = DraggableImageView(image: self.image)
        image.frame = self.frame;
        image.original = true;
        image.delegate = delegate
        image.color = ViewController.pickNextColor()
        self.superview?.addSubview(image)
    }
    
    func detectPan(_ recognizer:UIPanGestureRecognizer) {
        if original{
            makeCopyImage()
            self.original = false;
        }
        
        let spatialDifference = Vector2D(point: self.center - self.lastLocation)
        let component: Set<Calendar.Component> = [.nanosecond,.second, .minute, .hour]
        let timeDifference = Double(calender.dateComponents(component, from: Date(), to: lastTime).nanosecond!) / 1E9
        let viewVelocity = spatialDifference / Double(timeDifference)
        
        
        let translation  = recognizer.translation(in: self.maxSuperView)
        self.center = CGPoint(x: beginningLocation.x + translation.x, y: beginningLocation.y + translation.y)
        if spatialDifference.hypotenuse != 0 && timeDifference != 0{
            
            lastVelocity = Vector2D(x: -viewVelocity.x, y: viewVelocity.y)
            lastLocation = self.center
            lastTime = Date()}
        
        
        let inIllegalZoneBefore = DraggableImageView.IllegalZones.filter{$0.frame.contains(self.beginningLocation)}.count != 0;
        
        let inIllegalZoneNow = inIllegalZone()
        
        if inIllegalZoneNow && !inIllegalZoneBefore{
            recognizer.isEnabled = false;
            recognizer.isEnabled = true;
            delegate?.handleEnd(self, inLegalZone: !inIllegalZone(), finalVelocity: lastVelocity)
            self.removeFromSuperview();
            return;
        }
        
        if recognizer.state == .ended{
            self.alpha = 1
            delegate?.handleEnd(self, inLegalZone: !inIllegalZone(), finalVelocity: lastVelocity)

            if inIllegalZoneNow{
                self.removeFromSuperview()
            }
        }
    }
    
    override func touchesBegan(_ touches: (Set<UITouch>!), with event: UIEvent!) {
        delegate?.handleBegin(self, inLegalZone: !inIllegalZone())
        
        // Promote the touched view
        self.maxSuperView.bringSubview(toFront: self)
        
        // Remember original location
        beginningLocation = self.center
        self.alpha = 0.5
    }
    
    func inIllegalZone() -> Bool{
        return DraggableImageView.IllegalZones.filter{$0.frame.intersects(self.frame)}.count != 0;
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 1
        delegate?.handleEnd(self, inLegalZone: !inIllegalZone(), finalVelocity: Vector2D())
    }

    func createBody() -> Body{
        let key = SpaceCell.planetImages.keysForValue(value: image!)!
        let mass = SpaceCell.planetMasses[key]!
        let radius = SpaceCell.planetRadius[key]!
        let body = Body(mass: mass, position: Vector2D(), velocity: Vector2D(), radius: radius)
        return body;
    }
    
    }

    


extension CGPoint{
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
}

extension Vector2D{
    init(point: CGPoint){
        x = Double(point.x)
        y = Double(point.y)
    }
}

