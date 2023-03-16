//
//  TopBannerViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-03-04.
//

import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Turf
import MapKit
import MapboxSearchUI

class TopBanner: ContainerViewController {
    var previouslySentDistance : String!

    var bluetoothModel = BluetoothModel()

    
    init(bluetooth: BluetoothModel) {
        self.bluetoothModel = bluetooth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private lazy var instructionsBannerTopOffsetConstraint = {
    return instructionsBannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
    }()
    private lazy var centerOffset: CGFloat = calculateCenterOffset(with: view.bounds.size)
    private lazy var instructionsBannerCenterOffsetConstraint = {
    return instructionsBannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
    }()
    private lazy var instructionsBannerWidthConstraint = {
    return instructionsBannerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
    }()

    lazy var instructionsBannerView: InstructionsBannerView = {
    let banner = InstructionsBannerView()
    banner.translatesAutoresizingMaskIntoConstraints = false
    banner.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    banner.layer.cornerRadius = 25
    banner.layer.opacity = 0.75
    banner.separatorView.isHidden = true
    return banner
    }()

    override func viewDidLoad() {
        view.addSubview(instructionsBannerView)
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    updateConstraints()
    }

    private func setupConstraints() {
    instructionsBannerCenterOffsetConstraint.isActive = true
    instructionsBannerTopOffsetConstraint.isActive = true
    instructionsBannerWidthConstraint.isActive = true
    }

    private func updateConstraints() {
    instructionsBannerCenterOffsetConstraint.constant = centerOffset
    }

    private func calculateCenterOffset(with size: CGSize) -> CGFloat {
    return (size.height < size.width ? -size.width / 5 : 0)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    centerOffset = calculateCenterOffset(with: size)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateConstraints()
    }

    public func distancePrep(dist : String)
    {
        if dist != previouslySentDistance
        {
            let distArr1 = dist.components(separatedBy: .whitespaces)
            var distArr2 = distArr1
            
            if (distArr1[1] == "km")
            {
                let value = Double(distArr1[0])
                let value_formatted = String(format: "%.1f", value!)
                distArr2 = [value_formatted, distArr1[1]]
            }
            
            let distance = distArr2.joined()

            if(distance != "1000m")
            {
                self.bluetoothModel.sendToRPI(flag: "d:", data: distance)
                previouslySentDistance = dist
            }
        }
    }

    public func iconPrep(typeOfDirection : String, typeOfManeuver : String)
    {
        var direction = ""
        var instruction = ""

        switch typeOfDirection
        {
        case "sharp right":
            direction = "right"

        case "right":
            direction = "right"

        case "slight right":
            direction = "right"

        case "straight ahead":
            direction = "forward"

        case "slight left":
            direction = "left"

        case "sharp left":
            direction = "left"

        case "left":
            direction = "left"

        case "uturn":
            direction = "uturn"

        default:
            direction = "forward"
        }

        switch typeOfManeuver
        {
        case "depart":
            instruction = "depart"

        case "turn":
            instruction = direction

        case "continue":
            instruction = "forward"

        case "new name":
            instruction = direction

        case "merge":
            instruction = direction

        case "on ramp":
            instruction = direction

        case "off ramp":
            instruction = direction

        case "fork":
            instruction = direction

        case "end of road":
            instruction = direction

        case "use lane":
            instruction = direction

        case "roundabout":
            instruction = direction

        case "rotary":
            instruction = direction

        case "roundabout turn":
            instruction = direction

        case "exit roundabout":
            instruction = direction

        case "exit rotary":
            instruction = direction

        case "notification":
            instruction = "warning"

        case "arrive":
            instruction = "arrive"

        default:
            instruction = "forward"
        }

        self.bluetoothModel.sendToRPI(flag: "n:", data: instruction)
    }

    public func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        instructionsBannerView.updateDistance(for: progress.currentLegProgress.currentStepProgress)
        distancePrep(dist: instructionsBannerView.distanceLabel.text ?? "default")
    }

    public func navigationService(_ service: NavigationService, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        instructionsBannerView.update(for: instruction)


        iconPrep(typeOfDirection: instruction.primaryInstruction.maneuverDirection?.rawValue ?? "default", typeOfManeuver: instruction.primaryInstruction.maneuverType?.rawValue ?? "default")

    }

    public func navigationService(_ service: NavigationService, didRerouteAlong route: MapboxDirections.Route, at location: CLLocation?, proactive: Bool) {
    instructionsBannerView.updateDistance(for: service.routeProgress.currentLegProgress.currentStepProgress)
    }
}


