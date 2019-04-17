//
//  BGDatePicker.swift
//  BGDatePicker_Example
//
//  Created by ioszhb on 2019/4/3.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

@objcMembers
class BGDateResultObj: NSObject {
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var dateString: String?
    var date: Date?
}

typealias BGYearMonthDay = (year: Int, month: Int, day: Int)
typealias BGDateHandle = ((_ obj: BGDateResultObj) -> Void)
let tagForever = 9998

@objcMembers
final class BGDatePicker: UIPickerView {
    ////////....↓以下属性对外暴露......\\\\\\\
    var minDate: Date {
        get {
            return _minDate
        }
        set {
            //            assert(_maxDate >= newValue, "最小年数 必须小于 最大年数")
            _minDate = newValue
            self.minYMD = newValue.bg_toTuple(format: "yyyy-MM-dd")
        }
    }
    var maxDate: Date{
        get {
            return _maxDate
        }
        set {
            //            assert(newValue >= _minDate, "最小年数 必须小于 最大年数")
            _maxDate = newValue
            self.maxYMD = newValue.bg_toTuple(format: "yyyy-MM-dd")
        }
    }
    var textColor: UIColor = .red
    var textFont: UIFont = UIFont.systemFont(ofSize: 16)
    var selectedDateBlock: BGDateHandle?
    private(set) var dateObject: BGDateResultObj = BGDateResultObj()
    //////////////....↑以上属性对外暴露......\\\\\\\\\\\\\\
    
    /////////////////....↓以下属性在init里实例化......\\\\\\\\\\\
    private var selectedYear: Int!
    private var selectedMonth: Int!
    private var selectedDay: Int!
    private var minYMD: BGYearMonthDay!
    private var maxYMD: BGYearMonthDay!
    private var forever = (isHas: false, title: "永远")
    /////////////////....↑以上属性在init里实例化......\\\\\\\\\\\
    private var _minDate: Date = Date(timeIntervalSince1970: 0)
    private var _maxDate: Date = Date()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setupUI()
        setupDate()
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        self.dataSource = self
        self.delegate = self
    }
    
    private func setupDate() {
        self.minYMD = minDate.bg_toTuple(format: "yyyy-MM-dd")
        self.maxYMD = maxDate.bg_toTuple(format: "yyyy-MM-dd")
        self.selectedYear  = minYMD.year
        self.selectedMonth = minYMD.month
        self.selectedDay   = minYMD.month
    }
    
}


// MARK: - 对外提供的方法
@objc extension BGDatePicker {
    func doSelect(year: Int, month: Int, day: Int) {//此方法内涵十足,勿动...
        let yearIndex   = getYearsArray().firstIndex(of: year) ?? 0;
        self.selectedYear   = self.getYearsArray()[yearIndex]
        let monthIndex  = getMonthsArray().firstIndex(of: month) ?? 0;
        self.selectedMonth  = self.getMonthsArray()[monthIndex]
        let dayIndex    = getDaysArray().firstIndex(of: day) ?? 0;
        self.selectedDay    = self.getDaysArray()[dayIndex]
        self.selectRow(yearIndex, inComponent: 0, animated: true)
        self.selectRow(monthIndex, inComponent: 1, animated: true)
        self.selectRow(dayIndex, inComponent: 2, animated: true)
        resetDateObj()
    }
    
    func reloadDate() {
        self.reloadAllComponents()
        doSelect(year: selectedYear, month: selectedMonth, day: selectedDay)
    }
    
    /// 添加'长期有效'
    ///
    /// - Parameters:
    ///   - string: 字符串,不能为空
    ///   - maxDate: 添加'长期有效',必须设置最大时间,不能小于最小时间
    func addForever(title: String, maxDate: Date) {
        if (title.isEmpty) {return;}
        self.maxDate = maxDate;
        self.forever.isHas = true
        self.forever.title = title
    }
}

