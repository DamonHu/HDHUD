//
//  HDHUDLabelContentView.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit
import Kingfisher

class HDHUDLabelContentView: HDHUDContentView {

    init(content: String? = nil, hudType: HDHUDType, direction: HDHUDContentDirection = .horizontal) {
        super.init()
        self.createUI(content: content, hudType: hudType, direction: direction)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: UI
    lazy var mImageView: UIImageView = {
        let tImageView = UIImageView()
        return tImageView
    }()
    lazy var mLabel: UILabel = {
        let tLabel = UILabel()
        tLabel.numberOfLines = 0
        tLabel.textAlignment = .center
        tLabel.textColor = HDHUD.textColor
        tLabel.font = HDHUD.textFont
        return tLabel
    }()
}

extension HDHUDLabelContentView {
    func createUI(content: String?, hudType: HDHUDType, direction: HDHUDContentDirection) {
        switch hudType {
            case .none:
                mImageView.image = nil
            case .warn:
                mImageView.image = HDHUD.warnImage
            case .error:
                mImageView.image = HDHUD.errorImage
            case .success:
                mImageView.image = HDHUD.successImage
            case .loading:
                mImageView.kf.setImage(with: HDHUD.loadingImageURL)
        }
        mLabel.text = content

        self.addSubview(mImageView)
        self.addSubview(mLabel)

        self.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualTo(240)
        }

        //判断单一存在的情况
        guard content != nil else {
            self.snp.makeConstraints { (make) in
                make.width.height.equalTo(100)
            }
            mImageView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                if hudType == .loading {
                    make.width.height.equalTo(48)
                } else {
                    make.width.height.equalTo(24)
                }
            }
            return
        }
        guard hudType != .none else {
            mLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(15)
            }
            return
        }

        mImageView.snp.makeConstraints { (make) in
            if hudType == .loading {
                make.width.height.equalTo(48)
            } else {
                make.width.height.equalTo(24)
            }

            if direction == .horizontal {
                make.left.equalToSuperview().offset(15)
                make.centerY.equalToSuperview()
            } else {
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(15)
            }
        }

        mLabel.snp.makeConstraints { (make) in
            if direction == .horizontal {
                make.left.equalTo(mImageView.snp.right).offset(8)
                make.top.bottom.right.equalToSuperview().inset(15)
            } else {
                make.top.equalTo(mImageView.snp.bottom).offset(8)
                make.left.bottom.right.equalToSuperview().inset(15)
            }
        }
    }
}
