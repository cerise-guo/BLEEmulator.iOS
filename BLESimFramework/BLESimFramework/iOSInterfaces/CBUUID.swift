//
//  CBUUID.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 4/16/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

@available(iOS 5.0, *)
open class CBUUID : NSObject {

    fileprivate let stringValue:String
    
    //line 93
    open var uuidString: String { get {
        return stringValue
        }
    }
    
    //line 104
    public /*not inherited*/ init(string theString: String){
        stringValue = theString
    }
    
    //line 136
    public init(nsuuid theUUID: UUID){
        stringValue = theUUID.uuidString
    }
    
    //line 114
    public /*not inherited*/ init(data theData: Data){
        stringValue = (String(data:theData, encoding:String.Encoding.utf8) as String?)!
    }
    
    override open var hashValue : Int {
        return uuidString.hashValue;
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        if let other = object as? CBUUID {
            return self.uuidString == other.uuidString
        } else {
            return false
        }
    }
}
