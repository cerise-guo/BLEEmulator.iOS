//
//  CBCentralMgrRequest.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/21/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public enum CentralRequest {
    case SCAN([CBUUID]?, [String : Any]?)
    
    case STOP_SCAN
    
    case CONNECT( CBPeripheral, [String : Any]?)
    
    case DISCONNECT( CBPeripheral )
}
