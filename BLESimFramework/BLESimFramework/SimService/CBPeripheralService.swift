//
//  CBPeripheralService.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 10/7/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public typealias PeripheralRequestBlock = ( _ request:PeripheralRequest, _ peripheral:CBPeripheral) -> Bool;

class CBPeripheralService{

    private var requestBlock:PeripheralRequestBlock
    
    var requestQueue:DispatchQueue
    private let requestQueueName:String = "requestQueue"
    
    //async queue for internal request process.
    private let concurrentQueue = DispatchQueue(
            label: "ble-process-queue",
            attributes: .concurrent)

    fileprivate static var service = createInstance()
    
    fileprivate static func createInstance() -> CBPeripheralService{
        GLog.d()
        return CBPeripheralService()
    }
    
    public static var instance:CBPeripheralService{
        get{
            return service
        }
    }
    
    private init(){
        GLog.d()
        
        //to satisfy compiler only. Will be set in static interface.
        requestBlock = {(request:PeripheralRequest, peripheral:CBPeripheral)->Bool in
            assert(false)
            GLog.d("should not use this default block")
            return true
        };
        
        //The queue by default is serial so the task will be executed as the order it was added.
        requestQueue = DispatchQueue( label: requestQueueName, qos: DispatchQoS.userInitiated )
        
        //_peripheral = nil
    }
    
    public func register( peripheral:CBPeripheral ){
        peripheral._requestBlock = self.DispatchMessage
    }
    
    private func DispatchMessage(request:PeripheralRequest, peripheral:CBPeripheral)->Bool
    {
        GLog.d()
        
        requestQueue.async { [unowned self] in
            switch request{
            case .DISCOVER_SERVICE:
                GLog.d("discover service request")
                
                self.concurrentQueue.async(flags: .barrier){
                    let delegate = SimCBPeripheralImpl.instance
                    delegate.peripheralManagerDiscoverService(peripheral)
                }
                
            case .DISCOVER_CHARACTERISTIC(let service):
                GLog.d("discover characteristic for service: \(service.uuid)" )
                
                self.concurrentQueue.async(flags: .barrier){
                    let delegate = SimCBPeripheralImpl.instance
                    delegate.peripheralManagerDiscoverCharacteristic(peripheral, forService: service)
                }
                
            case .SET_NOTIFICATION( let uuid, let enable ):
                GLog.d("set notification for characteristic : \(uuid.uuidString) , \(enable)")

                self.concurrentQueue.async(flags: .barrier){
                    let delegate = SimCBPeripheralImpl.instance
                    delegate.peripheralManager(peripheral, didSubscribeTo: uuid, subscribe: enable)
                }
                
            case .READ_VALUE( let uuid ):
                GLog.d("read value: \(uuid.uuidString)")
                
                self.concurrentQueue.async(flags: .barrier){
                    let delegate = SimCBPeripheralImpl.instance
                    delegate.peripheralManager(peripheral, didReceiveRead: uuid)
                }
                
            case .WRITE_VALUE(let uuid, let data, let type):
                GLog.d("write value: \(data.count)")
                
                self.concurrentQueue.async(flags: .barrier){
                    let delegate = SimCBPeripheralImpl.instance
                    delegate.peripheralManager(peripheral,
                                               didReceiveWrite: uuid,
                                               dataToWrite: data,
                                               writeType: type)
                }
            }
        }
        
        return true
    }

}
