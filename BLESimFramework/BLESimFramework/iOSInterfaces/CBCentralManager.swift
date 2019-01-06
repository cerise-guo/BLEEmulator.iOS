//
//  CBCentralManager.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 4/16/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

open class CBCentralManager : CBManager {
    
    internal let uuid:UUID = UUID()
    
    var _dispatchBlock: DispatchBlock?
        
    let dispatchQueueName:String = "CMDispatchQueue"
    
    //This queue receives the BLE request from user, it should be efficient and not blocked.
    let requestQueue:DispatchQueue
    let requestQueueName:String = "CMRequestQueue"
    
    let dispatchCallbackQueue:DispatchQueue
    let centralMgrDelegate:CBCentralManagerDelegate?
    
    //line102
    @available(iOS 7.0, *)
    public init(delegate: CBCentralManagerDelegate?, queue: DispatchQueue?, options: [String : Any]? = nil){
        
        if( nil == queue ){
            //By default, the dispatch queue is main queue as official document
            dispatchCallbackQueue = DispatchQueue.main
        }else{
            dispatchCallbackQueue = queue!
        }
        
        centralMgrDelegate = delegate
        
        //The queue by default is serial so the task will be executed as the order it was added.
        requestQueue = DispatchQueue( label: requestQueueName, qos: DispatchQoS.userInitiated )
        
        isScanning = false
        
        super.init()
        GLog.d("init(delegate, queue,options)")
        
        let cbcmService = CBCentralManagerService.sharedInstance()
        cbcmService.register( centralManager: self )
    }
    
    public var requestBlock:DispatchBlock {
        set(newValue) {
            GLog.d()
            if self._dispatchBlock != nil {
                assert(false)
                GLog.d("should not set block twice.")
            }else{
                self._dispatchBlock = newValue
            }
        }
        get{
            assert(false)
            GLog.d("don't expect to get, it is used internally only")
        }
    }
    
    //line 67
    //@available(iOS 9.0, *)
    private(set) open var isScanning: Bool
    
    //line 151
    open func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil){
        GLog.d("scanForPeripherals - UUID: \(String(describing: serviceUUIDs))" )
        
        //Set the scanning status in case the caller check it immediately.
        //ToDo: this could be a potential issue if the scan failure is simulated in the CentralService,
        //where this isScanning flag won't reflect the truth.
        self.isScanning = true
        
        self.requestQueue.async { [weak self] in
            GLog.d("scan in request queue")
        
            //monitor the async queue to avoid unexpected execution order
            assert((self?.isScanning)!)
            
            let scanRequest = CentralRequest.SCAN(serviceUUIDs, options)
            let result = self?._dispatchBlock!( scanRequest, self!)
            assert(result!)
        }
    }
    
    //line 160
    open func stopScan(){
        GLog.d("stopScan()")
        
        //Set the scanning status in case the caller check it immediately.
        //ToDo: this could be a potential issue if the stop failure is simulated in the CentralService,
        //where this isScanning flag won't reflect the truth.
        self.isScanning = false
        
        self.requestQueue.async { [weak self] in
            GLog.d("queue stop scan request")
            
            //monitor the async queue to avoid unexpected execution order
            assert(!(self?.isScanning)!)
            
            let scanRequest = CentralRequest.STOP_SCAN
            let result = self?._dispatchBlock!( scanRequest, self!)
            assert(result!)
        }
    }
    
    //line 180
    open func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil){
        GLog.d("connect : \(peripheral.identifier)")
        
        self.requestQueue.async { [weak self] in
            GLog.d("queued connection request")
            
            let connectRequest = CentralRequest.CONNECT( peripheral, options )
            let result = self?._dispatchBlock!( connectRequest, self!)
            assert(result!)
        }
    }
    
    //line 194
    open func cancelPeripheralConnection(_ peripheral: CBPeripheral){
        GLog.d("cancelPeripheralConnection : \(peripheral.identifier)")
        
        self.requestQueue.async { [weak self] in
            GLog.d("queue disconnection request")
            
            let disconnectRequest = CentralRequest.DISCONNECT( peripheral )
            let result = self?._dispatchBlock!( disconnectRequest, self!)
            assert(result!)
        }
    }
}
