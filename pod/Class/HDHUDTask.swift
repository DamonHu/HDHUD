//
//  HDHUDTask.swift
//  HDHUD
//
//  Created by Damon on 2021/7/12.
//

import Foundation
import UIKit

public enum HDHUDTaskType {
    case text
    case progress
    case custom
}

open class HDHUDTask: NSObject {
    public var taskType = HDHUDTaskType.text
    public var duration: TimeInterval = 2.5
    public var superView: UIView?
    public var mask = false
    public var priority = HDHUDPriority.high
    public var contentView: UIView = UIView()
    public var didAppear: (()->Void)? = nil
    public var completion: (()->Void)? = nil

    init(taskType: HDHUDTaskType = .text, duration: TimeInterval = 2.5, superView: UIView? = nil, mask: Bool = false, priority: HDHUDPriority = .high, contentView: UIView = UIView(), didAppear: (()->Void)? = nil, completion: (()->Void)? = nil) {

        self.taskType = taskType
        self.duration = duration
        self.superView = superView
        self.mask = mask
        self.priority = priority
        self.contentView = contentView
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
