//
//  CBPeer.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/20/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

@available(iOS 8.0, *)
open class CBPeer : NSObject, NSCopying {
    
    required override public init() {
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        return copy
    }
    
    open private(set) var identifier:UUID = UUID()
    
    /*!
     *  @property identifier
     *
     *  @discussion The unique, persistent identifier associated with the peer.
     */
    //@available(iOS 7.0, *)
    /*open var identifier: UUID {
        get
        {
            //return UUID(uuidString: "abcdefg")!
            return identifier
        }
    }*/
}
