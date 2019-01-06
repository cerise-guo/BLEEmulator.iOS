//
//  CentralService.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/8/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public typealias DispatchBlock = ( _ request:CentralRequest, _ manager:CBCentralManager) -> Bool;

class CBCentralManagerService{
    
    //ToDo: make this static, so the created peripheral object can be kept and reused.
    fileprivate var centralManagers = Dictionary<UUID,Weak<CBCentralManager>>()
    
    //private var dispatchBlock:DispatchBlock
    
    var centralRequestQueue:DispatchQueue
    let requestQueueName:String = "requestQueue"
    
    var scanHandler:ScanRequestProtocol?

    fileprivate var connectionHandlers = Dictionary<UUID, ConnectRequestProtocol>()
    
    class func sharedInstance() -> CBCentralManagerService {
        return createService
    }
    
    fileprivate static var createService: CBCentralManagerService = {
        GLog.d( "create CBCentralManager service" )
        let service = CBCentralManagerService()
        
        return service;
    }()
    
    fileprivate init(){
        GLog.d()
        
        //The queue by default is serial so the task will be executed as the order it was added.
        centralRequestQueue = DispatchQueue( label: requestQueueName, qos: DispatchQoS.userInitiated )
    }
    
    var tempUUID:UUID?
    
    func register( centralManager: CBCentralManager ){
        GLog.d( "register : \(centralManager.uuid)" )
        
        
        tempUUID = centralManager.uuid
        
        if nil == self.centralManagers[centralManager.uuid] {
            centralManagers[centralManager.uuid] = Weak(value: centralManager )
            centralManager.requestBlock = self.DispatchMessage
            
            GLog.d("central manager \(centralManager.uuid) is added now.")
        }else{
            GLog.d("manager had been added before.")
        }
    }
    
    //This function only validates the manager, does nothing else.
    private func validateManager( manager:CBCentralManager){
        
        //The manager should be created through the designated ctor,
        //so the manager should have been saved in the dictionary.
        if let mgr = self.centralManagers[manager.uuid]{
            if let centralMgr = mgr.get(){
                assert( centralMgr.hashValue == manager.hashValue )
            }else{
                GLog.d("nil central manager.")
                assert(false)
            }
        }else{
            GLog.d("unknown central manager.")
            assert(false)
        }
    }
    
    private func DispatchMessage(request:CentralRequest, manager:CBCentralManager)->Bool
    {
        GLog.d()
        
        centralRequestQueue.async{
            switch request{
            case .SCAN(let serviceUUIDs, let options):
                GLog.d("scan request : \(String(describing: serviceUUIDs)), \(String(describing: options))")
                
                //Create new scan handler, the previous one, if exist, will stop scan response.
                self.scanHandler = ScanRequestHandler()
                
                //So far, I can only image one app should initate one central manager.
                assert( 1 == self.centralManagers.count )
                
                //weak var centralMgr = manager
                
                self.validateManager(manager: manager)
                
                self.scanHandler!.scan( manager )
                
            case .STOP_SCAN:
                GLog.d("stop scan request")
                
                if( nil != self.scanHandler ){
                    self.scanHandler?.stopScan()
                    self.scanHandler = nil
                }
                
            case .CONNECT(let peripheral, let options):
                GLog.d("connect request")
                
                var connectHandler:ConnectRequestProtocol?
                if let handler = self.connectionHandlers[peripheral.identifier] {
                    connectHandler = handler
                }else{
                    connectHandler = ConnectRequestHandler()
                    self.connectionHandlers[peripheral.identifier] = connectHandler
                }
                assert(nil != connectHandler)

                self.validateManager(manager: manager)
                
                //Stop existing connection attempt if any
                //ToDo: if connection has been estabished, just return success directly, need not to disconnect first
                connectHandler!.disconnect( cbmanager: manager, peripheral: peripheral )
                
                connectHandler!.connect(cbmanager: manager, peripheral: peripheral, options: options ){_ in
                    
                    //Should NOT remove the connection handler from connectionHandlers, since we need it
                    //to call caller's disconnection callback later.
                    //After connection, remove the strong reference
                    //Bad action: self.connectionHandlers[peripheral.identifier] = nil
                }

            case .DISCONNECT( let peripheral ):
                GLog.d("disconnect request")
                
                if let handler = self.connectionHandlers[peripheral.identifier] {
                    self.connectionHandlers[peripheral.identifier] = nil
                    
                    self.validateManager(manager: manager)
                    handler.disconnect(cbmanager: manager, peripheral: peripheral)
                }else{
                    GLog.d("can not find disconnection handler")
                }
            }
        }
        
        return true
    }
}
