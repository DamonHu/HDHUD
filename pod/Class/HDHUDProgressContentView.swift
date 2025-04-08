//
//  HDHUDProgressContentView.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit
import DDUtils
#if canImport(Kingfisher)
import Kingfisher
#endif

class HDHUDProgressContentView: HDHUDContentView {
    var progress: Float = 0 {
        willSet {
            self.mLabel.text = String(format: "%.2f%%", newValue * 100)
            self.mProgressView.progress = newValue
        }
    }

    init(direction: HDHUDContentDirection = .horizontal) {
        super.init()
        self.createUI(direction: direction)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: UI
    lazy var mImageView: UIImageView = {
        let tImageView = UIImageView()
        tImageView.translatesAutoresizingMaskIntoConstraints = false
        tImageView.image = HDHUD.loadingImage
        return tImageView
    }()

    lazy var mProgressView: CircularProgressView = {
        let tProgressView = CircularProgressView(frame: CGRect(x: 27.5, y: 15, width: 55, height: 55))
        tProgressView.translatesAutoresizingMaskIntoConstraints = false
        tProgressView.trackLineWidth = 4
        tProgressView.trackTintColor = HDHUD.trackTintColor
        tProgressView.progressTintColor = HDHUD.progressTintColor
        tProgressView.roundedProgressLineCap = true
        return tProgressView
    }()
    
    lazy var mLabel: UILabel = {
        let tLabel = UILabel()
        tLabel.translatesAutoresizingMaskIntoConstraints = false
        tLabel.text = "0%"
        tLabel.numberOfLines = 0
        tLabel.textAlignment = .center
        tLabel.textColor = HDHUD.textColor
        tLabel.font = HDHUD.textFont
        return tLabel
    }()
}

extension HDHUDProgressContentView {
    func createUI(direction: HDHUDContentDirection) {
        self.addSubview(mImageView)
        self.addSubview(mLabel)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(lessThanOrEqualToConstant: 240).isActive = true
        

        self.addSubview(mProgressView)
        mProgressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        mProgressView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        if direction == .horizontal {
            mProgressView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        } else {
            mProgressView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        }
        mProgressView.widthAnchor.constraint(equalToConstant: 55).isActive = true
        mProgressView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        
        self.addSubview(mImageView)
        mImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        mImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        mImageView.centerXAnchor.constraint(equalTo: mProgressView.centerXAnchor).isActive = true
        mImageView.centerYAnchor.constraint(equalTo: mProgressView.centerYAnchor).isActive = true

        self.addSubview(mLabel)
        if direction == .horizontal {
            mLabel.leftAnchor.constraint(equalTo: mProgressView.rightAnchor, constant: 8).isActive = true
            mLabel.centerYAnchor.constraint(equalTo: mProgressView.centerYAnchor).isActive = true
            mLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        } else {
            mLabel.topAnchor.constraint(equalTo: mProgressView.bottomAnchor, constant: 8).isActive = true
            mLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            mLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        }
    }
}
