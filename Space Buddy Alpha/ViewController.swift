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
        createImages()
        BodiesContainer.layer.borderColor = UIColor.darkGray.cgColor
        BodiesContainer.layer.borderWidth = 6
        BodiesContainer.layer.cornerRadius = 10
        SpaceView.layer.borderColor = UIColor.darkGray.cgColor
        SpaceView.layer.borderWidth = 6
        SpaceView.layer.cornerRadius = 10
        Controls.layer.borderColor = UIColor.darkGray.cgColor
        Controls.layer.borderWidth = 6
        Controls.layer.cornerRadius = 10
        
        addGrayFixes()
        
        DraggableImageView.IllegalZones = [Controls, BodiesContainer]
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func addGrayFixes(){
        let grayView = UIView()
        grayView.frame = CGRect(x: Controls.frame.minX + 62, y: Controls.frame.maxY, width: 15, height: 12)
        grayView.backgroundColor = UIColor.darkGray
        view.addSubview(grayView)
        
        let grayView2 = UIView()
        grayView2.frame = CGRect(x: Controls.frame.minX + 62, y: Controls.frame.maxY - 5, width: 11, height: 20)
        grayView2.backgroundColor = UIColor.darkGray
        view.addSubview(grayView2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createImages(){
        let w = Double(BodiesContainer.frame.width)
        let h = Double(BodiesContainer.frame.height)
        var frame = CGRect(x: w/6 + 20, y: 50, width: w, height: h / 7)
        for (name, image) in SpaceCell.planetImages{
            if name != "blank"{
                let imageView = DraggableImageView(image: image)
                imageView.frame = frame
                imageView.lastLocation = imageView.center
                view.addSubview(imageView)
                frame = frame.offsetBy(dx: 0, dy: CGFloat(1.5 * h / 7))
            }
        }
        view.sendSubview(toBack: SpaceView)
    }
}



class SpaceCell: UICollectionViewCell {
    
    static let planetImages: [String: UIImage] = ["Planets":#imageLiteral(resourceName: "Earth for app"), "Asteroids": #imageLiteral(resourceName: "asteroid for app"), "Suns": #imageLiteral(resourceName: "Sun Image For App"), "Neutrons":#imageLiteral(resourceName: "Neutron For app"), "Blackholes":#imageLiteral(resourceName: "Screen Shot 2017-03-20 at 8.48.13 PM"), "blank": #imageLiteral(resourceName: "Screen Shot 2017-03-20 at 8.48.13 PM")]
}
