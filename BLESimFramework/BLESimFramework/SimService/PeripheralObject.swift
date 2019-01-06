//
//  PeripheralObject.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/26/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

//This object is designed for advertisement result/callback
 struct PeripheralObject {
    let peripheral:CBPeripheral
    let rssi:Int
    let advData:[String:Any]
    
    init( _ peripheral:CBPeripheral, rssi:Int, adv:[String:Any]){
        self.peripheral = peripheral
        self.rssi = rssi
        self.advData = adv
    }
}
