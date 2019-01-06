//
//  CBCharacteristicContainer.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 11/30/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public class CBCharacteristicContainer{
    
    fileprivate var chracterDict = Dictionary<String, CBCharacteristic>()
    
    class func sharedInstance() -> CBCharacteristicContainer {
        return createContainer
    }
    
    fileprivate static var createContainer: CBCharacteristicContainer = {
        GLog.d( "create CBCharacteristicContainer" )
        let container = CBCharacteristicContainer()
        return container;
    }()
    
    fileprivate init() {}
    
    func register( character: CBCharacteristic ){
        GLog.d( "register : \(character.uuid.uuidString)" )
        
        if nil == self.chracterDict[character.uuid.uuidString] {
            self.chracterDict[character.uuid.uuidString] = character
            
            GLog.d("Characteristic \(character.uuid.uuidString) is added now.")
        }else{
            assert(false) //May not be a issue, just want to know when it is triggered
            
            GLog.d("character had been added before.")
        }
    }
    
    func get( uuid:CBUUID )->CBCharacteristic?{

        for( _, character ) in chracterDict {
            if( character.uuid == uuid ){
                return character
            }
        }
        
        return nil
    }
}
