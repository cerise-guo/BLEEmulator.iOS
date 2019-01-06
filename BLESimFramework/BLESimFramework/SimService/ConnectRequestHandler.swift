//
//  ConnectRequestHandler.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/7/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public class ConnectRequestHandler  : ConnectRequestProtocol {

    //ID used to identify this instance
    let id = arc4random()
    
    fileprivate var completed:Bool = false
    
    private var timer: DispatchSourceTimer?
    
    private let CONNECTION_DELAY:Int = 2; //sec
    private let DISCONNECTION_DELAY:Int = 1; //sec
    
    deinit {
        GLog.d( "id: \(id)")
        timer?.cancel()
        timer = nil
    }
    
    init(){
        GLog.d("init: \(id)")
        
        timer?.cancel()
        timer = nil
    }
    
    //This is used to determine whether this handler object can be recycled
    public var isCompleted:Bool{
        get{
            return completed
        }
    }

    //If need delay of scan response, put here.
    public func connect( cbmanager:CBCentralManager?, peripheral:CBPeripheral, options:[String : Any]?, complete:@escaping (String?) -> Void){
        GLog.d("connect : \(peripheral.identifier)")
        
        if(( cbmanager?.centralMgrDelegate ) == nil){
            GLog.d("no delegate, will do nothing")
            return;
        }
        
        //ToDo: if there is in-progress connecting already, what to do ?
        timer?.cancel()        // cancel previous timer if any
        timer = nil

        timer = DispatchSource.makeTimerSource(queue: cbmanager!.dispatchCallbackQueue)
        let time = DispatchTime.now() + DispatchTimeInterval.seconds(CONNECTION_DELAY);
        timer?.schedule(deadline:time,  repeating: .never, leeway: .milliseconds(2000))

        timer?.setEventHandler {
            GLog.d("will return connection result")
            
            cbmanager?.centralMgrDelegate?.centralManager!(cbmanager!, didConnect: peripheral)
            
            complete("")
        }
        timer?.resume()
    }
    
    public func disconnect( cbmanager:CBCentralManager?, peripheral:CBPeripheral){
        GLog.d("disconnect: \(peripheral.identifier) , \(String(describing: timer))")
        
        timer?.cancel()
        timer = nil

        cbmanager!.dispatchCallbackQueue.async {
            GLog.d("call disconnect callback")
            cbmanager?.centralMgrDelegate?.centralManager!(cbmanager!, didDisconnectPeripheral: peripheral, error: nil)
        }

        self.completed = true
    }
}
