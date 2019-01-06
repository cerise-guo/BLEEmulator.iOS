//
//  PeripheralFactory.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/3/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

class PeripheralFactory{
    
    enum PeripheralType {
        case HeartRateMonitor
        case CGM
    }
    
    class func sharedInstance() -> PeripheralFactory {
        return createFactory
    }
    
    fileprivate static var createFactory: PeripheralFactory = {
        GLog.d( "create peripheral factory" )
        let factory = PeripheralFactory()
        
        return factory;
    }()

    fileprivate init(){
        GLog.d()
    }
    
    public func createPeripheral( type:PeripheralType )->CBPeripheral {
    
        switch( type ){
        case .HeartRateMonitor:
            return createHeartRateMonitor()
        case .CGM:
            return createCGM()
        }
    }
    
    private func createHeartRateMonitor()->CBPeripheral{
        //let p1 = CBPeripheral(name: "iPod Touch")
        //let p1 = CBSimPeripheral( type:PeripheralFactory.PeripheralType.HeartRateMonitor ,name: "G5")
        //let advData:[String:Any] = ["CBAdvertisementDataServiceUUIDsKey":1234,"key2":"5678"]
        //return PeripheralObject(p1, type:PeripheralType.HeartRateMonitor, rssi: 30, adv: advData)
        GLog.d()
        return CBSimPeripheral( type:PeripheralFactory.PeripheralType.HeartRateMonitor ,name: "G5")
    }
    
    private func createCGM()->CBPeripheral{
        //let p1 = CBSimPeripheral(type:PeripheralFactory.PeripheralType.CGM, name: "My CGM")
        //let advData:[String:Any] = ["CBAdvertisementDataServiceUUIDsKey":24680,"key2":"112233"]
        //return PeripheralObject(p1, type: PeripheralType.CGM, rssi: 30, adv: advData)
        GLog.d()
        return CBSimPeripheral(type:PeripheralFactory.PeripheralType.CGM, name: "My CGM")
    }
}
