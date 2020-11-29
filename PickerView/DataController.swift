//
//  DataController.swift
//  PickerView
//
//  Created by Connor on 2020/11/2.
//

import Foundation

struct DataController {
    static let shared = DataController()
    let dateFormatter = DateFormatter()
    
    // 設定日期picker data
    func fetchDateData() -> [String] {
        let today = Date()
        var dates = [today]
        let secondsOfDay = 60 * 60 * 24
        for dateCount in 1 ... 30 {
            let date = today.timeIntervalSinceNow + ( Double(secondsOfDay * dateCount) )
            dates.append(Date(timeIntervalSinceNow: date))
        }
        
        let datesArray:[String]
        datesArray = dates.map({ (date) -> String in
            // 格式化每一天的日期格式
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        })
        return datesArray
    }
    
    // 時間小時
    func fetchHoursData() -> [String]{
        var hours = [String]()
        for hour in 1 ... 24 {
            hours.append("\(hour)時")
        }
        return hours
    }
    
    // 時間分鐘
    func fetchMinsData() -> [String]{
        var mins = [String]()
        for min in 0 ... 59 {
            if min < 10 {
                mins.append("0\(min)分")
            }else {
                mins.append("\(min)分")
            }
        }
        return mins
    }

    
    // 車站picker data,從plist取得
    func fetchStation() -> [String:[String]]? {
        let stationDataUrl = Bundle.main.url(forResource: "Station", withExtension: "plist")!
        
        // 1. 從plist取得的URL轉為data
        // 2. 再利用PropertyListDecoder將data轉為想要的格式資料
        guard let data = try? Data(contentsOf: stationDataUrl),
              let stations = try? PropertyListDecoder().decode([String:[String]].self, from: data) else { return nil }
        return stations
    }
}
