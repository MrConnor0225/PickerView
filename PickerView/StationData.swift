//
//  DrinksData.swift
//  PickerView
//
//  Created by Connor on 2020/11/2.
//

import Foundation

struct StationData:Decodable {
    // 用來decode station.plist資料
    var stationDictionary:[String:[String]]
}
