//
//  CBSimPeripheral.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 11/28/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

class CBSimPeripheral: CBPeripheral {
    
    let type:PeripheralFactory.PeripheralType
    
    init(type:PeripheralFactory.PeripheralType, name:String){
        self.type = type
        
        super.init(name: name)
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    required public init(name: String) {
        fatalError("init(name:) has not been implemented")
    }
}
