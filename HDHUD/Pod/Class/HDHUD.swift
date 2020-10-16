//
//  HDHUD.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit
import HDSwiftCommonTools

public enum HDHUDType {
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

open class HDHUD {
    public static var warnImage = UIImageHDBoundle(named: "ic_warning")
    public static var warnImageSize = CGSize(width: 24, height: 24)
    public static var errorImage = UIImageHDBoundle(named: "ic_error")
    public static var errorImageSize = CGSize(width: 24, height: 24)
    public static var successImage = UIImageHDBoundle(named: "ic_success")
    public static var successImageSize = CGSize(width: 24, height: 24)
    public static var loadingImageURL = URL(fileURLWithPath: Bundle.main.path(forResource: "loading", ofType: "gif")!)
    public static var loadingImageSize = CGSize(width: 48, height: 48)
    public static var backgroundColor = UIColor(hexValue: 0x000000, alpha: 0.8)
    public static var textColor = UIColor(hexValue: 0xFFFFFF)
    public static var textFont = UIFont.systemFont(ofSize: 16)
    public static var contentOffset = CGPoint.zero
    public static var progressTintColor = UIColor(hexValue: 0xFF8F0C)
    public static var trackTintColor = UIColor(hexValue: 0xFFFFFF)
    //private members
    private static let mContentBGView = UIView()
    private static var mTimer: Timer? = nil
}

//MARK: Public Method
public extension HDHUD {


    /// display HUD
    /// - Parameters:
    ///   - content: content text
    ///   - hudType: icon type
    ///   - direction: Layout direction of icon and text
    ///   - duration: specifies the time when the HUD is automatically turned off, `-1` means not to turn off automatically
    ///   - superView: the upper view of the HUD, the default is the current window
    ///   - userInteractionOnUnderlyingViewsEnabled: whether the bottom view responds when the hud pops up
    ///   - completion: callback after the HUD is automatically closed, if `duration` is set to -1, it will not be called
    static func show(_ content: String? = nil, hudType: HDHUDType = .none, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        //remove last view
        HDHUD.hide()
        DispatchQueue.main.async {
            mContentBGView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
            let contentView = HDHUDLabelContentView(content: content, hudType: hudType, direction: direction)
            self.showView(view: contentView, superView: superView)
            self.addPopAnimation(view: contentView)

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
    }

    static func showProgress(_ progress: Float, direction: HDHUDContentDirection = .horizontal, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true) {
        if let progressContentView = mContentBGView.subviews.first as? HDHUDProgressContentView {
            progressContentView.progress = progress
        } else {
            //remove last view
            HDHUD.hide()
            DispatchQueue.main.async {
                mContentBGView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
                let contentView = HDHUDProgressContentView(direction: direction)
                contentView.progress = progress
                self.showView(view: contentView, superView: superView)
                self.addPopAnimation(view: contentView)
            }
        }
    }
    
    static func show(view: UIView, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        //remove last view
        HDHUD.hide()
        DispatchQueue.main.async {
            mContentBGView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
            self.showView(view: view, superView: superView)
            self.addPopAnimation(view: view)

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
    }

    static func hide() {
        if mTimer != nil {
            mTimer?.invalidate()
            mTimer = nil
        }
        DispatchQueue.main.async {
            for view in mContentBGView.subviews {
                view.removeFromSuperview()
            }
            mContentBGView.removeFromSuperview()
        }
    }
}

//MARK: Private Method
private extension HDHUD {
    static func UIImageHDBoundle(named: String?) -> UIImage? {
        let name = named ?? ""
        let filePath = Bundle.main.path(forResource: "\(name)@3x", ofType: "png")
        return UIImage(contentsOfFile: filePath ?? "")
    }

    static func showView(view: UIView, superView: UIView?) {
        //show new view
        var tmpSuperView = superView
        if tmpSuperView == nil {
            tmpSuperView = HDCommonTools.shared.getCurrentNormalWindow()
        }
        guard let tSuperView = tmpSuperView else { return }

        tSuperView.addSubview(mContentBGView)
        mContentBGView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        mContentBGView.addSubview(view)
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
