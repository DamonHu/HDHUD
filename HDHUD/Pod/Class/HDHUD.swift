//
//  HDHUD.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit
import HDCommonToolsSwift

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

///当页面正在展示toast，此时调用loading显示，会根据优先级的设置进行展示。
///low： loading不显示，只显示toast
///common: loading和toast同时叠加显示
///high：关闭toast，展示loading
///When the page is displaying toast, the loading display is called, and it will be displayed according to the priority setting.
///Low: loading is not displayed, only toast is displayed
///Common: loading and toast are superimposed at the same time
///High: close toast and show loading
public enum HDHUDLoadingPriority {
    case low
    case common
    case high
}

open class HDHUD {
    public static var warnImage = UIImage(contentsOfFile: UIImageHDBoundle(named: "ic_warning@3x.png"))
    public static var warnImageSize = CGSize(width: 24, height: 24)
    public static var errorImage = UIImage(contentsOfFile: UIImageHDBoundle(named: "ic_error@3x.png"))
    public static var errorImageSize = CGSize(width: 24, height: 24)
    public static var successImage = UIImage(contentsOfFile: UIImageHDBoundle(named: "ic_success@3x.png"))
    public static var successImageSize = CGSize(width: 24, height: 24)
    public static var loadingImageURL = URL(fileURLWithPath: UIImageHDBoundle(named: "loading.gif"))
    public static var loadingImageSize = CGSize(width: 48, height: 48)
    public static var backgroundColor = UIColor(hexValue: 0x000000, alpha: 0.8)
    public static var textColor = UIColor(hexValue: 0xFFFFFF)
    public static var textFont = UIFont.systemFont(ofSize: 16)
    public static var contentOffset = CGPoint.zero
    public static var progressTintColor = UIColor(hexValue: 0xFF8F0C)
    public static var trackTintColor = UIColor(hexValue: 0xFFFFFF)
    //Display form when loading and toast appear at the same time
    public static var loadingPriority = HDHUDLoadingPriority.high

    //private members
    private static var mCurrentIconType: HDHUDIconType?
    private static var mNextIconType = HDHUDIconType.none
    private static let mContentBGView = UIView()
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
    static func show(_ content: String? = nil, icon: HDHUDIconType = .none, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        if Thread.isMainThread {
            self.p_show(content, icon: icon, direction: direction, duration: duration, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled, completion: completion)
        } else {
            DispatchQueue.main.async {
                self.p_show(content, icon: icon, direction: direction, duration: duration, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled, completion: completion)
            }
        }
    }

    static func showProgress(_ progress: Float, direction: HDHUDContentDirection = .horizontal, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true) {
        if Thread.isMainThread {
            self.p_showProgress(progress, direction: direction, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled)
        } else {
            DispatchQueue.main.async {
                self.p_showProgress(progress, direction: direction, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled)
            }
        }
    }
    
    static func show(commonView: UIView, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        if Thread.isMainThread {
            self.p_show(commonView: commonView, duration: duration, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled, completion: completion)
        } else {
            DispatchQueue.main.async {
                self.p_show(commonView: commonView, duration: duration, superView: superView, userInteractionOnUnderlyingViewsEnabled: userInteractionOnUnderlyingViewsEnabled, completion: completion)
            }
        }
    }

    static func hide(type: HDHUDIconType? = nil) {
        if Thread.isMainThread {
            self.p_hide(type: type)
        } else {
            DispatchQueue.main.async {
                self.p_hide(type: type)
            }
        }
    }
}

//MARK: Private Method

private extension HDHUD {
    static func p_show(_ content: String? = nil, icon: HDHUDIconType = .none, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        //下次即将显示的toast
        mNextIconType = icon
        //根据下次即将显示的类型进行清理
        //remove last view
        if self.mNextIconType == .loading, let currentIconType = mCurrentIconType, currentIconType != .loading {
            switch self.loadingPriority {
                case .low:
                    return
                case .common:
                    break
                case .high:
                    HDHUD.hide()
            }
        } else {
            HDHUD.hide()
        }
        mContentBGView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
        let contentView = HDHUDLabelContentView(content: content, icon: icon, direction: direction)
        self.showView(view: contentView, superView: superView)
        self.addPopAnimation(view: contentView)
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
    
    static func p_showProgress(_ progress: Float, direction: HDHUDContentDirection = .horizontal, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true) {
        if let progressContentView = mContentBGView.subviews.first as? HDHUDProgressContentView {
            progressContentView.progress = progress
        } else {
            HDHUD.hide()
            mContentBGView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
            let contentView = HDHUDProgressContentView(direction: direction)
            contentView.progress = progress
            self.showView(view: contentView, superView: superView)
            self.addPopAnimation(view: contentView)
        }
    }
    
    static func p_show(commonView: UIView, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        HDHUD.hide()
        mContentBGView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
        self.showView(view: commonView, superView: superView)
        self.addPopAnimation(view: commonView)

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
    
    static func p_hide(type: HDHUDIconType? = nil) {
        if type == nil || (type != nil && type == mCurrentIconType) {
            //没有指定隐藏类型，或者隐藏类型和当前显示类型一致才销毁
            if mTimer != nil {
                mTimer?.invalidate()
                mTimer = nil
            }
            for view in mContentBGView.subviews {
                view.removeFromSuperview()
            }
            mContentBGView.removeFromSuperview()
            mNextIconType = .none
            mCurrentIconType = nil
        }
    }
}

private extension HDHUD {
    static func UIImageHDBoundle(named: String?) -> String {
        guard let name = named else { return "" }
        guard let bundlePath = Bundle(for: HDHUD.self).path(forResource: "HDHUD", ofType: ".bundle") else { return "" }
        let filePath = Bundle(path: bundlePath)?.path(forResource: name, ofType: "") ?? ""
        return filePath
    }

    static func showView(view: UIView, superView: UIView?) {
        //show new view
        var tmpSuperView = superView
        if tmpSuperView == nil {
            tmpSuperView = HDCommonToolsSwift.shared.getCurrentNormalWindow()
        }
        guard let tSuperView = tmpSuperView else { return }

        tSuperView.addSubview(mContentBGView)
        mContentBGView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        mContentBGView.insertSubview(view, at: 0)
        view.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(contentOffset.x)
            make.centerY.equalToSuperview().offset(contentOffset.y)
        }
    }

    static func addPopAnimation(view: UIView) {
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
