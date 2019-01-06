//
//  CBError.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 12/25/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public struct CBError {
    
    public enum Code : Int {
        
        /*!
         * @enum CBError
         *
         * @discussion The possible errors returned during LE transactions.
         */
        public typealias _ErrorType = CBError
        
        case unknown
        case invalidParameters
        case invalidHandle
        case notConnected
        case outOfSpace
        case operationCancelled
        case connectionTimeout
        case peripheralDisconnected
        case uuidNotAllowed
        case alreadyAdvertising
        case connectionFailed
        case connectionLimitReached
        case unkownDevice
    }
    
    public static var unknown: CBError.Code {
        get{return CBError.Code.unknown }
    }

    @available(iOS 6.0, *)
    public static var invalidParameters: CBError.Code {
        get{return CBError.Code.invalidParameters}
    }
    
    @available(iOS 6.0, *)
    public static var invalidHandle: CBError.Code {
        get{return CBError.Code.invalidHandle}
    }
    
    @available(iOS 6.0, *)
    public static var notConnected: CBError.Code {
        get{return CBError.Code.notConnected}
    }
    
    @available(iOS 6.0, *)
    public static var outOfSpace: CBError.Code {
        get{return CBError.Code.outOfSpace}
    }
    
    @available(iOS 6.0, *)
    public static var operationCancelled: CBError.Code {
        get{return CBError.Code.operationCancelled}
    }
    
    @available(iOS 6.0, *)
    public static var connectionTimeout: CBError.Code {
        get{return CBError.Code.connectionTimeout}
    }
    
    @available(iOS 6.0, *)
    public static var peripheralDisconnected: CBError.Code {
        get{return CBError.Code.peripheralDisconnected}
    }
    
    @available(iOS 6.0, *)
    public static var uuidNotAllowed: CBError.Code {
        get{return CBError.Code.uuidNotAllowed}
    }
    
    @available(iOS 6.0, *)
    public static var alreadyAdvertising: CBError.Code {
        get{return CBError.Code.alreadyAdvertising}
    }
    
    @available(iOS 7.1, *)
    public static var connectionFailed: CBError.Code {
        get{return CBError.Code.connectionFailed}
    }
    
    @available(iOS 9.0, *)
    public static var connectionLimitReached: CBError.Code {
        get{return CBError.Code.connectionLimitReached}
    }
    
    @available(iOS 9.0, *)
    public static var unkownDevice: CBError.Code {
        get{return CBError.Code.unkownDevice}
    }
}