// MARK: - picker.dataSource/delegate
extension BGDatePicker: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if 0 == component {
            return getYearsArray().count
        }else if 1 == component {
            return getMonthsArray().count
        }else if 2 == component{
            return getDaysArray().count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = createLabel()
        label.text = nil
        //赋值
        if 0 == component {
            label.text = textForYear(at: row)
        } else if 1 == component {
            label.text = textForMonth(at: row)
        } else if 2 == component {
            label.text = textForDay(at: row)
        }
        cleanSeparateLine()
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if 0 == component {
            if (row < 0 || row >= self.getYearsArray().count) { return }
            self.selectedYear = self.getYearsArray()[row]
            if (selectedYear == tagForever) {//永久嵌入
                self.forever_reloadMonth()
                self.forever_reloadDay()
            }else {
                self.selected_reloadMonth()
                self.selected_reloadDay()
            }
        }else if 1 == component {
            if (row < 0 || row >= self.getMonthsArray().count) { return }
            if (selectedYear == tagForever) {//永久嵌入
                self.forever_reloadDay()
            }else {
                self.selectedMonth = self.getMonthsArray()[row]
                self.selected_reloadDay()
            }
        }else if 2 == component {
            if (row < 0 || row >= self.getDaysArray().count) { return }
            if (selectedYear == tagForever) {//永久嵌入
            }else {
                self.selectedDay = self.getDaysArray()[row]
            }
        }
        resetDateObj()
        self.selectedDateBlock?(self.dateObject)
    }
    
    private func resetDateObj() {
        if (selectedYear == tagForever) {
            dateObject.year  = 0;
            dateObject.month = 0;
            dateObject.day   = 0;
            dateObject.date  = nil;
            dateObject.dateString = nil;
        }else {
            let yearStr  = String(selectedYear);
            let monthStr = ((selectedMonth > 9) ? String(selectedMonth) : "0" + String(selectedMonth));
            let dayStr = ((selectedDay > 9) ? String(selectedDay) : "0" + String(selectedDay));
            dateObject.year  = selectedYear
            dateObject.month = selectedMonth
            dateObject.day   = selectedDay
            dateObject.dateString = yearStr + "-" + monthStr + "-" + dayStr;
            dateObject.date = dateObject.dateString?.bg_toDate(format: "yyyy-MM-dd");
        }
    }
}


// MARK: - row展示相关
extension BGDatePicker {
    func createLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = self.textColor
        label.font = self.textFont
        return label
    }
    
    func textForYear(at row: Int) -> String? {
        if (row < 0 || row >= self.getYearsArray().count) { return nil; }
        let value = self.getYearsArray()[row]
        if (value == tagForever) { return forever.title;}//永久嵌入
        return String(value)
    }
    
    func textForMonth(at row: Int) -> String? {
        if (row < 0 || row >= self.getMonthsArray().count) { return nil; }
        let value = self.getMonthsArray()[row]
        if (selectedYear == tagForever) { return "";} //永久嵌入
        return String(value)
    }
    
    func textForDay(at row: Int) -> String? {
        if (row < 0 || row >= self.getDaysArray().count) { return nil; }
        let value = self.getDaysArray()[row]
        if (selectedYear == tagForever) { return "";}//永久嵌入
        return String(value)
    }
    
    /// 隐藏每行的分隔线
    func cleanSeparateLine() {
        for subView1 in self.subviews {
            if #available(iOS 10, *) {
                if (subView1.frame.size.height < 1) {//取出分割线view
                    subView1.isHidden = true;//隐藏分割线
                    subView1.backgroundColor = .clear
                }
            }else {
                if subView1.isKind(of: UIPickerView.classForCoder()) {
                    for subView2 in subView1.subviews {
                        if (subView2.frame.size.height < 1) {//取出分割线view
                            subView2.isHidden = true;//隐藏分割线
                            subView2.backgroundColor = .clear
                        }
                    }
                }
            }
        }
    }
}


// MARK: - 获取每列数据
extension BGDatePicker {
    
    func getYearsArray() -> [Int] {
        objc_sync_enter(self)
        assert(minYMD.year <= maxYMD.year, "最小年 必须小于 最大年")
        var array = [Int]()
        array.append(contentsOf: minYMD.year...maxYMD.year)
        if (forever.isHas) {//永久嵌入
            array.append(tagForever)
        }
        objc_sync_exit(self)
        return array
    }
    
