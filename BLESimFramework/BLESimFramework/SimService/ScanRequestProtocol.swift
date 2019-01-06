//
//  CentralRequestHandler.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/21/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public protocol ScanRequestProtocol{
    
    func scan( _ manager: CBCentralManager? )
    
    func stopScan()
}
