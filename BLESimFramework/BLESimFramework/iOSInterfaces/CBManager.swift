//
//  CBManager.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 4/16/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
open class CBManager : NSObject {
    
    
    /*!
     *  @enum CBManagerState
     *
     *  @discussion Represents the current state of a CBManager.
     *
     *  @constant CBManagerStateUnknown       State unknown, update imminent.
     *  @constant CBManagerStateResetting     The connection with the system service was momentarily lost, update imminent.
     *  @constant CBManagerStateUnsupported   The platform doesn't support the Bluetooth Low Energy Central/Client role.
     *  @constant CBManagerStateUnauthorized  The application is not authorized to use the Bluetooth Low Energy role.
     *  @constant CBManagerStatePoweredOff    Bluetooth is currently powered off.
     *  @constant CBManagerStatePoweredOn     Bluetooth is currently powered on and available to use.
     *
     */
    
    /*!
     *  @property state
     *
     *  @discussion The current state of the manager, initially set to <code>CBManagerStateUnknown</code>.
     *                Updates are provided by required delegate method {@link managerDidUpdateState:}.
     *
     */
    open var state: CBManagerState {
        get { return CBManagerState.unknown }
    }
}

@available(iOS 10.0, *)
public enum CBManagerState : Int {
    
    case unknown
    
    case resetting
    
    case unsupported
    
    case unauthorized
    
    case poweredOff
    
    case poweredOn
}
