//
//  BCActionSheet.swift
//  BCActionSheet_Example
//
//  Created by ioszhb on 2019/3/21.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

typealias ItemClickBlock = (_ index: Int) -> Void

struct BCActionSheetItemObj {
    var title: String
    var color: UIColor
    var font: UIFont
    var handler:ItemClickBlock?
    
    init(title: String, color: UIColor, font: UIFont, block: ItemClickBlock?) {
        self.title = title
        self.color = color
        self.font = font
        self.handler = block
    }
}


//@objcMembers 属性及类支持oc
@objcMembers class BCActionSheet: UIView {
    fileprivate let kScreenW = UIScreen.main.bounds.size.width
    fileprivate let kScreenH = UIScreen.main.bounds.size.height
    fileprivate let kScreenRect = UIScreen.main.bounds
    fileprivate let kScreenSize = UIScreen.main.bounds.size
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    fileprivate let coverBackView = UIView()
    fileprivate var itemObjs = [BCActionSheetItemObj]()
    fileprivate var cancelItemObj = BCActionSheetItemObj(title: "取消", color: .red, font: UIFont.systemFont(ofSize: 15), block: nil)
    fileprivate var alertTitle = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = .white
        coverBackView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        coverBackView.frame = UIScreen.main.bounds
        coverBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedBackView)))
        
        tableView.backgroundColor = .white
        tableView.register(BCActionSheetCell.classForCoder(), forCellReuseIdentifier: "BC_Action_Sheet_Cell")
        tableView.isScrollEnabled = false
        tableView.rowHeight = 49
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 0)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let supeView = newSuperview else {
            return
        }
        var totalCount = 0
        self.tableView.reloadData()
        if alertTitle.isEmpty {
            totalCount = itemObjs.count + 1
        }else {
            totalCount = itemObjs.count + 2
        }
        let tableviewH = CGFloat(totalCount * 49 + 10)
        var alertViewH = tableviewH
        
        //更新frame
        if #available(iOS 11.0, *) {
            alertViewH += (supeView.safeAreaInsets.bottom)
        }
        self.tableView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: tableviewH)
        self.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: alertViewH)
        UIView.animate(withDuration: 0.25, animations: {
            self.y = self.kScreenH - alertViewH
            self.coverBackView.alpha = 0.4
        })
    }
    
    
    /// 设置弹框的标题
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - color: 颜色
    ///   - font: 字体
    func setAlertTitle(_ title: String, color: UIColor? = .red, font: UIFont? = UIFont.boldSystemFont(ofSize: 16)) {
        if title.isEmpty {
            return
        }
        self.alertTitle = title
        let label = UILabel()
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 49)
        label.text = title
        label.textColor = color ?? .red
        label.font = font ?? UIFont.boldSystemFont(ofSize: 16)
        
        let line = UIView()
        line.frame = CGRect(x: 0, y: 49 - 0.5, width: kScreenW, height: 0.5)
        line.backgroundColor = .lightGray
        
        let tbHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 49))
        tbHeaderView.backgroundColor = .white
        tbHeaderView.addSubview(label)
        tbHeaderView.addSubview(line)
        
        self.tableView.tableHeaderView = tbHeaderView
    }
    
    
    /// 增加item(除最底部取消外的选项)
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - color: 颜色
    ///   - font: 字体
    ///   - handle: 回调
    func addAlertItem(title: String, color: UIColor? = .red, font: UIFont? = UIFont.systemFont(ofSize: 15), handle: ItemClickBlock?) {
        if title.isEmpty {
            return
        }
        let nColor = (color ?? .red)
        let nFont = (font ?? UIFont.systemFont(ofSize: 15))
        let itemObj = BCActionSheetItemObj(title: title, color: nColor, font: nFont, block: handle)
        itemObjs.append(itemObj)
    }
    
    /// 设置取消按钮的样式(可以不设置,有默认的颜色,字体)
    ///
    /// - Parameters:
    ///   - title: 默认'取消'
    ///   - color: 默认red
    ///   - font: 默认15
    ///   - handle: 回调
    func setCancelItem(title: String, color: UIColor? = .red, font: UIFont? = UIFont.systemFont(ofSize: 15), handle: ItemClickBlock?) {
        let nTitle = (title.isEmpty ? "取消" : title)
        let nColor = (color ?? .red)
        let nFont = (font ?? UIFont.systemFont(ofSize: 15))
        self.cancelItemObj = BCActionSheetItemObj(title: nTitle, color: nColor, font: nFont, block: handle)
    }
}


// MARK: - 事件
@objc extension BCActionSheet {
    
    /// 展示
    func show() {
        UIApplication.shared.keyWindow?.addSubview(coverBackView)
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    /// 隐藏
    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.y = self.kScreenH
            self.coverBackView.alpha = 0
        }, completion: { (_) in
            self.removeFromSuperview()
            self.coverBackView.removeFromSuperview()
        })
    }
    
    /// 点击了遮罩层
    func clickedBackView() {
        hide()
    }
}

extension BCActionSheet: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            return itemObjs.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BC_Action_Sheet_Cell", for: indexPath) as! BCActionSheetCell
        if 0 == indexPath.section {
            let obj = self.itemObjs[indexPath.row]
            cell.label.text = obj.title
            cell.label.textColor = obj.color
            cell.bottomLine.isHidden = (self.itemObjs.count - 1 == indexPath.row)
        }else {
            cell.label.text = self.cancelItemObj.title
            cell.label.textColor = self.cancelItemObj.color
            cell.bottomLine.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if 0 == section {
            return 10
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if 0 == section {
            let view =  UIView()
            view.backgroundColor = UIColor(white: 0, alpha: 0.38)
            return view
        }
        return nil;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if itemObjs[indexPath.row].handler != nil {
                itemObjs[indexPath.row].handler!(indexPath.row)
            }
            hide()
        } else {
            if cancelItemObj.handler != nil {
                cancelItemObj.handler!(indexPath.row)
            }
            hide()
        }
    }
}

private extension BCActionSheet {
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var rect = self.frame
            rect.origin.y = newValue
            self.frame = rect
        }
    }
}


/// item
fileprivate class BCActionSheetCell: UITableViewCell {
    var label = UILabel()
    var bottomLine = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        self.contentView.addSubview(label)
        self.contentView.addSubview(bottomLine)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
        label.backgroundColor = .white
        bottomLine.backgroundColor = .lightGray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = self.bounds
        var rect = self.bounds
        rect.origin.y = rect.size.height - 0.5
        rect.size.height = 0.5
        bottomLine.frame = rect
    }
}
