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
    var lastLocation = CGPoint(x: 0, y: 0)
    var maxSuperView: UIView {var view: UIView? = self; while (view?.superview != nil) {view = view?.superview}; return view!}
    var original: Bool = true;
    weak var delegate: ViewDragDelegate?
    
    static var IllegalZones: [UIView] = []
    
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
        self.superview?.addSubview(image)
    }
    
    func detectPan(_ recognizer:UIPanGestureRecognizer) {
        if original{
            makeCopyImage()
            self.original = false;
        }
        let translation  = recognizer.translation(in: self.maxSuperView)
        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        let inIllegalZoneBefore = DraggableImageView.IllegalZones.filter{$0.frame.contains(self.lastLocation)}.count != 0;
        
        let inIllegalZoneNow = inIllegalZone()
        if inIllegalZoneNow && !inIllegalZoneBefore{
            recognizer.isEnabled = false;
            recognizer.isEnabled = true;
            delegate?.handleEnd(self, inLegalZone: !inIllegalZone())
            self.removeFromSuperview();
            return;
        }
        
        if recognizer.state == .ended{
            self.alpha = 1
            delegate?.handleEnd(self, inLegalZone: !inIllegalZone())
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
        lastLocation = self.center
        self.alpha = 0.5
    }
    
    func inIllegalZone() -> Bool{
        return DraggableImageView.IllegalZones.filter{$0.frame.intersects(self.frame)}.count != 0;
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 1
        delegate?.handleEnd(self, inLegalZone: !inIllegalZone())
    }

    func createBody() -> Body{
        let key = SpaceCell.planetImages.keysForValue(value: image!)!
        let mass = SpaceCell.planetMasses[key]!
        let radius = SpaceCell.planetRadius[key]!
        let body = Body(mass: mass, position: Vector2D(), velocity: Vector2D(), radius: radius)
        return body;
    }
}
