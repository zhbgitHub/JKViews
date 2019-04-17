//
//  BGDateSheetView.swift
//  Finance
//
//  Created by ioszhb on 2019/4/4.
//  Copyright © 2019 Udo. All rights reserved.
//

import UIKit

typealias BGDateSheetHandle = ((_ obj: BGDateResultObj?) -> Void)
@objcMembers
class BGDateSheetView: UIView {
    var minDate: Date {
        get {
            return self.pickerView.minDate;
        }
        set {
            self.pickerView.minDate = newValue;
        }
    }
    var maxDate: Date {
        get {
            return self.pickerView.maxDate;
        }
        set {
            self.pickerView.maxDate = newValue;
        }
    }
    var textColor: UIColor {
        get {
            return self.pickerView.textColor;
        }
        set {
            self.pickerView.textColor = newValue;
        }
    }
    var textFont: UIFont {
        get {
            return self.pickerView.textFont;
        }
        set {
            self.pickerView.textFont = newValue;
        }
    }
    var dateObject: BGDateResultObj?
    var sureBlock: BGDateSheetHandle?
    var cancelBlock: BGDateSheetHandle?
    private var tabBarView = UIView()
    private var cancelButton = UIButton(type: .custom)
    private var sureButton = UIButton(type: .custom)
    private var pickerView = BGDatePicker()
    private var coverView  = UIView()
    private var midTopLine = UIView()
    private var midBottomLine = UIView()
    
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .white
        setupCoverView()
        setupTabBarView()
        setupPickerView()
    }
    
    private func setupCoverView() {
        coverView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        coverView.alpha = 0
        coverView.frame = UIScreen.main.bounds
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedCoverView)))
    }
    
    private func setupTabBarView() {
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.hex_666666, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelButton.contentMode = .left
        cancelButton.frame = CGRect(x: 15, y: 0, width: 50, height: 44)
        sureButton.setTitle("确认", for: .normal)
        sureButton.setTitleColor(.hex_508CEE, for: .normal)
        sureButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        sureButton.contentMode = .right
        sureButton.frame = CGRect(x: kScreenW-15-50, y: 0, width: 50, height: 44)
        tabBarView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 44)
        tabBarView.addSubview(cancelButton)
        tabBarView.addSubview(sureButton)
        cancelButton.addTarget(self, action: #selector(clickedCancel), for: .touchDown)
        sureButton.addTarget(self, action: #selector(clickedSure), for: .touchDown)
        let topLine = UIView()
        topLine.backgroundColor = .hex_DDDDDD
        topLine.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 0.5)
        let btmLine = UIView()
        btmLine.backgroundColor = .hex_DDDDDD
        btmLine.frame = CGRect(x: 0, y: 43.5, width: kScreenW, height: 0.5)
        tabBarView.addSubview(topLine)
        tabBarView.addSubview(btmLine)
        addSubview(tabBarView)
    }
    
    private func setupPickerView() {
        pickerView.frame = CGRect(x: (kScreenW-275)/2, y: 44, width: 275, height: 225)
        pickerView.textColor = .black
        pickerView.textFont = UIFont.systemFont(ofSize: 24)
        midTopLine.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 0.5)
        midBottomLine.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 0.5)
        midTopLine.backgroundColor = .hex_DDDDDD
        midBottomLine.backgroundColor = .hex_DDDDDD
        addSubview(pickerView)
        addSubview(midTopLine)
        addSubview(midBottomLine)
        pickerView.selectedDateBlock = { [weak self] (dateObj: BGDateResultObj) in
            self?.dateObject = dateObj
        }
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let supeView = newSuperview else {
            return
        }
        self.pickerView.reloadDate()
        var alertViewH = CGFloat(225 + 44);
        //更新frame
        if #available(iOS 11.0, *) {
            alertViewH += (supeView.safeAreaInsets.bottom)
        }
        let rowSize = pickerView.rowSize(forComponent: 0).height
        midTopLine.ss_y = pickerView.ss_centerY - rowSize * 0.5
        midBottomLine.ss_y = pickerView.ss_centerY + rowSize * 0.5
        self.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: alertViewH)
        UIView.animate(withDuration: 0.25, animations: {
            self.ss_y = (kScreenH - alertViewH);
            self.coverView.alpha = 0.6
        })
    }
    
    @objc private func clickedCoverView() {
        self.dateObject = self.pickerView.dateObject;
        self.cancelBlock?(self.dateObject)
        self.hide()
    }
    
    @objc private func clickedCancel() {
        self.dateObject = self.pickerView.dateObject;
        self.cancelBlock?(self.dateObject)
        self.hide()
    }
    
    @objc private func clickedSure() {
        self.dateObject = self.pickerView.dateObject;
        self.sureBlock?(self.dateObject)
        self.hide()
    }
}


@objc extension BGDateSheetView {
    func show() {
        UIApplication.shared.keyWindow?.addSubview(coverView)
        UIApplication.shared.keyWindow?.addSubview(self)
        self.pickerView.reloadDate()
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.ss_y = kScreenH
            self.coverView.alpha = 0
        }, completion: { (_) in
            self.removeFromSuperview()
            self.coverView.removeFromSuperview()
        })
    }
    
    func doSelect(year: Int, month: Int, day: Int) {
        self.pickerView.doSelect(year: year, month: month, day: day)
    }
    
    func doSelect(dateString: String, dateFormat:String) {
        let date = dateString.bgsc_toDate(format: dateFormat) ?? self.minDate
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        self.pickerView.doSelect(year: year, month: month, day: day)
    }
    
}


extension UIView {
    var ss_y: CGFloat {
        get {
            return self.frame.origin.y;
        }
        set {
            var nRect = self.frame
            nRect.origin.y = newValue
            self.frame = nRect
        }
    }
    
    var ss_centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            var nPoint = self.center
            nPoint.y = newValue
            self.center = nPoint
        }
    }
}


fileprivate extension String {
    func bgsc_toDate(format: String) -> Date? {
        let dfmatter = DateFormatter()
        dfmatter.timeZone = TimeZone.current
        dfmatter.dateFormat = format
        let date = dfmatter.date(from: self)
        return date
    }
}








