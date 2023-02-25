//
//  StatusViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-24.
//

import UIKit

class StatusViewController: UIViewController {

    @IBOutlet weak var DeviceName: UILabel!
    @IBOutlet weak var DisconnectButton: UIButton!
    
    var pulsating : CAShapeLayer!
    var inner: CAShapeLayer!

    let imageCircle = UIImageView(frame: CGRectMake(0, 0, 270, 270))

    let logoCircle = UIImageView(frame: CGRectMake(0, 0, 325, 46))
        
    let backgroundColor = UIColor(red: 21/255, green: 22/255, blue: 33/255, alpha: 1)
    let notConnectedInnerStrokeColor = UIColor(red: 234/255, green: 46/255, blue: 111/255, alpha: 1)
    let notConnectedPulsatingFillColor = UIColor(red: 86/255, green: 30/255, blue: 63/255, alpha: 1)
    let connectedInnerStrokeColor = UIColor(red: 90/255, green: 255/255, blue: 21/255, alpha: 1)
    let connectedPulsatingFillColor = UIColor(red: 95/255, green: 173/255, blue: 86/255, alpha: 1)
    
    private func notifObservations() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothConnected(notification:)), name: Notification.Name("BluetoothConnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(confirmedBluetoothDisconnect), name: Notification.Name("BluetoothConfirmedDisconnected"), object: nil)
    }
    
    @objc private func handleForeground() {
        animatePulsating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
        animatePulsating()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notifObservations()
        
        

        
        
        self.view.backgroundColor = backgroundColor
        


        DeviceName.textColor = .white
        DeviceName.text = "Not Connected!"
        DeviceName.font = UIFont.systemFont(ofSize: 25)
        
        DisconnectButton.tintColor = notConnectedInnerStrokeColor
        DisconnectButton.addTarget(self, action: #selector(disconnectBluetooth), for: UIControl.Event.touchUpInside)
        DisconnectButton.isEnabled = false //change to false
        DisconnectButton.setTitle("Disconnect Bluetooth", for: .normal) // sets text
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 140, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        pulsating = CAShapeLayer()
        pulsating.path = circularPath.cgPath
        pulsating.strokeColor = UIColor.clear.cgColor
        //pulsating.lineWidth = 10 //don't need this
        pulsating.fillColor = notConnectedPulsatingFillColor.cgColor//this
        pulsating.lineCap = CAShapeLayerLineCap.round
        pulsating.position = view.center
        view.layer.addSublayer(pulsating)
        animatePulsating()
        
        inner = CAShapeLayer()
        inner.path = circularPath.cgPath
        inner.lineCap = CAShapeLayerLineCap.round
        inner.position = view.center
        
        inner.strokeColor = notConnectedInnerStrokeColor.cgColor
        inner.lineWidth = 12.5 //this
        inner.fillColor = backgroundColor.cgColor //this
        view.layer.addSublayer(inner)

        imageCircle.image =  UIImage(named: "logo_inv")
        imageCircle.layer.cornerRadius = imageCircle.frame.size.height/2
        imageCircle.layer.borderColor = UIColor.clear.cgColor
        imageCircle.clipsToBounds = true
        imageCircle.center = view.convert(view.center, from: view)
        view.addSubview(imageCircle)

        
        logoCircle.image =  UIImage(named: "Untitled")
        logoCircle.clipsToBounds = true
        let t = CGPoint(x: view.center.x, y: view.center.y - 250)
        logoCircle.center = t
        view.addSubview(logoCircle)
    }
    
    private func animatePulsating() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 0.98
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsating.add(animation, forKey: "pulsing")
    }
    
    @objc private func disconnectBluetooth() {
        NotificationCenter.default.post(name: Notification.Name("Bluetooth Disconnect Request"), object: nil)
    }
    
    @objc private func bluetoothConnected(notification: Notification) {
        print("THIS IS A CONNECTION")
        if let instruction = notification.userInfo?["instructions"] as? String {
            inner.strokeColor = connectedInnerStrokeColor.cgColor
            pulsating.fillColor = connectedPulsatingFillColor.cgColor//this
            DisconnectButton.isEnabled = true
            DeviceName.text = instruction
        }
    }
    
    @objc private func confirmedBluetoothDisconnect() {
        inner.strokeColor = notConnectedInnerStrokeColor.cgColor
        pulsating.fillColor = notConnectedPulsatingFillColor.cgColor//this
        DisconnectButton.isEnabled = false
        DeviceName.text = "Not Connected!"
    }
    



}
