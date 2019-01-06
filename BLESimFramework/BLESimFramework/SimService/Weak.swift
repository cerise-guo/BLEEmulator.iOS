//
//  Weak.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/26/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

//A wrapper for weak reference to work with containers.
struct Weak <T:AnyObject> {
    weak var obj:T?
    
    init( value:T ){
        self.obj = value
    }
    
    func get()->T?{
        return obj
    }
}
