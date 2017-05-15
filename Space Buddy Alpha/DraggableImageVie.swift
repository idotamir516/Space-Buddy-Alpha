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
    
    func detectPan(_ recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.maxSuperView)
        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        let inIllegalZoneBefore = DraggableImageView.IllegalZones.filter{$0.frame.contains(self.lastLocation)}.count != 0;
        let inIllegalZoneNow = DraggableImageView.IllegalZones.filter{$0.frame.contains(self.center)}.count != 0;
        if inIllegalZoneNow && !inIllegalZoneBefore{
            print("NEEDS IMPLEMENTATION IN ILLEGAL ZONE")
            recognizer.isEnabled = false;
            recognizer.isEnabled = true;
        }
        if recognizer.state == .ended{
            self.alpha = 1
        }
    }
    
    override func touchesBegan(_ touches: (Set<UITouch>!), with event: UIEvent!) {
        // Promote the touched view
        self.superview?.bringSubview(toFront: self)
        
        // Remember original location
        lastLocation = self.center
        self.alpha = 0.5
    }

}
