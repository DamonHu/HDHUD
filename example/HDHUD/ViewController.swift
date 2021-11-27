//
//  ViewController.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    let titleLabel = ["displayPosition: top", "displayPosition: center", "displayPosition: bottom", "displayPosition: navigationBarMask", "displayPosition: tabBarMask"]
    let dataList = [["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "横版纯文字", "横版警告", "横版错误", "横版成功", "横版加载loading"],
                    ["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "横版纯文字", "横版警告", "横版错误", "横版成功", "横版加载loading"],
                    ["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "横版纯文字", "横版警告", "横版错误", "横版成功", "横版加载loading"],
                    ["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "横版纯文字", "横版警告", "横版错误", "横版成功", "横版加载loading"],
                    ["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "横版纯文字", "横版警告", "横版错误", "横版成功", "横版加载loading"]
    ]
    
    var task: HDHUDProgressTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mTableView)
        mTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    //自定义视图
    lazy var mCustomView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        view.backgroundColor = UIColor.red
        return view
    }()

    //自定义视图使用snapkit布局
    lazy var mCustomView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(100)
        }
        return view
    }()
    
    //MARK: UI
    lazy var mTableView: UITableView = {
        let tTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        if #available(iOS 15.0, *) {
            tTableView.sectionHeaderTopPadding = 0
        }
        tTableView.rowHeight = 40
        tTableView.backgroundColor = UIColor.clear
        tTableView.showsVerticalScrollIndicator = false
        tTableView.separatorStyle = .singleLine
        tTableView.dataSource = self
        tTableView.delegate = self
        tTableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.zx.className())
        return tTableView
    }()
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemlist = dataList[section]
        return itemlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemlist = dataList[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.zx.className())
        cell?.textLabel?.text = itemlist[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        let label = UILabel()
        label.text = titleLabel[section]
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor.zx.color(hexValue: 0xffffff)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            HDHUD.displayPosition = .top
        case 1:
            HDHUD.displayPosition = .center
        case 2:
            HDHUD.displayPosition = .bottom
        case 3:
            HDHUD.displayPosition = .navigationBarMask
        case 4:
            HDHUD.displayPosition = .tabBarMask
        default:
            break
        }
        let item = dataList[indexPath.section][indexPath.row]
        switch indexPath.row {
        case 0:
            HDHUD.show(item, icon: .none)
        case 1:
            HDHUD.show(item, icon: .none)
        case 2:
            HDHUD.show(item, icon: .warn)
        case 3:
            HDHUD.show(item, icon: .error)
        case 4:
            HDHUD.show(item, icon: .success)
        case 5:
            HDHUD.show(nil, icon: .loading)
        case 6:
            HDHUD.show(item, icon: .loading)
        case 7:
            HDHUD.showProgress(0.3)
        case 8:
            HDHUD.showProgress(0.6)
        case 9:
            HDHUD.show(item, icon: .none, direction: .horizontal)
        case 10:
            HDHUD.show(item, icon: .warn, direction: .horizontal)
        case 11:
            HDHUD.show(item, icon: .error, direction: .horizontal)
        case 12:
            HDHUD.show(item, icon: .success, direction: .horizontal)
        case 13:
            HDHUD.show(item, icon: .loading, direction: .horizontal)
        default:
            break
        }
    }
}
