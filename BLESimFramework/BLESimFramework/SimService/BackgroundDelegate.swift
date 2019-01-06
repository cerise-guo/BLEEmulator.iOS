//
//  BackgroundDelegate.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 12/28/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public class BackgroundDelegate : NSObject
{
    fileprivate static var delegate = createInstance()
    
    fileprivate static func createInstance()->BackgroundDelegate {
        GLog.d()
        return BackgroundDelegate()
    }
    
    public static var instance:BackgroundDelegate{
        get{
            return delegate
        }
    }
    
    @objc dynamic var changed:Bool = false
    
    private override init(){
        GLog.d()
        super.init()
        
        //addObserver(self, forKeyPath: #keyPath(changed), options: [.old, .new], context: nil)
        addObserver(SimCBPeripheralImpl.instance, forKeyPath: #keyPath(changed), options: [.old, .new], context: nil)
        
        //ToDo: when to remove observer, whether need to remove observer.
        //removeObserver(SimCBPeripheralManagerDelegate.instance, forKeyPath: #keyPath(changed))
    }
    
    public func trigger(){
        changed = !changed
    }
}
