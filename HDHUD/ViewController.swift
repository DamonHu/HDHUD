//
//  ViewController.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit

var i = 0

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.red
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(p_click), for: .touchUpInside)

    }

    @objc func p_click() {
        if i == 0 {
            HDHUD.show("横版排列", icon: .none, direction: .horizontal)
        }
        if i == 1 {
            HDHUD.show("横版排列", icon: .warn, direction: .horizontal)
        }
        if i == 2 {
            HDHUD.show("横版排列", icon: .error, direction: .horizontal)
        }
        if i == 3 {
            HDHUD.show("横版排列", icon: .success, direction: .horizontal)
        }
        if i == 4 {
            HDHUD.show("横版排列", icon: .loading, direction: .horizontal)
        }

        if i == 5 {
            HDHUD.show("竖版排列", icon: .none, direction: .vertical)
        }
        if i == 6 {
            HDHUD.show("竖版排列", icon: .warn, direction: .vertical)
        }
        if i == 7 {
            HDHUD.show("竖版排列", icon: .error, direction: .vertical)
        }
        if i == 8 {
            HDHUD.show("竖版排列", icon: .success, direction: .vertical)
        }
        if i == 9 {
            HDHUD.show("竖版排列", icon: .loading, direction: .vertical)
        }
        if i == 10 {
            HDHUD.show("自动换行自动换行自动换行自动换行自动换行自动换行自动换行自动换行自动换行自动换行自动换行", icon: .success, direction: .vertical)
        }
        if i == 11 {
            HDHUD.showProgress(0.1, direction: .vertical)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                HDHUD.showProgress(0.3, direction: .vertical)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                HDHUD.showProgress(0.5, direction: .vertical)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                HDHUD.showProgress(0.6, direction: .vertical)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                HDHUD.showProgress(0.9, direction: .vertical)
            }
        }

        

        i = i+1
    }
}

