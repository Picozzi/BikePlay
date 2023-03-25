//
//  AppSettingTableViewCell.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-24.
//
//  Cell Layout From https://www.youtube.com/watch?v=2FigkAlz1Bg
//

import UIKit

class AppSettingTableViewCell: UITableViewCell {
    
    static let identifier = "AppSettingTableViewCell"
    
    let iconContainer : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size : CGFloat = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 10, y: 6, width: size, height: size)
        
        let imageSize : CGFloat = size/1.5
        let image_x : CGFloat = (iconContainer.frame.size.width-imageSize)/2
        let image_y : CGFloat = (iconContainer.frame.size.height-imageSize)/2
        
        iconImageView.frame = CGRect(x: image_x, y: image_y, width: imageSize, height: imageSize)
        
        let label_x : CGFloat = 25 + iconContainer.frame.size.width
        let label_y : CGFloat = 0
        let label_width : CGFloat = contentView.frame.size.width - 15 - iconContainer.frame.size.width - 10
        let label_height : CGFloat = contentView.frame.size.height

        label.frame = CGRect(x: label_x, y: label_y, width: label_width, height: label_height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
    }
    
//    public func configure(with model: SettingsOption) {
//        label.text = model.title
//        iconImageView.image = model.icon
//        iconContainer.backgroundColor = model.iconBackgroundColor
//    }
}
