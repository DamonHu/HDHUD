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

///当页面正在展示toast，此时再调用显示模式，会根据优先级的设置进行展示。
///low： 已有toast在显示的情况下，该条提示不显示
///overlay: 该提示和之前的toast同时叠加显示
///high：关闭toast，展示当前要显示的toast
///When the page is displaying toast, the loading display is called, and it will be displayed according to the priority setting.
///Low: loading is not displayed, only toast is displayed
///Common: loading and toast are superimposed at the same time
///High: close toast and show loading
public enum HDHUDPriority {
    case low
    case overlay
    case high
    case sequence
}

open class HDHUD {
    ///images
    public static var warnImage = UIImageHDBoundle(named: "ic_warning")
    public static var warnImageSize = CGSize(width: 24, height: 24)
    public static var errorImage = UIImageHDBoundle(named: "ic_error")
    public static var errorImageSize = CGSize(width: 24, height: 24)
    public static var successImage = UIImageHDBoundle(named: "ic_success")
    public static var successImageSize = CGSize(width: 24, height: 24)
    public static var loadingImageURL = URL(fileURLWithPath: URLPathHDBoundle(named: "loading.gif")!)
    public static var loadingImageSize = CGSize(width: 48, height: 48)

    ///color and text
    public static var contentBackgroundColor = UIColor.zx.color(hexValue: 0x000000, alpha: 0.8)
    public static var backgroundColor = UIColor.zx.color(hexValue: 0x000000, alpha: 0.3) {
        willSet {
            self.bgView.backgroundColor = newValue
        }
    }
    public static var textColor = UIColor.zx.color(hexValue: 0xFFFFFF)
    public static var textFont = UIFont.systemFont(ofSize: 16)
    public static var contentOffset = CGPoint.zero
    public static var progressTintColor = UIColor.zx.color(hexValue: 0xFF8F0C)
    public static var trackTintColor = UIColor.zx.color(hexValue: 0xFFFFFF)

    //private members
    private static var prevIconType: HDHUDIconType?
    private static let bgView = UIView()
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
    ///   - userInteractionOnUnderlyingViewsEnabled: whether the bottom view responds when the hud pops up
    ///   - completion: callback after the HUD is automatically closed, if `duration` is set to -1, it will not be called
    static func show(_ content: String? = nil, icon: HDHUDIconType = .none, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, priority: HDHUDPriority, completion: (()->Void)? = nil) {
        if Thread.isMainThread {
            self._show(content, icon: icon, direction: direction, duration: duration, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled, completion: completion)
        } else {
            DispatchQueue.main.async {
                self._show(content, icon: icon, direction: direction, duration: duration, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled, completion: completion)
            }
        }
    }

    static func showProgress(_ progress: Float, direction: HDHUDContentDirection = .horizontal, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true) {
        if Thread.isMainThread {
            self._showProgress(progress, direction: direction, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled)
        } else {
            DispatchQueue.main.async {
                self._showProgress(progress, direction: direction, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled)
            }
        }
    }
    
    static func show(commonView: UIView, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        if Thread.isMainThread {
            self._show(commonView: commonView, duration: duration, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled, completion: completion)
        } else {
            DispatchQueue.main.async {
                self._show(commonView: commonView, duration: duration, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled, completion: completion)
            }
        }
    }

    static func hide(type: HDHUDIconType? = nil) {
        if Thread.isMainThread {
            self._hide(type: type)
        } else {
            DispatchQueue.main.async {
                self._hide(type: type)
            }
        }
    }
}

///MARK: Private Method
private extension HDHUD {
    static func _show(_ content: String? = nil, icon: HDHUDIconType = .none, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        //根据下次即将显示的类型进行清理
        if icon == .loading, let prevIconType = prevIconType, prevIconType != .loading {
            switch self.loadingPriority {
                case .low:
                    //当前有显示，下次即将显示loading，忽略掉
                    return
                case .common:
                    //重叠显示
                    break
                case .high:
                    //优先显示
                    HDHUD.hide()
            }
        } else {
            HDHUD.hide()
        }
        bgView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
        let contentView = HDHUDLabelContentView(content: content, icon: icon, direction: direction)
        self._showView(view: contentView, superView: superView)
        self._addPopAnimation(view: contentView)
        //设置当前正在显示的hud类型
        if mCurrentIconType == nil {
            mCurrentIconType = icon
        }

        if duration > 0 {
            if mTimer != nil {
                mTimer?.invalidate()
                mTimer = nil
            }
            mTimer = Timer(fire: Date(timeIntervalSinceNow: duration), interval: 0, repeats: false) { (timer) in
                HDHUD.hide()
                if let completion = completion {
                    completion()
                }
            }
            RunLoop.main.add(mTimer!, forMode: .common)
        }
    }
    
    static func _showProgress(_ progress: Float, direction: HDHUDContentDirection = .horizontal, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true) {
        if let progressContentView = bgView.subviews.first as? HDHUDProgressContentView {
            progressContentView.progress = progress
        } else {
            HDHUD.hide()
            bgView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
            let contentView = HDHUDProgressContentView(direction: direction)
            contentView.progress = progress
            self._showView(view: contentView, superView: superView)
            self._addPopAnimation(view: contentView)
        }
    }
    
    static func _show(commonView: UIView, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        HDHUD.hide()
        bgView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
        self._showView(view: commonView, superView: superView)
        self._addPopAnimation(view: commonView)

        if duration > 0 {
            mTimer = Timer(fire: Date(timeIntervalSinceNow: duration), interval: 0, repeats: false) { (timer) in
                HDHUD.hide()
                if let completion = completion {
                    completion()
                }
            }
            RunLoop.main.add(mTimer!, forMode: .common)
        }
    }
    
    static func _hide(type: HDHUDIconType? = nil) {
        if type == nil || (type != nil && type == mCurrentIconType) {
            //没有指定隐藏类型，或者隐藏类型和当前显示类型一致才销毁
            if mTimer != nil {
                mTimer?.invalidate()
                mTimer = nil
            }
            for view in bgView.subviews {
                view.removeFromSuperview()
            }
            bgView.removeFromSuperview()
            mNextIconType = .none
            mCurrentIconType = nil
        }
    }

    static func _showView(view: UIView, superView: UIView?) {
        //show new view
        var tmpSuperView = superView
        if tmpSuperView == nil {
            tmpSuperView = ZXKitUtil.shared.getCurrentNormalWindow()
        }
        guard let tSuperView = tmpSuperView else { return }
        bgView.backgroundColor = self.backgroundColor
        tSuperView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        bgView.insertSubview(view, at: 0)

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
    }

    static func _addPopAnimation(view: UIView) {
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
}

private extension HDHUD {
    static func UIImageHDBoundle(named: String?) -> UIImage? {
        guard let name = named else { return nil }
        guard let bundlePath = Bundle(for: HDHUD.self).path(forResource: "HDHUD", ofType: "bundle") else { return UIImage(named: name) }
        let bundle = Bundle(path: bundlePath)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }

    static func URLPathHDBoundle(named: String?) -> String? {
        guard let name = named else { return "" }
        guard let bundlePath = Bundle(for: HDHUD.self).path(forResource: "HDHUD", ofType: "bundle") else { return Bundle.main.path(forResource: name, ofType: "") }
        let filePath = Bundle(path: bundlePath)?.path(forResource: name, ofType: "")
        return filePath
    }
}
