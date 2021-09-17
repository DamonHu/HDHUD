//
//  HDHUD.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit
import ZXKitUtil

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



/**当页面正在展示toast，此时再调用显示模式，会根据优先级的设置进行展示。

 low： 已有toast在显示的情况下，该条提示不显示
 overlay: 该提示和当前在展示的toast同时叠加显示
 high：关闭当前在展示的toast，立即展示当前要显示的toast
 sequence: 当前展示的toast结束之后，展示本条即将显示的toast

 When the toast is being displayed on the page, the display mode will be called at this time to display according to the priority setting.

 low: this prompt will not be displayed when a toast is already displayed
 overlay: the prompt is superimposed with the toast currently displayed
 high: close the toast currently displayed and display the toast to be displayed
 sequence: display the toast to be displayed after the toast currently displayed
*/
public enum HDHUDPriority {
    case low
    case overlay
    case high
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
    ///images
    public static var warnImage = UIImageHDBoundle(named: "ic_warning")
    public static var warnImageSize = CGSize(width: 24, height: 24)
    public static var errorImage = UIImageHDBoundle(named: "ic_error")
    public static var errorImageSize = CGSize(width: 24, height: 24)
    public static var successImage = UIImageHDBoundle(named: "ic_success")
    public static var successImageSize = CGSize(width: 24, height: 24)
    public static var loadingImage = getLoadingImage()
    public static var loadingImageSize = CGSize(width: 48, height: 48)
    #if canImport(Kingfisher)
    //如果设置了`loadingImageURL`，加载图片将会优先使用URL资源
    // If `loadingImageURL` is set, the URL resource will be used preferentially when loading images
    public static var loadingImageURL: URL? = URL(fileURLWithPath: URLPathHDBoundle(named: "loading.gif") ?? "")
    #endif
    ///color and text
    public static var contentBackgroundColor = UIColor.zx.color(hexValue: 0x000000, alpha: 0.8)
    public static var backgroundColor = UIColor.zx.color(hexValue: 0x000000, alpha: 0.2) {
        willSet {
            self.shared.bgView.backgroundColor = newValue
        }
    }
    public static var textColor = UIColor.zx.color(hexValue: 0xFFFFFF)
    public static var textFont = UIFont.systemFont(ofSize: 16)
    public static var contentOffset = CGPoint.zero
    public static var progressTintColor = UIColor.zx.color(hexValue: 0xFF8F0C)
    public static var trackTintColor = UIColor.zx.color(hexValue: 0xFFFFFF)
    public static var isShowCloseButton = true
    //private members
    private static var prevTask: HDHUDTask?
    private static var sequenceTask = [HDHUDTask]()
    private let bgView = UIView()
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = HDHUD.contentBackgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.setImage(UIImageHDBoundle(named: "icon_close"), for: .normal)
        button.addTarget(self, action: #selector(_onClickCloseButton), for: .touchUpInside)
        return button
    }()
    static let shared = HDHUD()
    private static var mTimer: Timer? = nil
}

//MARK: Public Method
public extension HDHUD {


    /// display HUD
    /// - Parameters:
    ///   - content: content text
    ///   - icon: icon type
    ///   - direction: Layout direction of icon and text
    ///   - duration: specifies the time when the HUD is automatically turned off, `-1` means not to turn off automatically
    ///   - superView: the upper view of the HUD, the default is the current window
    ///   - mask: whether the bottom view responds when the hud pops up
    ///   - priority:  When the toast is being displayed on the page, the display mode will be called at this time to display according to the priority setting.
    ///   - didAppear: callback after the HUD is appear
    ///   - completion: callback after the HUD is closed
    @discardableResult
    static func show(_ content: String? = nil, icon: HDHUDIconType = .none, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 2.5, superView: UIView? = nil, mask: Bool = false, priority: HDHUDPriority = .high, didAppear: (()->Void)? = nil, completion: (()->Void)? = nil) -> HDHUDTask {
        //创建任务
        let task = HDHUDTask(taskType: .text, duration: duration, superView: superView, mask: mask, priority: priority, didAppear: didAppear, completion: completion)
        if Thread.isMainThread {
            //显示的页面
            task.contentView = HDHUDLabelContentView(content: content, icon: icon, direction: direction)
            //展示
            self.show(task: task)
        } else {
            DispatchQueue.main.async {
                //显示的页面
                task.contentView = HDHUDLabelContentView(content: content, icon: icon, direction: direction)
                //展示
                self.show(task: task)
            }
        }
        return task
    }

