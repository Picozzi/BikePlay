////
////  SheetTableViewCell.swift
////  BikePlay
////
////  Created by Matthew Picozzi on 2023-01-26.
////
//
//import UIKit
//
//class SheetTableViewCell: UITableViewCell {
//    
//    @IBOutlet weak var RouteButton: UIButton!
//    @IBOutlet weak var NameLabel: UILabel!
//    @IBOutlet weak var DistanceLabel: UILabel!
//    @IBOutlet weak var ETALabel: UILabel!
//    
//    var delegate: ClickDelegate?
//    var cellIndex: IndexPath?
//   
//    @objc func buttonAction(sender: UIButton)
//    {
//        delegate?.clicked(cellIndex!.row)
//        self.animateView(sender)
//    }
//    
//    static let identifier = "SheetTableViewCell"
//    
//    static func nib() -> UINib {
//        return UINib(nibName: "SheetTableViewCell", bundle: nil)
//    }
//    
//    public func configure(with title: String, ETA: String, distance: String) {
//        RouteButton.tintColor = UIColor.green
//        RouteButton.addTarget(self, action: #selector(buttonAction), for: UIControl.Event.touchUpInside)
//        NameLabel.text = title
//        ETALabel.text = ETA
//        DistanceLabel.text = distance
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//    
//    fileprivate func animateView(_ viewToAnimate:UIView)
//    {
//        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
//            
//            viewToAnimate.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
//        }) { (_) in
//            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)},completion: nil)
//        }
//    }
//    
//}
