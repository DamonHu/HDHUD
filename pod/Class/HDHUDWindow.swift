//
//  HDHUDWindow.swift
//  HDHUD
//
//  Created by Damon on 2025/10/10.
//

import UIKit

class HDHUDWindow: UIWindow {
    static let shared = HDHUDWindow()
    
    private override init(frame: CGRect = UIScreen.main.bounds) {
        super.init(frame: frame)
        self.windowLevel = .alert + 1  // 高于普通界面
        self.backgroundColor = .clear
        self.rootViewController = HDHUDTaskViewController()
        self.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
