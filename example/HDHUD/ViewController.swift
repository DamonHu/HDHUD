//
//  ViewController.swift
//  HDHUD
//
//  Created by Damon on 2020/10/15.
//

import UIKit

class ViewController: UIViewController {
    let titleLabel = ["displayPosition: top", "displayPosition: center", "displayPosition: bottom", "displayPosition: navigationBarMask", "displayPosition: tabBarMask"]
    let dataList = [["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "图文纵版排序纯文字", "图文纵版排序警告", "图文纵版排序错误", "图文纵版排序成功", "图文纵版排序加载loading", "图文纵版排序进度30%", "图文纵版排序进度60%"],
                    ["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "图文纵版排序纯文字", "图文纵版排序警告", "图文纵版排序错误", "图文纵版排序成功", "图文纵版排序加载loading", "图文纵版排序进度30%", "图文纵版排序进度60%"],
                    ["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "图文纵版排序纯文字", "图文纵版排序警告", "图文纵版排序错误", "图文纵版排序成功", "图文纵版排序加载loading", "图文纵版排序进度30%", "图文纵版排序进度60%"],
                    ["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "图文纵版排序纯文字", "图文纵版排序警告", "图文纵版排序错误", "图文纵版排序成功", "图文纵版排序加载loading", "图文纵版排序进度30%", "图文纵版排序进度60%"],
                    ["纯文字", "多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示多行显示", "警告", "错误", "成功", "加载loading", "loading+文字", "进度30%", "进度60%", "图文纵版排序纯文字", "图文纵版排序警告", "图文纵版排序错误", "图文纵版排序成功", "图文纵版排序加载loading", "图文纵版排序进度30%", "图文纵版排序进度60%"]
    ]
    
    var task: HDHUDProgressTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mTableView)
        
        mTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        mTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        mTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        return view
    }()
    
    //MARK: UI
    lazy var mTableView: UITableView = {
        let tTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        if #available(iOS 15.0, *) {
            tTableView.sectionHeaderTopPadding = 0
        }
        tTableView.translatesAutoresizingMaskIntoConstraints = false
        tTableView.rowHeight = 40
        tTableView.backgroundColor = UIColor.clear
        tTableView.showsVerticalScrollIndicator = false
        tTableView.separatorStyle = .singleLine
        tTableView.dataSource = self
        tTableView.delegate = self
        tTableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.dd.className())
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
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.dd.className())
        cell?.textLabel?.text = itemlist[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = titleLabel[section]
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor.dd.color(hexValue: 0xffffff)
        view.addSubview(label)
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
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
            HDHUD.show(item, icon: .none, direction: .vertical)
        case 10:
            HDHUD.show(item, icon: .warn, direction: .vertical)
        case 11:
            HDHUD.show(item, icon: .error, direction: .vertical)
        case 12:
            HDHUD.show(item, icon: .success, direction: .vertical)
        case 13:
            HDHUD.show(item, icon: .loading, direction: .vertical)
        case 14:
            HDHUD.showProgress(0.3, direction: .vertical)
        case 15:
            HDHUD.showProgress(0.6, direction: .vertical)
        default:
            break
        }
    }
}
