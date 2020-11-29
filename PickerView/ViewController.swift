//
//  ViewController.swift
//  PickerView
//
//  Created by Connor on 2020/11/2.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var stationTextField: UITextField!
    
    var pickerField = UITextField()
    var dates = [String]()
    var hours = [String]()
    var mins = [String]()
    var cities = [String]()
    var stationDictionary = [String:[String]]()
    
    // 選擇textfield上的變數
    var selectedDate = ""
    var selectedHour = ""
    var selectedMin = ""
    var cityRow = 0
    var stationRow = 0
    // 避免點選車站時直接點擊確認而沒有值
    var selectedCity = "01基隆市"
    var selectedStation = "三坑"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTextField.delegate = self
        timeTextField.delegate = self
        stationTextField.delegate = self
        loadData()
    }
    
    func loadData(){
        dates = DataController.shared.fetchDateData()
        hours = DataController.shared.fetchHoursData()
        mins = DataController.shared.fetchMinsData()
        guard let stationDictionary = DataController.shared.fetchStation()
            else { return }
        self.stationDictionary = stationDictionary
        stationDictionary.keys.forEach { (city) in
            cities.append(city)
        }
        cities.sort()
    }
    
    func initPickerView(touchAt sender:UITextField){
        let pickerView = UIPickerView()
        // 依照點選不同的textField取出對應的pickView並給予tag
        // 到時候再依 tag 來撈出相對應資料
        switch sender {
        case dateTextField:
            pickerView.tag = 0
        case timeTextField:
            pickerView.tag = 1
        case stationTextField:
            pickerView.tag = 2
        default:
            pickerView.tag = 0
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 設定pickerView上方的toolbar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        // 讓toolbar自動調整合適於pickerView尺吋
        toolBar.sizeToFit()
    
        // 設定toolbar內的button
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(clickCancelButton))
        // 中間空白的部份
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "確認", style: .plain, target: self, action: #selector(clickDoneButton))
        
        toolBar.setItems([cancelButton, spaceItem, doneButton], animated: false)
        
        // 設定toobar可以使用
        toolBar.isUserInteractionEnabled = true
        //初始化textfield
        pickerField = UITextField(frame: CGRect.zero)
        
        // 將pickerField加到畫面上
        view.addSubview(pickerField)
        // 將pickerField輸入view改為pickerView
        pickerField.inputView = pickerView
        // 將toolbar設定在pickerField裡面
        pickerField.inputAccessoryView = toolBar
        // 彈出pickerField在點擊的欄位
        pickerField.becomeFirstResponder()
    }
    
    @objc func clickCancelButton(){
        self.pickerField.resignFirstResponder()
    }
    
    @objc func clickDoneButton(){
        let pickerViewTag = pickerField.inputView?.tag
        switch pickerViewTag {
        case 0:
            DispatchQueue.main.async { [self] in
                self.dateTextField.text = "\(selectedDate)"
            }
        case 1:
            DispatchQueue.main.async { [self] in
                self.timeTextField.text = "\(selectedHour) \(selectedMin)"
            }
        case 2:
            DispatchQueue.main.async { [self] in
                let index = selectedCity.index(selectedCity.startIndex, offsetBy: 2)
                // 去掉city前面的數字
                let cityName = String(selectedCity.suffix(from: index))
                self.stationTextField.text = "\(cityName) - \(selectedStation)"
            }
        default:
            pickerField.resignFirstResponder()
        }
        pickerField.resignFirstResponder()
        
    }
    

}


extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // 依pickerview的tag決定有幾個components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
            case 0:
                return 1
            case 1:
                return 2
            case 2:
                return 2
            default:
                return 1
        }

    }
    
    // component要顯示的內容data row
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 0:
            return dates.count
        case 1:
            if component == 0 {
                return hours.count
            } else {
                return mins.count
            }
        case 2:
            // 由於車站會有兩個component(city and station)
            // 所以各自設定不同的row數
            if component == 0 {
                return cities.count
            } else {
                // 取得第一個component(city)停留在哪一個row
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                return stationDictionary[cities[selectedRow]]!.count
            }
        default:
            return 0
        }
        
    }
    
    // 設定呈現的資料
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return dates[row]
        } else if pickerView.tag == 1 {
            if component == 0 {
                return hours[row]
            } else if component == 1 {
                return mins[row]
            }
        } else if pickerView.tag == 2 {
            if component == 0 {
                let trimNumberOfCity = cities.map { (city) -> String in
                    let index = city.index(city.startIndex, offsetBy: 2)
                    return String(city.suffix(from: index))
                }
                return trimNumberOfCity[row]
            } else if component == 1{
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                let stations = stationDictionary[cities[selectedRow]]
                return stations?[row]
            }
        }
        return nil
    }
    
    
    // pickerview row 點擊的資料
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            selectedDate = dates[row]
            
        } else if pickerView.tag == 1 {
            if component == 0 {
                selectedHour = hours[row]
            } else if component == 1 {
                selectedMin = mins[row]
            }

        } else if pickerView.tag == 2 {
            // station data是會隨著切換city而變化
            // 所以加上reloadComponent
            // component(0) → city； component(1) → station
            pickerView.reloadComponent(1)
            if component == 0 {
                cityRow = row
                self.selectedCity = cities[cityRow]
                let stationByCity = stationDictionary[selectedCity]!
            
                self.selectedStation = stationByCity[0]
            } else if component == 1 {
                stationRow = row
                let stationByCity = stationDictionary[cities[cityRow]]!
                if stationRow > stationByCity.count {
                    stationRow = 0
                }
                self.selectedStation = stationByCity[stationRow]
            }
    
        }
    
    }
}


extension ViewController: UITextFieldDelegate {
    // 點擊textField即跳出pickerView
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            // 依點擊的textField去初始化對應的pickerView
            self.initPickerView(touchAt: textField)
        }
    }
    // 加入這方法點擊欄位外的地方會自動將pickerView收起來
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
