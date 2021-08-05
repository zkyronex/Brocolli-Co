//
//  ShakeAnimation.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import UIKit

final class ShakeAnimation: CAKeyframeAnimation {

    override public init() {
        super.init()
        configureAnimator()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureAnimator()
    }

    public func configureAnimator() {
        keyPath = "position.x"
        values = [0, 15, -15, 15, -10, 10, -5, 5, 0]
        keyTimes = [0, 1.0 / 10.0, 3.0 / 10.0, 5.0 / 10.0, 6.0 / 10.0, 7.0 / 10.0, 8.0 / 10.0, 9.0 / 10.0, 1.0]
            .map({ value in
                NSNumber(value: value)
            })
        duration = 0.4
        isAdditive = true
    }
}
