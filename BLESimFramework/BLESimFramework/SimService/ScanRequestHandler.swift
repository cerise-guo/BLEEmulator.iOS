//
//  ScanRequestHandler.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 5/21/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

public class ScanRequestHandler : ScanRequestProtocol{

    private var timer: DispatchSourceTimer?
    
    //ID used to identify this instance
    let id = arc4random()
    
    //Record / Report how many scan response is delivered
    var scanResponseCount:UInt32 = 0
    
    deinit {
        GLog.d( "id: \(id)")
        timer?.cancel()
        timer = nil
    }
    
    //If need delay of scan response, put here.
    public func scan( _ manager: CBCentralManager? ){
        GLog.d( "id: \(id)")
        
        if( nil != manager ){
            
            if( nil == manager?.dispatchCallbackQueue || nil == manager?.centralMgrDelegate){
                GLog.d(">>>>>>>>>> no scan response : \(String(describing: manager?.dispatchCallbackQueue)), \(String(describing: manager?.centralMgrDelegate))")
                return
            }
            scanResponseCount = 0
            timer?.cancel()        // cancel previous timer if any
            timer = DispatchSource.makeTimerSource(queue: manager?.dispatchCallbackQueue)
            timer?.schedule(deadline: .now(), repeating: .seconds(3), leeway: .milliseconds(2000))

            var peripheralObjs = Array<PeripheralObject>()
            
            let container = PeripheralContainer.sharedInstance()
            
            //ToDo: advertisement info shall be from a formal exteranl supplier
            let advData:[String:Any] = ["CBAdvertisementDataServiceUUIDsKey":1234,"key2":"5678"]
            var peripheralObj:PeripheralObject?
            
            if let peripheral = container.get(type: .HeartRateMonitor){
                GLog.d("Use existing peripheral")
                peripheralObj = PeripheralObject(peripheral, rssi: 30, adv: advData)
            }
            else{
                //For performance consideration, get the objects outside the timer loop/callback
                let peripheral = PeripheralFactory.sharedInstance().createPeripheral(type: .HeartRateMonitor)
                PeripheralContainer.sharedInstance().register(peripheral: peripheral)
                
                peripheralObj = PeripheralObject(peripheral, rssi: 30, adv: advData)
            }
            
            peripheralObjs.append(peripheralObj!)
            
            //This handler may be destroied any time when user stop scan or scan again.
            //So keep the weak self to allow deallocating.
            timer?.setEventHandler { [weak self] in
                
                if( nil != manager ){
                    
                    for pobj in peripheralObjs{
                        manager?.centralMgrDelegate?.centralManager!(manager!, didDiscover: pobj.peripheral, advertisementData: pobj.advData, rssi:NSNumber(value:pobj.rssi))
                    }
                    GLog.d("return scan \(peripheralObjs.count) result to app : \(String(describing: self?.scanResponseCount)) , id : \(String(describing: self?.id))")
                    self?.scanResponseCount += 1
                }else{
                    GLog.d(">>>>>>>>>> manager is nil, no more scan response")
                }
            }
            
            timer?.resume()
            
            /* //work
            GLog.d( "call central manager delegate")
            manager?.dispatchCallbackQueue.asyncAfter (deadline: .now() + .milliseconds(2000)) {
                let rssiValue = NSNumber(value:888)
                let peripheral = CBPeripheral(name: "MyBLEDevice")
                let advData:[String:Any] = ["CBAdvertisementDataServiceUUIDsKey":1234,"key2":"5678"]
                
                GLog.d("retrun scan result to app")
                manager?.centralMgrDelegate?.centralManager!(manager!, didDiscover: peripheral, advertisementData: advData, rssi: rssiValue)
            }*/
        }
    }
    
    public func stopScan() {
        GLog.d()
        timer?.cancel()
        timer = nil
    }
}
