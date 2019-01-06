//
//  CBPeripheralRequest.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/7/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public enum PeripheralRequest {

    case DISCOVER_SERVICE

    case DISCOVER_CHARACTERISTIC( CBService )
    
    case SET_NOTIFICATION( CBUUID, Bool )
    
    case READ_VALUE( CBUUID )
    
    case WRITE_VALUE( CBUUID, Data, CBCharacteristicWriteType )
    
}
