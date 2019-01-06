//
//  SimCBPeripheralManagerDelegate.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 12/25/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

class SimCBPeripheralImpl : NSObject {
    
    //async queue for internal request process.
    private let concurrentResultQueue = DispatchQueue(
        label: "ble-result-queue",
        attributes: .concurrent)
    
    fileprivate static var delegate = createInstance()
    
    fileprivate static func createInstance()->SimCBPeripheralImpl {
        GLog.d()
        return SimCBPeripheralImpl()
    }
    
    public static var instance:SimCBPeripheralImpl{
        get{
            return delegate
        }
    }
    
    private override init() {
        super.init()
        
        if( backgroundMode ){
            registerBackgroundTask()
        }
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    //This flag shall be set according to the actual test scope whether to test background mode.
    //The background related code will be triggered when this flag is true
    let backgroundMode:Bool = false
    
    //NOTE: shall use enterGroup() and leaveGroup() call instead of using memeber variables directly
    var dispatchGroup:DispatchGroup?
    var enteredGroup:Bool = false
    private func enterGroup(){
        GLog.d("enterGroup")
        dispatchGroup = DispatchGroup()
        dispatchGroup!.enter()
        self.enteredGroup = true
    }
    
    private func leaveGroup(){
        GLog.d("leaveGroup")
        if( enteredGroup ){
            dispatchGroup!.leave()
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        NSLog("observeValue is triggered")
        
        if keyPath == #keyPath(BackgroundDelegate.changed) {
            
            //Note: object is a instance of BackgroundDelegate object
            NSLog("captured changed value: \(BackgroundDelegate.instance.changed)")
            
            NSLog("release interlock to continue BLE callback flow")
            leaveGroup()
        }
    }
    
    func peripheralManagerDiscoverCharacteristic( _ peripheral:CBPeripheral, forService service:CBService ){
        GLog.d(" prepare to discover characteristic \(backgroundMode)")
        
        let characterList:[CBCharacteristic] = createCharacteristicsFor( service )
        
        for character in characterList{
            service.setCharacteristic( characteristics: character )
        }
        
        //the delegate's behavior is from caller, it should not block/delay the simulator
        //code here, so a async call is used.
        if( backgroundMode ){
            enterGroup()
            dispatchGroup?.notify(queue: self.concurrentResultQueue){
                GLog.d("continue delegate callback")
                peripheral.delegate?.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error:nil)
            }
        }
        else{
            self.concurrentResultQueue.async(flags: .barrier){
                peripheral.delegate?.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error:nil)
            }
        }
    }
    
    func peripheralManagerDiscoverService(_ peripheral:CBPeripheral ){
        GLog.d("")
        
        //add services to peripheral first, then trigger the 'did' callback
        let serviceFactory = CBServiceFactory.getInstance
        
        let serviceContainer:CBServiceContainer = CBServiceContainer.instance
        
        //switch expected service here
        let serviceType = CBService.SERVICE_TYPE.HEART_RATE_MONITOR
        //let serviceType = CBService.SERVICE_TYPE.BATTERY_LEVEL
        
        if let service = serviceContainer.get(
            uuid:  CBUUID(string:serviceType.rawValue)){
            peripheral.appendServices(service: service)
        }else{
            let service = serviceFactory.createServiceWithUUID(
                serviceType,
                peripheral:peripheral)
            
            serviceContainer.register(service: service)
            peripheral.appendServices(service: service)
        }
        
        //the delegate's behavior is from caller, it should not block/delay the simulator
        //code here, so a async call is used.
        self.concurrentResultQueue.async(flags: .barrier){
            peripheral.delegate?.peripheral(peripheral, didDiscoverServices: nil)
        }
    }
    
    func peripheralManager(_ peripheral:CBPeripheral, didSubscribeTo characteristicUUID:CBUUID, subscribe enable:Bool){
        GLog.d("\(characteristicUUID)")
        
        if let char = CBCharacteristicContainer.sharedInstance().get(uuid: characteristicUUID){
            GLog.d("found charactertistic for notification")
            
            if( enable ){
                if !char.isNotifying {
                    char.setNotifying(notify:  true )
                }
            }else{
                
                if( char.isNotifying ){
                    char.setNotifying(notify: false )
                }
            }
            
            self.concurrentResultQueue.async(flags: .barrier){
                GLog.d()
                peripheral.delegate?.peripheral(peripheral, didUpdateNotificationStateFor: char, error:nil)
            }
        }else{
            GLog.w("can not find target charactertistic")
            assert( false, "can not find target charactertistic")
        }
    }
    
    func peripheralManager(_ peripheral:CBPeripheral,
                           didReceiveWrite characteristicUUID:CBUUID,
                           dataToWrite data:Data,
                           writeType type:CBCharacteristicWriteType){
        GLog.d("\(characteristicUUID)")
        
        if let char = CBCharacteristicContainer.sharedInstance().get(uuid: characteristicUUID){
            
            let size = MemoryLayout<Int8>.stride
            let bytes = data.withUnsafeBytes {
                Array(UnsafeBufferPointer<Int8>(start: $0, count: data.count/size))
            }
            for value in bytes {
                NSLog("value wrote : \(value)")
            }
            
            if( type == .withResponse){
                GLog.d()
                self.concurrentResultQueue.async(flags: .barrier){
                    peripheral.delegate?.peripheral(peripheral, didWriteValueFor: char, error: nil)
                }
            }
            
        }else{
            GLog.w("can not find target charactertistic")
            assert( false, "can not find target charactertistic")
        }
    }
    
    func peripheralManager(_ peripheral:CBPeripheral, didReceiveRead characteristicUUID:CBUUID ){
        GLog.d("\(characteristicUUID)")
        
        if let char = CBCharacteristicContainer.sharedInstance().get(uuid: characteristicUUID){
            
            let data = Data([123,122,121,120])
            char.setValue(data: data)
            
            self.concurrentResultQueue.async(flags: .barrier){
                peripheral.delegate?.peripheral(peripheral, didUpdateValueFor: char, error: nil)
            }
            
        }else{
            GLog.w("can not find target charactertistic")
            assert( false, "can not find target charactertistic")
        }

    }
    
    private func createCharacteristicsFor( _ service: CBService )->[CBCharacteristic]{
        
        switch( service.uuid.uuidString ){
        case CBService.SERVICE_TYPE.HEART_RATE_MONITOR.rawValue:
            GLog.d("create characteristic for heart rate monitor")
            return createCharacteristicForHeartRateMonitor( service )
            
        case CBService.SERVICE_TYPE.BATTERY_LEVEL.rawValue:
            GLog.d("create characteristic for battery service")
            return createCharacteristicForBatteryService( service )
            
        default:
            assert(false, "unknown service type")
        }
        
        return []
    }
    
    private func createCharacteristicForBatteryService( _ service: CBService )->[CBCharacteristic]{
        GLog.d()
        
        var characterList:[CBCharacteristic] = []
        
        let characteristicFactory = CBCharacteristicFactory.getInstance
        let charContainer = CBCharacteristicContainer.sharedInstance()
        
        let uuid1:CBUUID = CBUUID(string: "0x2A19")
        if let character = charContainer.get(uuid: uuid1){
            characterList.append(character)
        }else{
            let character = characteristicFactory.createCharacteristic(characterUUID: uuid1, service:service)
            charContainer.register(character: character)
            characterList.append(character)
        }
        
        return characterList
    }
    
    private func createCharacteristicForHeartRateMonitor( _ service: CBService )->[CBCharacteristic]{
        GLog.d()
        
        var characterList:[CBCharacteristic] = []
        
        let characteristicFactory = CBCharacteristicFactory.getInstance
        let charContainer = CBCharacteristicContainer.sharedInstance()
        
        let uuid1:CBUUID = CBUUID(string: "0x2A37")
        if let character = charContainer.get(uuid: uuid1){
            characterList.append(character)
        }else{
            let character = characteristicFactory.createCharacteristic(characterUUID: uuid1, service:service)
            charContainer.register(character: character)
            characterList.append(character)
        }
        
        let uuid2:CBUUID = CBUUID(string: "0x2A38")
        if let character = charContainer.get(uuid: uuid2){
            characterList.append(character)
        }else{
            let character = characteristicFactory.createCharacteristic(characterUUID: uuid2, service: service)
            charContainer.register(character: character)
            characterList.append(character)
        }
        
        let uuid3:CBUUID = CBUUID(string: "0x2A39")
        if let character = charContainer.get(uuid: uuid3){
            characterList.append(character)
        }else{
            let character = characteristicFactory.createCharacteristic(characterUUID: uuid3, service: service)
            charContainer.register(character: character)
            characterList.append(character)
        }
        
        GLog.d("created \(characterList.count) charactertistics")
        return characterList
    }
    
    //This function is just to log time stamp to help identify the background status
    //This function doesn't provide functional behavior.
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            NSLog( "Background task will end soon.")
            NSLog( "Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
            UIApplication.shared.endBackgroundTask((self?.backgroundTask)!)
            self?.backgroundTask = UIBackgroundTaskInvalid
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
}