    func getMonthsArray() -> [Int] {
        objc_sync_enter(self)
        var from = 1
        var to = 12
        if (selectedYear == minYMD.year) {
            from = minYMD.month
        }
        if (selectedYear == maxYMD.year) {
            to = maxYMD.month
        }
        if (selectedYear == tagForever && forever.isHas) {//永久嵌入
            to = 1
        }
        var array = [Int]()
        array.append(contentsOf: from...to)
        objc_sync_exit(self)
        return array
    }
    
    func getDaysArray() -> [Int] {
        objc_sync_enter(self)
        var from = 1
        var to = 30
        switch self.selectedMonth {
        case 1,3,5,7,8,10,12:
            to = 31
        case 2:
            let runYear = ((selectedYear%4 == 0 && selectedYear%100 != 0) || selectedYear%400 == 0)
            to = runYear ? 29 : 28
        default:
            to = 30
        }
        
        if (selectedYear == minYMD.year && selectedMonth == minYMD.month) {
            from = minYMD.day
        }
        if (selectedYear == maxYMD.year  && selectedMonth == maxYMD.month) {
            to = maxYMD.day
        }
        if (selectedYear == tagForever && forever.isHas) {//永久嵌入
            to = 1
        }
        var array = [Int]()
        array.append(contentsOf: from...to)
        objc_sync_exit(self)
        return array
    }
}


// MARK: - 选中刷洗相关
extension BGDatePicker {
    func selected_reloadMonth() {//此方法内涵十足,勿动...
        let firstMonth = getMonthsArray().first ?? 1
        let lastMonth = getMonthsArray().last ?? 1;//一定last一定有值
        //获取selectedMonth的index
        self.reloadComponent(1)
        var index = 0
        if (getMonthsArray().count == 12) {//最小/最大年
            index = selectedMonth - 1;
        }else {
            if let newIndex = getMonthsArray().firstIndex(where: {$0 == selectedMonth}) {
                index = newIndex
            }else {
                if (selectedMonth > lastMonth) {//最大年
                    index = getMonthsArray().count - 1;
                }
                if (selectedMonth < firstMonth) {//最小年
                    index = 0
                }
            }
        }
        self.selectRow(index, inComponent: 1, animated: false)
        self.selectedMonth = getMonthsArray()[index]
    }
    
    func selected_reloadDay() {//此方法内涵十足,勿动...
        let firstDay = getDaysArray().first ?? 1
        let lastDay = getDaysArray().last ?? 28;//一定last一定有值
        self.reloadComponent(2)
        //1.获取前一个moth在数组中的位置,一定能找到
        var index = 0
        if let newIndex = getDaysArray().firstIndex(where: {$0 == selectedDay}) {
            index = newIndex
        }else {
            if (selectedDay > lastDay) {
                index = getDaysArray().count - 1
            }
            if (selectedDay < firstDay){
                index = 0
            }
        }
        self.selectRow(index, inComponent: 2, animated: false)
        self.selectedDay = getDaysArray()[index]
    }
}

// MARK: - forever处理了
extension BGDatePicker {
    func forever_reloadMonth() {
        let _ = getMonthsArray().count
        self.reloadComponent(1)
    }
    
    func forever_reloadDay() {
        let _ = getDaysArray().count
        self.reloadComponent(2)
    }
}

fileprivate extension Date {
    //date-->String (2019-03-12)
    func bg_toString(format: String) -> String {
        let dfmatter = DateFormatter()
        dfmatter.timeZone = TimeZone.current
        dfmatter.dateFormat = format
        let dateString = dfmatter.string(from: self)
        return dateString
    }
    
    func bg_toTuple(format: String) -> BGYearMonthDay {
        let year = Calendar.current.component(.year, from: self)
        let month = Calendar.current.component(.month, from: self)
        let day = Calendar.current.component(.day, from: self)
        return (year, month, day);
    }
}

fileprivate extension String {
    func bg_toDate(format: String) -> Date? {
        let dfmatter = DateFormatter()
        dfmatter.timeZone = TimeZone.current
        dfmatter.dateFormat = format
        let date = dfmatter.date(from: self)
        return date
    }
}
