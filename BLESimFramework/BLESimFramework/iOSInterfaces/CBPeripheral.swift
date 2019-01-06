//
//  CBPeripheral.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 4/16/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public enum CBCharacteristicWriteType : Int {
    
    case withResponse
    
    case withoutResponse
}

open class CBPeripheral: CBPeer {
    
    internal let _name:String
    
    //This queue receives the BLE request from user, it should be efficient and not blocked.
    let requestQueue:DispatchQueue
    let requestQueueName:String = "PeripheralRequestQueue"
    
    fileprivate var _requestBlock: PeripheralRequestBlock?
    
    fileprivate let peripheralService:CBPeripheralService
    
    fileprivate var mServices:[CBService]?
    
    required public init( name:String ){
        
        //The queue by default is serial so the task will be executed as the order it was added.
        requestQueue = DispatchQueue( label: requestQueueName, qos: DispatchQoS.userInitiated )
        
        //ToDo: need a container to keep references to all peripheral service
        //Then each CBPeripheral object needs NOT to keep a strong reference to its peripheralService.
        //Besides the initialization, the CBPeripheral needs not to know/access the peripheralService.
        peripheralService = CBPeripheralService.instance
        
        _name = name
        super.init()
        
        peripheralService.register(peripheral: self)
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    public var requestBlock :PeripheralRequestBlock {
        set(newValue) {
            GLog.d()
            if self._requestBlock != nil {
                assert(false)
                GLog.d("should not set block twice.")
            }else{
                self._requestBlock = newValue
            }
        }
        get{
            assert(false)
            GLog.d("don't expect to get, it is used internally only")
        }
    }
    
    //line 60
    weak open var delegate: CBPeripheralDelegate?
    
    //line 68
    open var name: String? {
        get{ return _name }
    }
    
    public func appendServices( service:CBService ){
        
        if let existingServices = mServices {
            
            for tempService in existingServices {
                if( tempService.uuid == service.uuid ){
                    GLog.d("found service, jump to next")
                    return;
                }
            }
            
            GLog.d("append service to peripheral object")
            self.mServices?.append( service )
            
        }else{            
            mServices = [service]
        }
    }
    
    //line 95
    open var services: [CBService]? {
        get{
            return mServices
        }
    }
    
    //line 128
    open func discoverServices(_ serviceUUIDs: [CBUUID]?){
        GLog.d("discoverServices")
        
        self.requestQueue.async { [weak self] in
            GLog.d("queued discover service request")
            
            let request = PeripheralRequest.DISCOVER_SERVICE
            let result = self?._requestBlock!( request, self!)
            assert(result!)
        }
    }
    
    //line 156
    open func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService){
        GLog.d("discoverCharacteristics")
        
        self.requestQueue.async { [weak self] in
            GLog.d("queued discover characteristic request")
            
            let request = PeripheralRequest.DISCOVER_CHARACTERISTIC(service)
            let result = self?._requestBlock!( request, self!)
            assert(result!)
        }
    }
    
    //line 168
    open func readValue(for characteristic: CBCharacteristic){
        GLog.d("readValue")
        
        self.requestQueue.async { [weak self] in
            GLog.d("read value request")
            
            let request = PeripheralRequest.READ_VALUE(characteristic.uuid)
            let result = self?._requestBlock!( request, self!)
            assert(result!)
        }
    }
    
    open func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType){
        GLog.d("write value")
        
        self.requestQueue.async { [weak self] in
            GLog.d("queued write value request")
            
            let request = PeripheralRequest.WRITE_VALUE( characteristic.uuid, data, type )
            let result = self?._requestBlock!( request, self!)
            assert(result!)
        }
    }
    
    //line 218
    open func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic){
        GLog.d("setNotifyValue")
        
        self.requestQueue.async { [weak self] in
            GLog.d("queued set Notification request")

            let request = PeripheralRequest.SET_NOTIFICATION( characteristic.uuid, enabled )
            let result = self?._requestBlock!( request, self!)
            assert(result!)
        }
    }
}
