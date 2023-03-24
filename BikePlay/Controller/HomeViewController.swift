//
//  HomeViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-28.
//
// Pulsating Animation From: https://www.letsbuildthatapp.com/videos/2362
//

import UIKit

class HomeViewController: UIViewController {
    
    //Defining Shared Models
    var bluetoothModel = BluetoothModel()
                
    //Outlets
    @IBOutlet weak var deviceNameField: UILabel!
    
    //UI Variables
    var pulseLayer : CAShapeLayer!
    var innerRingLayer: CAShapeLayer!
    
    //UI Constants
    let wheelImage = UIImageView(frame: CGRectMake(0, 0, 270, 270))
    let logoImage = UIImageView(frame: CGRectMake(0, 0, 325, 46))
    let circularPath = UIBezierPath(arcCenter: .zero, radius: 140, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)

    //Notification Center
    let notificationCenter = NotificationCenter.default
    
    //UI Home Screen Colours
    let backgroundColor = UIColor(red: 21/255, green: 22/255, blue: 33/255, alpha: 1)
    let notConnectedInnerStrokeColor = UIColor(red: 234/255, green: 46/255, blue: 111/255, alpha: 1)
    let notConnectedPulsatingFillColor = UIColor(red: 86/255, green: 30/255, blue: 63/255, alpha: 1)
    let connectedInnerStrokeColor = UIColor(red: 90/255, green: 255/255, blue: 21/255, alpha: 1)
    let connectedPulsatingFillColor = UIColor(red: 95/255, green: 173/255, blue: 86/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(foregroundHandler), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let ancestralTabBarController = self.tabBarController  as! MainTabBarController
        bluetoothModel = ancestralTabBarController.bluetoothModel
            
        //Device Name Text Field Formatting
        deviceNameField.textColor = .white
        deviceNameField.text = "Not Connected!"
        deviceNameField.font = UIFont.systemFont(ofSize: 25)
        
        //Pulsation Animation Formatting
        pulseLayer = CAShapeLayer()
        pulseLayer.path = circularPath.cgPath
        pulseLayer.strokeColor = UIColor.clear.cgColor
        pulseLayer.fillColor = notConnectedPulsatingFillColor.cgColor//this
        pulseLayer.lineCap = CAShapeLayerLineCap.round
        pulseLayer.position = view.center
        view.layer.addSublayer(pulseLayer)
        startPulseAnimation()
        
        //Inner Ring Layer Formatting
        innerRingLayer = CAShapeLayer()
        innerRingLayer.path = circularPath.cgPath
        innerRingLayer.lineCap = CAShapeLayerLineCap.round
        innerRingLayer.position = view.center
        
        innerRingLayer.strokeColor = notConnectedInnerStrokeColor.cgColor
        innerRingLayer.lineWidth = 12.5 //this
        innerRingLayer.fillColor = backgroundColor.cgColor //this
        view.layer.addSublayer(innerRingLayer)

        //Wheel Logo Formatting
        wheelImage.image =  UIImage(named: "logo_inv")
        wheelImage.layer.cornerRadius = wheelImage.frame.size.height/2
        wheelImage.layer.borderColor = UIColor.clear.cgColor
        wheelImage.clipsToBounds = true
        wheelImage.center = view.convert(view.center, from: view)
        view.addSubview(wheelImage)

        //Logo Formatting
        logoImage.image =  UIImage(named: "logo_white-1")
        logoImage.clipsToBounds = true
        logoImage.center = CGPoint(x: view.center.x, y: view.center.y - 250)
        view.addSubview(logoImage)
    }
    
    //Update Logo On Tab Switch
    override func viewWillAppear(_ animated: Bool) {
        changeStatusUI()
    }
    
    //Continue Pulse Animation On Tab Switch
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
        startPulseAnimation()
    }
    
    //Continue Pulse Anmation On App Sleep and Reopen
    @objc private func foregroundHandler() {
        startPulseAnimation()
    }
    
    //Trigger UI Changes On BLE Connect
    @objc private func changeStatusUI(){
        if (bluetoothModel.connectedPeripheral == nil || bluetoothModel.connectedPeripheral?.state == .disconnected)
        {
            pulseLayer.fillColor = notConnectedPulsatingFillColor.cgColor//this
            innerRingLayer.strokeColor = notConnectedInnerStrokeColor.cgColor
            deviceNameField.text = "Not Connected!"
        }
        else
        {
            innerRingLayer.strokeColor = connectedInnerStrokeColor.cgColor
            pulseLayer.fillColor = connectedPulsatingFillColor.cgColor//this
            deviceNameField.text = bluetoothModel.connectedPeripheral?.name
        }
    }
    
    //Start Pulse Animation
    private func startPulseAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulseLayer.add(animation, forKey: "pulsing")
    }
    

    
}
