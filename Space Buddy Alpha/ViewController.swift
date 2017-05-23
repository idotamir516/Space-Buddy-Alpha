//
//  ViewController.swift
//  Space Buddy Alpha
//
//  Created by Ido Tamir on 5/3/17.
//  Copyright © 2017 Ido Tamir. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ViewDragDelegate {
    
    @IBOutlet weak var simulationSpeed: UISlider!
    @IBOutlet weak var radiusChange: UISlider!
    var space = Space();
    var bodiesList: [DraggableImageView:Body] = [:]
    var movingBodies: [DraggableImageView:Body] = [:]
    var timer: Timer = Timer()
    var updateTime: Double = 0.01;
    var spaceTime: Double = 1
    @IBAction func simulationSpeedChanged(sender: UISlider) {
        timer.invalidate() // just in case this button is tapped multiple times
        
        if(sender.value != 0){
            // start the timer
            timer = Timer.scheduledTimer(withTimeInterval: (0.01 / Double(sender.value)), repeats: true, block: { _ in
                self.update()
            })
            updateTime = 0.1 / Double(sender.value)
        }
        else {
            updateTime = 0
        }
    }
    
    @IBAction func radiusChanged(sender: UISlider) {
        timer.invalidate() // just in case this button is tapped multiple times
        if(sender.value != 0){
            // start the timer
            spaceRadius = Double(sender.value) * (2E12 - 2E6) + 2E6
            update()
            timer = Timer.scheduledTimer(withTimeInterval: (0.01 / Double(sender.value)), repeats: true, block: { _ in
                self.update()
            })
        }
        else {
            spaceRadius = 2E6
        }
    }
    
    var smallestLength: Double {
        let width =  SpaceView.frame.width
        let height = SpaceView.frame.height
        return Double(width < height ? width : height);
    }
    
    var spaceRadius: Double = 1E12
    
    func spaceToView(position: Vector2D) -> CGPoint{
        let (x, y) = (position.x, position.y)
        let viewSpaceRatio = smallestLength / (spaceRadius * 2)
        let widthToHeightRatio = Double(SpaceView.frame.width.divided(by: SpaceView.frame.height))
        let xCoor = viewSpaceRatio * (x + spaceRadius * widthToHeightRatio)
        let yCoor = Double(SpaceView.frame.height) - viewSpaceRatio * (y + spaceRadius)
        return CGPoint(x: xCoor, y: yCoor)
    }
    
    func createTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: updateTime / Double(simulationSpeed.value), repeats: true, block: { _ in
            self.update()
        })
    }
    
    func ViewToSpace(point: CGPoint) -> Vector2D{
        let location = SpaceView.convert(point, from: view)
        let spaceViewRatio = spaceRadius * 2 / smallestLength
        let xCoor = spaceViewRatio * Double(location.x - SpaceView.frame.width.divided(by: 2))
        let yCoor = spaceViewRatio * Double(SpaceView.frame.height.divided(by: 2) - location.y)
        return Vector2D(x: xCoor, y: yCoor)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vts = ViewToSpace(point: touches.first!.location(in: view))
        print("vts \(vts)")
        let stv = spaceToView(position: vts)
        print("stv \(stv)")
        let redo = ViewToSpace(point: stv)
        print("redo: \(redo)")
    }
    
    func update(){
        var newBodiesList: [DraggableImageView:Body] = [:]
        for (view, body) in bodiesList{
            let newBody = space.bodies.first(where: {$0 == body})!
            newBodiesList[view] = newBody;
        }
        bodiesList = newBodiesList
        space.update(time: spaceTime)
        putViewsInCorrectPosition()
    }
    
    func putViewsInCorrectPosition(){
        for (view, body) in bodiesList{
            correctPosition(of: view, using: body)
        }
    }
    
    func correctPosition(of view: DraggableImageView, using body: Body){
        let size = view.frame.size
        let oldCenter = CGPoint(x: view.frame.origin.x + size.width / 2, y: view.frame.origin.y + size.height / 2)
        let newCenter = spaceToView(position: body.position)
        let newFrame = view.frame.offsetBy(dx: newCenter.x - oldCenter.x, dy: newCenter.y - oldCenter.y)
        view.frame = SpaceView.convert(newFrame, to: self.view)
        if view.inIllegalZone(){
            view.alpha = 0
        }else{
            if view.alpha == 0 {
                view.alpha = 1
            }
        }
    }
    
    func handleBegin(_ view: DraggableImageView, inLegalZone: Bool) {
        if inLegalZone{
            let body = bodiesList.removeValue(forKey: view)!
            space.remove(body: body)
            movingBodies[view] = body;
        }else{
            movingBodies[view] = view.createBody()
        }
    }

    
    func handleEnd(_ view: DraggableImageView, inLegalZone: Bool, finalVelocity: Vector2D) {
        let b = movingBodies.removeValue(forKey: view)
        if let body = b{
        if inLegalZone {
            let viewSpaceRatio = spaceRadius * 2 / smallestLength
            let size = view.frame.size
            let center = CGPoint(x: view.frame.origin.x + size.width / 2, y: view.frame.origin.y + size.height / 2)
            let position = ViewToSpace(point: center)
            let velocity = finalVelocity * viewSpaceRatio * updateTime / spaceTime
            let newBody = Body(mass: body.mass, position: position, velocity: velocity, radius: body.radius)
            bodiesList[view] = newBody
            space.remove(body: body)
            space.addBody(body: newBody)
        }
        }
    }


    @IBOutlet weak var BodiesContainer: UIView!
    @IBOutlet weak var SpaceView: UIView!
    @IBOutlet weak var Controls: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTimer()
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
                imageView.delegate = self
                view.addSubview(imageView)
                frame = frame.offsetBy(dx: 0, dy: CGFloat(1.5 * h / 7))
            }
        }
        view.sendSubview(toBack: SpaceView)
    }
    
}



class SpaceCell: UICollectionViewCell {
    
    static let planetImages: [String: UIImage] = ["Planets":#imageLiteral(resourceName: "Earth for app"), "Asteroids": #imageLiteral(resourceName: "asteroid for app"), "Suns": #imageLiteral(resourceName: "Sun Image For App"), "Neutrons":#imageLiteral(resourceName: "Neutron For app"), "Blackholes":#imageLiteral(resourceName: "Screen Shot 2017-03-20 at 8.48.13 PM")]
    
    static let planetMasses: [String: Double] = ["Planets":6E24, "Asteroids": 2E10, "Suns": 2E35, "Neutrons":3E35, "Blackholes":1E45]
    
    static let planetRadius: [String: Double] = ["Planets":6.371E6, "Asteroids": 2E3, "Suns": 695.7E6, "Neutrons":10E3, "Blackholes":13.5E3]
}

protocol ViewDragDelegate: class{
    
    func handleBegin(_ view: DraggableImageView, inLegalZone: Bool)
    func handleEnd(_ view: DraggableImageView, inLegalZone: Bool, finalVelocity: Vector2D)
    
}

extension Dictionary where Value: Equatable {
    func keysForValue(value: Value) -> Key? {
        return filter{$1 == value}.first?.key
        }
    }





