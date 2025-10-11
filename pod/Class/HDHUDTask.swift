//
//  HDHUDTask.swift
//  HDHUD
//
//  Created by Damon on 2021/7/12.
//

import Foundation
import UIKit

open class HDHUDTask: NSObject {
    public var didAppear: (()->Void)? = nil
    public var completion: (()->Void)? = nil
    public var isVisible: Bool = false
    
    var duration: TimeInterval = 2.5
    var contentView: UIView = UIView()
    var closeButton: UIButton?

    init(duration: TimeInterval = 2.5, didAppear: (()->Void)? = nil, completion: (()->Void)? = nil) {
        self.duration = duration
        self.didAppear = didAppear
        self.completion = completion
        super.init()
    }
}

open class HDHUDProgressTask: HDHUDTask {
    public var progress: Float = 0 {
        willSet {
            if let contentView = self.contentView as? HDHUDProgressContentView {
                contentView.progress = newValue
            }
        }
    }
}
