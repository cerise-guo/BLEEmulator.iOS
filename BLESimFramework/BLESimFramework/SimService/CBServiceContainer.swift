//
//  CBServiceContainer.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 11/29/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public class CBServiceContainer{
    
    fileprivate var servicelDict = Dictionary<String,CBService>()
    
    public static var instance:CBServiceContainer {
        get {
            return container
        }
    }
    
    fileprivate static var container = createContainer()
    
    fileprivate static func createContainer()-> CBServiceContainer {
        GLog.d( "create CBServiceContainer" )
        return CBServiceContainer()
    }
    
    fileprivate init() {}
    
    func register( service: CBService ){
        GLog.d( "register : \(service.uuid)" )
        
        if nil == self.servicelDict[service.uuid.uuidString] {
            self.servicelDict[service.uuid.uuidString] = service
            
            GLog.d("CBService \(service.uuid.uuidString) is added now.")
        }else{
            assert(false) //May not be a issue, just want to know when it is triggered
            
            GLog.d("service had been added before.")
        }
    }
    
    func get( uuid:CBUUID )->CBService?{
        
        for( _, service ) in servicelDict {
            if( service.uuid == uuid ){
                return service;
            }
        }
        
        return nil
    }
}
