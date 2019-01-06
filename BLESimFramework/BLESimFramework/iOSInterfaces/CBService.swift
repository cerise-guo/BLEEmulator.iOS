//
//  CBService.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/3/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation
open class CBService : CBAttribute{
    
    public enum SERVICE_TYPE: String {
        case HEART_RATE_MONITOR = "0000180d-0000-1000-8000-00805f9b34fb"
        case BATTERY_LEVEL = "0000180F-0000-1000-8000-00805f9b34fb"
    }
    
    fileprivate(set) var primary:Bool
    
    unowned(unsafe) open private(set) var peripheral: CBPeripheral
    
    /*
    internal override init(){
        primary = false
        
        super.init()
    }*/
    
    internal init( type UUID: CBUUID, primary isPrimary:Bool, peripheral:CBPeripheral ){
        primary = isPrimary
        self.peripheral = peripheral
        
        super.init( uuid: UUID )
    }
    
    fileprivate var mCharacteristics:[CBCharacteristic] = []
    
    public func setCharacteristic( characteristics:CBCharacteristic){
        
        //ToDo: before appending, check whether being linked already.
        mCharacteristics.append(characteristics)
    }
    
    open var characteristics: [CBCharacteristic]? { get{
        return mCharacteristics
        }
    }
}
