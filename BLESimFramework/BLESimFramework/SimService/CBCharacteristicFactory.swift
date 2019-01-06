//
//  CBCharacteristicFactory.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 11/4/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

internal class CBCharacteristicFactory{
    
    fileprivate static var factory = createInstance()
    
    fileprivate static func createInstance()->CBCharacteristicFactory {
        GLog.d()
        return CBCharacteristicFactory()
    }
    
    public static var getInstance:CBCharacteristicFactory{
        get{
            return factory
        }
    }
    
    fileprivate static var characters = Dictionary<CBUUID, CBCharacteristic>()
    
    public func createCharacteristic( characterUUID:CBUUID, service:CBService ) -> CBCharacteristic{

        //Note: do NOT add the new charactertistic to service here. The adding is not a responsibility
        //or knowledge of this function.
        
        let character = CBCharacteristic(uuid: characterUUID, service:service)
        GLog.d("created characteristic : \(character.uuid)")
        
        return character
    }
}
