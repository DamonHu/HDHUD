//
//  ViewController.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit

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
        print("click")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ssssssssss")
//        HDHUD.show("水电费水电费就还是手动蝶阀接口和收到就好房间号史蒂芬霍金收到就好福建省方法",hudType: .loading, direction: .vertical, duration: 3) {
//            print("mmmm")
//        }
//        HDHUD.showProgress(0.1, direction: .vertical)

        HDHUD.show("修改成功", hudType: .success)

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
}

