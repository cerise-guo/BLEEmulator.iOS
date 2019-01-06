//
//  PeripheralContainer.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/5/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

class PeripheralContainer{
    
    //ToDo: make this static, so the created peripheral object can be kept and reused.
    fileprivate var peripheralDict = Dictionary<String,CBPeripheral>()
    
    class func sharedInstance() -> PeripheralContainer {
        return createContainer
    }
    
    fileprivate static var createContainer: PeripheralContainer = {
        GLog.d( "create PeripheralContainer" )
        let container = PeripheralContainer()        
        return container;
    }()
    
    fileprivate init() {}
    
    func register( peripheral: CBPeripheral ){
        GLog.d( "register : \(peripheral.identifier)" )
        
        if nil == self.peripheralDict[peripheral.identifier.uuidString] {
            self.peripheralDict[peripheral.identifier.uuidString] = peripheral
            
            GLog.d("peripheral \(peripheral.identifier.uuidString) is added now.")
        }else{
            assert(false) //May not be a issue, just want to know when it is triggered
            
            GLog.d("peripheral had been added before.")
        }
    }
    
    func get( type:PeripheralFactory.PeripheralType )->CBPeripheral?{
        
        for( _, peripheral ) in peripheralDict {
            
            if let device = peripheral as? CBSimPeripheral{
                
                if( device.type == type ){
                    return peripheral
                }
            }else{
                assert(false) //all peripheral shall be CBSimPeripheral
            }
        }
        
        return nil
    }
    
    public var peripheralCount:Int {
        get{
            return peripheralDict.count;
        }
    }
    
}
