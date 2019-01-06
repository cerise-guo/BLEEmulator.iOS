//
//  CBServiceFactory.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/27/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public class CBServiceFactory{
    
    fileprivate static var factory = createInstance()
    
    fileprivate static func createInstance()->CBServiceFactory {
        GLog.d()
        return CBServiceFactory()
    }
    
    public static var getInstance:CBServiceFactory{
        get{
            return factory
        }
    }
    
    public func createServiceWithUUID( _ type:CBService.SERVICE_TYPE, peripheral:CBPeripheral) -> CBService{
        GLog.d("create new service: " + type.rawValue )
        
        let service = CBService(
            type: CBUUID(string:type.rawValue),
            primary: true,
            peripheral: peripheral)
        
        return service
    }
}
