//
//  CBCharacteristic.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/4/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

open class CBCharacteristic : CBAttribute {
    
    private var mValue:Data?
    
    unowned(unsafe) open private(set) var service: CBService
    
    internal init( uuid:CBUUID, service:CBService ) {
        self.service = service
        self.isNotifying = false
        super.init(uuid: uuid)
        
        //Note: do NOT add the new charactertistic to service here. The adding is not a responsibility
        //or knowledge of this function.
    }
    
    //LINE 94
    open var value: Data? {
        get{
            return mValue
        }        
    }
    
    internal func setValue( data:Data ){
        mValue = data
    }
    
    //125
    open private(set) var isNotifying: Bool
    
    internal func setNotifying( notify:Bool ){
        isNotifying = notify
    }
}
