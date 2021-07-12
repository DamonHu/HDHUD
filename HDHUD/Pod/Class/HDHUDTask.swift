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

public struct HDHUDTask {
    public var taskType = HDHUDTaskType.text
    public var content: String?
    public var icon = HDHUDIconType.none
    public var direction = HDHUDContentDirection.horizontal
    public var duration: TimeInterval = 2.5
    public var superView: UIView?
    public var userInteractionOnUnderlyingViewsEnabled = true
    public var priority = HDHUDPriority.high
    public var progress: Float = 0
    public var commonView: UIView = UIView()
}
