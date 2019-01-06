//
//  GLogger.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/19/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

class GLog{
    
    static public func d( _ message: String = "", functionName:String = #function, fileName:String = #file, lineNum:Int = #line ){
        let className = (fileName as NSString).lastPathComponent
        
        NSLog( "\(className): \(functionName): \(lineNum): \(message)" )
    }
    
    static public func w( _ message: String = "", functionName:String = #function, fileName:String = #file, lineNum:Int = #line ){
        let className = (fileName as NSString).lastPathComponent
        
        NSLog( "\(className): \(functionName): \(lineNum): Warning : \(message)" )
    }
}
