//
//  CBPeripheralDelegate.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/9/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public protocol CBPeripheralDelegate : NSObjectProtocol {
    
    //line 343
    //@available(iOS 5.0, *)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    
    //line 372
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    
    //line 385
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    
    //line 398
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    
    //411
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
}


extension CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        GLog.d("default empty CBPeripheralDelegate didDiscoverServices")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        GLog.d("default empty CBPeripheralDelegate didDiscoverCharacteristicsFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        GLog.d("default empty CBPeripheralDelegate didUpdateNotificationStateFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        GLog.d("default empty CBPeripheralDelegate didUpdateValueFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        GLog.d("default empty CBPeripheralDelegate didWriteValueFor")
    }
}

