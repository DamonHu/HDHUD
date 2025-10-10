//
//  HDHUD.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit

public enum HDHUDIconType {
    case none
    case warn
    case error
    case success
    case loading
}

public enum HDHUDContentDirection {
    case vertical
    case horizontal
}

//
public enum HDHUDDisplayPosition {
    case top
    case center
    case bottom
    case navigationBarMask
    case tabBarMask
}

public enum HDHUDDisplayTypee {
    case single
    case sequence
}

func UIImageHDBoundle(named: String?) -> UIImage? {
    guard let name = named else { return nil }
    guard let bundlePath = Bundle(for: HDHUD.self).path(forResource: "HDHUD", ofType: "bundle") else { return UIImage(named: name) }
    let bundle = Bundle(path: bundlePath)
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}

func URLPathHDBoundle(named: String?) -> String? {
    guard let name = named else { return "" }
    guard let bundlePath = Bundle(for: HDHUD.self).path(forResource: "HDHUD", ofType: "bundle") else { return Bundle.main.path(forResource: name, ofType: "") }
    let filePath = Bundle(path: bundlePath)?.path(forResource: name, ofType: "")
    return filePath
}

open class HDHUD {
    public static var displayPosition: HDHUDDisplayPosition = .top
    public static var displayType: HDHUDDisplayTypee = .sequence
    ///images
    public static var warnImage = UIImageHDBoundle(named: "ic_warning")
    public static var warnImageSize = CGSize(width: 24, height: 24)
    public static var errorImage = UIImageHDBoundle(named: "ic_error")
    public static var errorImageSize = CGSize(width: 24, height: 24)
    public static var successImage = UIImageHDBoundle(named: "ic_success")
    public static var successImageSize = CGSize(width: 24, height: 24)
    public static var loadingImage = getLoadingImage()
    public static var loadingImageSize = CGSize(width: 18, height: 18)
    ///color and text
    public static var contentBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    public static var backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    public static var textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.00)
    public static var textFont = UIFont.systemFont(ofSize: 16)
    public static var contentOffset = CGPoint.zero
    public static var progressTintColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.00)
    public static var trackTintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.00)
    public static var isShowCloseButton = false
    public static var isUserInteractionEnabled = false
    //private members
    private static var sequenceTask = [HDHUDTask]()
    static let shared = HDHUD()
}

//MARK: Public Method
public extension HDHUD {
    /// display HUD
    /// - Parameters:
    ///   - content: content text
    ///   - icon: icon type
    ///   - direction: Layout direction of icon and text
    ///   - duration: specifies the time when the HUD is automatically turned off, `-1` means not to turn off automatically
    ///   - didAppear: callback after the HUD is appear
    ///   - completion: callback after the HUD is closed
    @discardableResult
    static func show(_ content: String? = nil, icon: HDHUDIconType = .none, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 3.5, didAppear: (()->Void)? = nil, completion: (()->Void)? = nil) -> HDHUDTask {
        //创建任务
        let task = HDHUDTask(taskType: .text, duration: duration, didAppear: didAppear, completion: completion)
        //显示的页面
        task.contentView = HDHUDLabelContentView(content: content, icon: icon, direction: direction)
        //展示
        self.show(task: task)
        return task
    }

    //display progress hud
    @discardableResult
    static func showProgress(_ progress: Float, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 6, didAppear: (()->Void)? = nil, completion: (()->Void)? = nil) -> HDHUDProgressTask {
        let task = HDHUDProgressTask(taskType: .progress, duration: duration, didAppear: didAppear, completion: completion)
        //显示的页面
        task.contentView = HDHUDProgressContentView(direction: direction)
        task.progress = progress
        //展示
        self.show(task: task)
        return task
    }

    //display customview
    @discardableResult
    static func show(customView: UIView, duration: TimeInterval = 3.5, didAppear: (()->Void)? = nil, completion: (()->Void)? = nil) -> HDHUDTask {
        //创建任务
        let task = HDHUDTask(taskType: .custom, duration: duration, didAppear: didAppear, completion: completion)
        //显示的页面
        task.contentView = customView
        //展示
        self.show(task: task)
        return task
    }

    //display use task
    static func show(task: HDHUDTask) {
        self._show(task: task)
    }

    static func hide(task: HDHUDTask? = nil, animation: Bool = true) {
        self._hide(task: task, animation: animation)
    }
}

///MARK: Private Method
private extension HDHUD {
    static func _show(task: HDHUDTask) {
        if self.displayType == .single {
            self._hide(animation: false)
        }
        self.sequenceTask.append(task)
        task.isVisible = true
        guard let taskContentVC = HDHUDWindow.shared.rootViewController as? HDHUDTaskViewController else { return  }
        //视图
        let contentView = task.contentView
        if self.isShowCloseButton && task.duration == -1 && self.isUserInteractionEnabled {
            let closeButton = UIButton(type: .custom)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.isHidden = true
            closeButton.backgroundColor = HDHUD.contentBackgroundColor
            closeButton.layer.masksToBounds = true
            closeButton.layer.cornerRadius = 8
            closeButton.setImage(UIImageHDBoundle(named: "icon_close"), for: .normal)
            closeButton.addTarget(shared, action: #selector(_onClickCloseButton), for: .touchUpInside)
            contentView.addSubview(closeButton)
            closeButton.centerXAnchor.constraint(equalTo: contentView.rightAnchor, constant: -2).isActive = true
            closeButton.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
            closeButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
            closeButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
            task.closeButton = closeButton
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if let taskCloseButton = task.closeButton {
                    taskCloseButton.isHidden = false
                }
            }
        }
        taskContentVC.showToast(contentView: task.contentView)
        if let didAppear = task.didAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                didAppear()
            }
        }
        if task.duration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + task.duration) {
                self._hide(task: task)
            }
        }
    }
    
    static func _hide(task: HDHUDTask? = nil, animation: Bool = true) {
        guard let taskContentVC = HDHUDWindow.shared.rootViewController as? HDHUDTaskViewController else { return  }
        if let task = task {
            task.isVisible = false
            //还在序列中未展示的任务
            if let index = self.sequenceTask.firstIndex(of: task) {
                task.closeButton?.removeFromSuperview()
                self.sequenceTask.remove(at: index)
            }
            if let completion = task.completion {
                completion()
            }
            taskContentVC.hideToast(contentView: task.contentView, animation: animation)
        } else {
            for task in self.sequenceTask {
                self._hide(task: task, animation: animation)
            }
        }
    }

    @objc func _onClickCloseButton() {
        HDHUD.hide()
    }
}

private extension HDHUD {
    static func getLoadingImage() -> UIImage? {
        var imageList = [UIImage]()
        for i in 0..<20 {
            if let image = UIImageHDBoundle(named: "loading_\(i).png") {
                imageList.append(image)
            }
        }

        return UIImage.animatedImage(with: imageList, duration: 0.6)
    }
}
