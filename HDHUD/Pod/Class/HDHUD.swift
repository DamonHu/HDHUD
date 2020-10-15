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
    public static var errorImage = UIImageHDBoundle(named: "ic_error")
    public static var successImage = UIImageHDBoundle(named: "ic_success")
    public static var loadingImageURL = URL(fileURLWithPath: Bundle.main.path(forResource: "loading", ofType: "gif")!)
    public static var backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    public static var textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    public static var textFont = UIFont.systemFont(ofSize: 16)
    public static var contentOffset = CGPoint.zero

    //private members
    private static let mContentBGView = UIView()
    private static var mTimer: Timer? = nil
}

//MARK: Public Method
public extension HDHUD {
    static func show(_ content: String? = nil, hudType: HDHUDType = .none, direction: HDHUDContentDirection = .horizontal, duration: TimeInterval = 2.5, superView: UIView? = nil, userInteractionOnUnderlyingViewsEnabled: Bool = true, completion: (()->Void)? = nil) {
        //remove last view
        HDHUD.hide()
        DispatchQueue.main.async {
            //show new view
            var tmpSuperView = superView
            if tmpSuperView == nil {
                tmpSuperView = HDCommonTools.shared.getCurrentNormalWindow()
            }
            guard let tSuperView = tmpSuperView else { return }
            mContentBGView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
            tSuperView.addSubview(mContentBGView)
            mContentBGView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            let contentView = HDHUDLabelContentView(content: content, hudType: hudType, direction: direction)
            mContentBGView.addSubview(contentView)
            contentView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview().offset(contentOffset.x)
                make.centerY.equalToSuperview().offset(contentOffset.y)
            }
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
                //show new view
                var tmpSuperView = superView
                if tmpSuperView == nil {
                    tmpSuperView = HDCommonTools.shared.getCurrentNormalWindow()
                }
                guard let tSuperView = tmpSuperView else { return }
                mContentBGView.isUserInteractionEnabled = !userInteractionOnUnderlyingViewsEnabled
                tSuperView.addSubview(mContentBGView)
                mContentBGView.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                let contentView = HDHUDProgressContentView(direction: direction)
                contentView.progress = progress
                mContentBGView.addSubview(contentView)
                contentView.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview().offset(contentOffset.x)
                    make.centerY.equalToSuperview().offset(contentOffset.y)
                }
                self.addPopAnimation(view: contentView)
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
