//
//  CBAttribute.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/4/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation
open class CBAttribute : NSObject {
    
    fileprivate var mUUID:CBUUID = CBUUID( nsuuid: UUID() )
    
    public init( uuid:CBUUID ) {
        GLog.d("CBUUID init with: \(uuid.uuidString)")
        mUUID = uuid
    }
    
    public override init() {
        super.init()
    }
    
    open var uuid: CBUUID { get{
        
        //this CBUUID is not the CBUUID.stringValue which was used to initiate the CBUUID.
        //the output value from this CBUUID is not its string value during initialization.
        
        return mUUID
        }
    }
}
