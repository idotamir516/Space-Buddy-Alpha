//
//  DraggableImageView.swift
//  Space Buddy Alpha
//
//  Created by Ido Tamir on 5/3/17.
//  Copyright © 2017 Ido Tamir. All rights reserved.
//

import Foundation
import UIKit

class DraggableImageView: UIImageView{
    var lastLocation = CGPoint(x: 0, y: 0);
    
    var maxSuperView: UIView {var view = self.superview!
        while(view.superview != nil){
            view = view.superview!
        }
        return view;
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(DraggableImageView.detectPan(_:)))
        self.gestureRecognizers = [panRecognizer]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func detectPan(_ recognizer:UIPanGestureRecognizer) {
        print("hello")
        let translation  = recognizer.translation(in: self.maxSuperView)
        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        
    }
    
    override func touchesBegan(_ touches: (Set<UITouch>!), with event: UIEvent!) {
        // Promote the touched view
        self.superview?.bringSubview(toFront: self)
        print("not here")
        // Remember original location
        lastLocation = self.center
    }
}
