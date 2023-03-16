//
//  SheetTableViewCell.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-01-26.
//
import UIKit

class RouteTableViewCell: UITableViewCell {
    

    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var StartRoute: UIButton!
    
    var cellIndex: IndexPath?
    
    static let identifier = "RouteTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "RouteTableViewCell", bundle: nil)
    }
    
    public func configure(distance: String, time: String) {
        StartRoute.backgroundColor = UIColor.green
        StartRoute.layer.cornerRadius = 5
        StartRoute.layer.borderWidth = 1
        StartRoute.setTitleColor(.white, for: .normal)
        StartRoute.addTarget(self, action: #selector(startedNavigation(sender:)), for: .touchUpInside)
        StartRoute.setTitle("Start Navigation", for: .normal)
        DistanceLabel.text = distance
        TimeLabel.text = time
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    fileprivate func animateView(_ viewToAnimate:UIView)
    {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)},completion: nil)
        }
    }
    
    @objc func startedNavigation(sender: UIButton)
    {
        NotificationCenter.default.post(name: Notification.Name("navigationButtonClicked"), object: nil, userInfo: ["instructions": cellIndex?.row as Any])
    }
    
}