    //display progress hud
    @discardableResult
    static func showProgress(_ progress: Float, direction: HDHUDContentDirection = .horizontal, superView: UIView? = nil, mask: Bool = false, priority: HDHUDPriority = .high, didAppear: (()->Void)? = nil, completion: (()->Void)? = nil) -> HDHUDProgressTask {
        let task = HDHUDProgressTask(taskType: .progress, duration: -1, superView: superView, mask: mask, priority: priority, didAppear: didAppear, completion: completion)
        if Thread.isMainThread {
            //显示的页面
            task.contentView = HDHUDProgressContentView(direction: direction)
            task.progress = progress
            //展示
            self.show(task: task)
        } else {
            DispatchQueue.main.async {
                //显示的页面
                task.contentView = HDHUDProgressContentView(direction: direction)
                task.progress = progress
                //展示
                self.show(task: task)
            }
        }
        return task
    }

    //display customview
    @discardableResult
    static func show(customView: UIView, duration: TimeInterval = 2.5, superView: UIView? = nil, mask: Bool = false, priority: HDHUDPriority = .high, didAppear: (()->Void)? = nil, completion: (()->Void)? = nil) -> HDHUDTask {
        //创建任务
        let task = HDHUDTask(taskType: .custom, duration: duration, superView: superView, mask: mask, priority: priority, didAppear: didAppear, completion: completion)
        if Thread.isMainThread {
            //显示的页面
            task.contentView = customView
            //展示
            self.show(task: task)
        } else {
            DispatchQueue.main.async {
                //显示的页面
                task.contentView = customView
                //展示
                self.show(task: task)
            }
        }
        return task
    }

    //display use task
    static func show(task: HDHUDTask) {
        //展示
        if Thread.isMainThread {
            if task.taskType == .progress {
                self._showProgress(task: task as! HDHUDProgressTask)
            } else {
                self._show(task: task)
            }
        } else {
            DispatchQueue.main.async {
                if task.taskType == .progress {
                    self._showProgress(task: task as! HDHUDProgressTask)
                } else {
                    self._show(task: task)
                }
            }
        }
    }

    static func hide(task: HDHUDTask? = nil) {
        if Thread.isMainThread {
            self._hide(task: task, autoNext: true)
        } else {
            DispatchQueue.main.async {
                self._hide(task: task, autoNext: true)
            }
        }
    }


    /// clear and hide all HUDs, including undescending in the sequence
    /// - Parameter completeValid: Whether to call back the task completion when the hud in the sequence is cleared
    static func clearAll(completeValid: Bool = false) {
        if completeValid {
            for task in self.sequenceTask {
                if let completion = task.completion {
                    completion()
                }
            }
        }
        self.sequenceTask.removeAll()
        if Thread.isMainThread {
            self._hide(task: nil, autoNext: false)
        } else {
            DispatchQueue.main.async {
                self._hide(task: nil, autoNext: false)
            }
        }
    }
}

///MARK: Private Method
private extension HDHUD {
    static func _show(task: HDHUDTask) {
        //根据下次即将显示的类型进行清理
        if prevTask != nil {
            switch task.priority {
            case .low:
                //当前有显示，忽略掉不显示
                if let completion = task.completion {
                    completion()
                }
                return
            case .overlay:
                //重叠显示
                break
            case .high:
                //移除当前显示
                self._hide(task: prevTask, autoNext: false)
            case .sequence:
                //添加到序列
                self.sequenceTask.append(task)
                return
            }
        }
        self._showView(task: task)
        //设置当前正在显示的hud类型
        if task.duration > 0 {
            if mTimer != nil {
                mTimer?.invalidate()
                mTimer = nil
            }
            mTimer = Timer(fire: Date(timeIntervalSinceNow: task.duration), interval: 0, repeats: false) { (timer) in
                //自动关闭当前显示
                self._hide(task: task, autoNext: true)
            }
            RunLoop.main.add(mTimer!, forMode: .common)
        }
    }
    
