//
//  Settings.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-03-24.
//

import Foundation
import UIKit

public struct SettingSections {
    let title : String
    let cells : [SettingCell]
}

public enum CellType {
    case normalCell
    case toggleCell
    
}

public struct SettingCell {
    let title : String
    let icon: UIImage?
    let iconBackgroundColor : UIColor
    var isOn: Bool
    let type : CellType
    let handler : (() -> Void)
}


