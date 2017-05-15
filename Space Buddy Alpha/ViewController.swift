//
//  ViewController.swift
//  Space Buddy Alpha
//
//  Created by Ido Tamir on 5/3/17.
//  Copyright © 2017 Ido Tamir. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var BodiesContainer: UIView!
    @IBOutlet weak var SpaceView: UIView!
    @IBOutlet weak var Controls: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = DraggableImageView(image: #imageLiteral(resourceName: "asteroid for app"))
        image.frame = CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 100, height: 100))
        image.lastLocation = image.center;
        view.addSubview(image)
        DraggableImageView.IllegalZones = [Controls, BodiesContainer]
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