    static func _showProgress(task: HDHUDProgressTask) {
        //当前正在显示的就是进度条，直接更新进度
        if let prevTask = prevTask, prevTask.taskType == .progress {
            let contentView = prevTask.contentView as! HDHUDProgressContentView
            contentView.progress = task.progress
        } else {
            if prevTask != nil {
                switch task.priority {
                case .low:
                    if let completion = task.completion {
                        completion()
                    }
                    //当前有显示，忽略掉不显示
                    return
                case .overlay:
                    //重叠显示
                    break
                case .high:
                    //直接显示
                    self._hide(task: prevTask, autoNext: false)
                case .sequence:
                    //添加到序列，稍后再显示
                    self.sequenceTask.append(task)
                    return
                }
            }
            let contentView = task.contentView as! HDHUDProgressContentView
            contentView.progress = task.progress
            self._showView(task: task)
        }
    }
    
    static func _hide(task: HDHUDTask? = nil, autoNext: Bool = true) {
        if let task = task, self.sequenceTask.contains(task) {
            //还在序列中未展示的任务
            if let index = self.sequenceTask.firstIndex(of: task) {
                self.sequenceTask.remove(at: index)
            }
            if let completion = task.completion {
                completion()
            }
        } else {
            //未指定，或者是正在显示task
            if task == nil || task == prevTask {
                if mTimer != nil {
                    mTimer?.invalidate()
                    mTimer = nil
                }
                for view in shared.bgView.subviews {
                    view.removeFromSuperview()
                }
                shared.bgView.removeFromSuperview()
                shared.closeButton.removeFromSuperview()
                if let prev = prevTask, let completion = prev.completion {
                    completion()
                }
                prevTask = nil
            } else {
                print("task invalid")
                return
            }
        }
        if autoNext, let prepareTask = sequenceTask.first {
            sequenceTask.removeFirst()
            if prepareTask.taskType == .progress {
                self._showProgress(task: prepareTask as! HDHUDProgressTask)
            } else {
                self._show(task: prepareTask)
            }
        }
    }

    static func _showView(task: HDHUDTask) {
        assert(task.contentView != nil, "HDHUD contentView is nil")
        guard let view = task.contentView else { return }
        //阻止点击
        shared.bgView.isUserInteractionEnabled = task.mask
        //show new view
        var tmpSuperView = task.superView
        if tmpSuperView == nil {
            tmpSuperView = ZXKitUtil.shared.getCurrentNormalWindow()
        }
        guard let tSuperView = tmpSuperView else { return }
        shared.bgView.backgroundColor = self.backgroundColor
        tSuperView.addSubview(shared.bgView)
        shared.bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        shared.bgView.insertSubview(view, at: 0)
        if isShowCloseButton && task.duration < 0 {
            self._addPopAnimation(view: shared.closeButton)
            tSuperView.addSubview(shared.closeButton)
            shared.closeButton.snp.makeConstraints { make in
                make.centerX.equalTo(view.snp.right).offset(-2)
                make.centerY.equalTo(view.snp.top).offset(2)
                make.width.height.equalTo(16)
            }
        }

        if view.frame.size.width > 0 || view.frame.size.height > 0 {
            view.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(contentOffset.x)
                make.centerY.equalToSuperview().offset(contentOffset.y)
                make.width.equalTo(view.frame.size.width)
                make.height.equalTo(view.frame.size.height)
            }
        } else {
            view.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview().offset(contentOffset.x)
                make.centerY.equalToSuperview().offset(contentOffset.y)
            }
        }
        self._addPopAnimation(view: task.contentView)
        prevTask = task
        //回调
        if let didAppear = task.didAppear {
            didAppear()
        }
    }

    static func _addPopAnimation(view: UIView?) {
        guard let view = view else { return }
        //动态弹出
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 1))
        scaleAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1))
        scaleAnimation.isCumulative = false
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.isCumulative = false
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let group = CAAnimationGroup()
        group.duration = 0.5
        group.isRemovedOnCompletion = false
        group.repeatCount = 1
        group.fillMode = CAMediaTimingFillMode.forwards
        group.animations = [scaleAnimation, opacityAnimation]
        view.layer.add(group, forKey: "scale")
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
