//
//  Design.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import UIKit

extension UIColor {

    static var background = #colorLiteral(red: 0.7568627451, green: 0.6588235294, blue: 0.8941176471, alpha: 1)
    static var secondary = #colorLiteral(red: 0.1058823529, green: 0.2274509804, blue: 0.2039215686, alpha: 1)
    static var primary = #colorLiteral(red: 0.4, green: 0.7882352941, blue: 0.3803921569, alpha: 1)
    static var separator = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
}

extension CGFloat {

    static func layout(_ layout: Layout) -> CGFloat {
        layout.rawValue
    }

    static func size(_ size: Size) -> CGFloat {
        size.rawValue
    }
}

enum Layout: CGFloat {

    case inner = 20
    case outer = 36
    case section = 60
    case corner = 10
}

enum Size: CGFloat {

    case buttonWidth = 220
    case buttonHeight = 56
    case textFieldHeight = 54
}
