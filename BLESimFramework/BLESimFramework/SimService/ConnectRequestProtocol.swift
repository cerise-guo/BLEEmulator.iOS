//
//  ConnectRequestProtocol.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/7/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public protocol ConnectRequestProtocol{
    
    typealias CompletionBlock = (String?) -> Void
    
    func connect( cbmanager:CBCentralManager?, peripheral:CBPeripheral, options:[String : Any]?, complete:@escaping CompletionBlock)
    
    func disconnect( cbmanager:CBCentralManager?, peripheral:CBPeripheral)
}
