//
//  ViewController.swift
//  BLESim
//
//  Created by CeriseGuo on 12/26/17.
//  Copyright © 2017 CeriseGuo. All rights reserved.
//

import UIKit

#if SIM_BLE
    import BLESimFramework
#else
    import CoreBluetooth
#endif

//import CoreBluetooth  //need to remove this after my framework can simulate its behavior

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheral: CBPeripheral?
    
    //let targetDeviceName:String = "S7"
    let targetDeviceName:String = "G5"
    //let targetDeviceName:String = "iPod Touch"
    
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let centralQueue = DispatchQueue(label: "BLE_scan_queue", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        statusLabel.text = ""
        
        NSLog("Done")        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func OnClickA(_ sender: UIButton) {
        NSLog("OnClick A - Scan")
        
        self.startScanning()
        
        //assert( (centralManager?.isScanning)! ) //assert failed on iPhoneSE
    }
    
    @IBAction func OnClickB(_ sender: UIButton) {
        NSLog("OnClick B - Stop Scan")
        
        centralManager?.stopScan()
        
        assert( !(centralManager?.isScanning)! )
    }
    
    @IBAction func OnClickC(_ sender: UIButton) {
        NSLog("OnClick C - Connect")
        
        if( nil != peripheral){
            NSLog("connect to peripheral")
            peripheral?.delegate = self
            centralManager?.connect(peripheral!)
        }
    }
    
    @IBAction func OnClickD(_ sender: UIButton) {
        NSLog("OnClick D - Disconnect")
        
        if( nil != peripheral){
            NSLog("disconnect to peripheral")
            centralManager?.cancelPeripheralConnection(peripheral!)
        }
    }
    
    private var registerStatus = true
    @IBAction func OnClickE(_ sender: UIButton) {
        NSLog("OnClick E - register notification: \(registerStatus)")
        
        if( nil != heartRateMeasurement ){
            
            peripheral?.setNotifyValue(registerStatus, for: heartRateMeasurement! )
            registerStatus = !registerStatus
        }
    }
    
    @IBAction func OnClickF(_ sender: UIButton) {
        NSLog("OnClick F - write value")
        
        if( nil != heartRateControlPoint ){
            peripheral?.writeValue(Data([12]), for: heartRateControlPoint!, type: .withResponse)
        }
    }
    
    @IBAction func OnClickG(_ sender: UIButton) {
        NSLog("OnClick G - read value")
        
        if( nil != self.batteryLevel ){
            peripheral?.readValue(for: self.batteryLevel!)  //setNotifyValue(registerStatus, for: heartRateMeasurement! )
        }else{
            NSLog("have no battery characteristic")
        }
    }
    
    private func startScanning() {
        if let central = centralManager {
            NSLog( "start scanning")
            
            central.scanForPeripherals(withServices:nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        NSLog( "didDiscover : \(String(describing: peripheral.name)), \(peripheral.identifier) , RSSI : \(RSSI)")
        NSLog(" queue name: \(String(describing: currentQueueName()))")
        
        if( nil == self.peripheral ){

            if( nil != peripheral.name?.range(of: self.targetDeviceName)){
                self.peripheral = peripheral;
                NSLog("Dicovered target : \(self.targetDeviceName)")
                
                DispatchQueue.main.async() {
                    self.statusLabel.text = self.targetDeviceName + " discovered."
                }
                
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog( "connected to peripheral : \(peripheral.identifier)")
        NSLog(" queue name: \(String(describing: currentQueueName()))")
        
        assert( peripheral.name == self.targetDeviceName )
        
        DispatchQueue.main.async() {
            self.statusLabel.text = self.targetDeviceName + " connected."
        }
        
        if( peripheral.identifier == self.peripheral?.identifier ){
            NSLog("start discovering service")
            peripheral.discoverServices(nil)
        }
        else{
            NSLog("different peripheral is connected.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("did disconnect : \(peripheral.identifier.uuidString)")
        NSLog(" queue name: \(String(describing: currentQueueName()))")
        
        self.batteryLevel = nil
        self.heartRateControlPoint = nil
        self.heartRateMeasurement = nil
        
        DispatchQueue.main.async() {
            self.statusLabel.text = self.targetDeviceName + " disconnected."
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        NSLog("did didUpdateNotificationStateFor : \(peripheral.identifier.uuidString)")
        NSLog(" queue name: \(String(describing: currentQueueName()))")
        
        DispatchQueue.main.async() {
            self.statusLabel.text =  "notifying : \(characteristic.isNotifying)"
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("didUpdateValueFor : \(characteristic.uuid.uuidString)")
        NSLog(" queue name: \(String(describing: currentQueueName()))")
        
        if (nil != characteristic.value){
            
            //let valueString = String(data: characteristic.value!, encoding: String.Encoding.utf8)
            
            let size = MemoryLayout<Int8>.stride
            let bytes = characteristic.value!.withUnsafeBytes {
                Array(UnsafeBufferPointer<Int8>(start: $0, count: characteristic.value!.count/size))
            }
            for value in bytes {
                NSLog("\(characteristic.uuid.uuidString) value updated : \(value)")
            }
            
            DispatchQueue.main.async() {
                self.statusLabel.text =  "read \(bytes.count) bytes"
            }
            
            //Data format:
            //https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
            //NSLog("\(characteristic.uuid.uuidString) value updated : \(bytes[1])")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        NSLog( "peripheral didDiscoverServices for \(peripheral.identifier)")
        NSLog(" queue name: \(String(describing: currentQueueName()))")
        
        if( peripheral.identifier == self.peripheral?.identifier ){
            
            guard let services = peripheral.services else {
                NSLog("no service discovered")
                return
            }
            
            for service in services {
                NSLog("discovered service : \(service.uuid.uuidString)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
            print("Discovered Services: \(services)")
            
            //Services:
            //<CBService: 0x1c047ce00, isPrimary = YES, UUID = Continuity>,
            //      <CBCharacteristic: 0x1c02a7800, UUID = Continuity, properties = 0x98, value = (null), notifying = NO>
            //
            //<CBService: 0x1c047cc40, isPrimary = YES, UUID = 9FA480E0-4967-4542-9390-D343DC5D04AE>,
            //      <CBCharacteristic: 0x1c02a6f60, UUID = AF0BADB1-5B99-43CD-917A-A77BC549E3CC, properties = 0x98, value = (null), notifying = NO>
            //
            //<CBService: 0x1c047f140, isPrimary = YES, UUID = Battery>,
            //      <CBCharacteristic: 0x1c02a7860, UUID = Battery Level, properties = 0x12, value = (null), notifying = NO>
            //
            //<CBService: 0x1c047cf00, isPrimary = YES, UUID = Current Time>,
            //      <CBCharacteristic: 0x1c02a7740, UUID = Current Time, properties = 0x12, value = (null), notifying = NO>,
            //      <CBCharacteristic: 0x1c02a76e0, UUID = Local Time Information, properties = 0x2, value = (null), notifying = NO>
            //
            //<CBService: 0x1c047cf40, isPrimary = YES, UUID = Device Information>,
            //      <CBCharacteristic: 0x1c02a7680, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO>,
            //      <CBCharacteristic: 0x1c02a7620, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>])
            //
            //<CBService: 0x1c047cf80, isPrimary = YES, UUID = Heart Rate>]
            //      <CBCharacteristic: 0x1c02a75c0, UUID = 2A37, properties = 0x10, value = (null), notifying = NO>,  heart rate measurement
            //      <CBCharacteristic: 0x1c02a7560, UUID = 2A38, properties = 0x2, value = (null), notifying = NO>,  body sensor location
            //      <CBCharacteristic: 0x1c02a7500, UUID = 2A39, properties = 0x88, value = (null), notifying = NO>, heart rate control point
            
        }
        else{
            NSLog("service is discovered for different peripheral.")
        }
    }
    
    var heartRateMeasurement:CBCharacteristic? //0x2A37
    let heartRateMeasurementUUID:CBUUID = CBUUID( string: "0x2A37" )
    let heartRateControlPointUUID:CBUUID = CBUUID( string: "0x2A39" )
    
    let batteryServiceUUID:CBUUID = CBUUID( string: "0x2A19" )
    var batteryLevel:CBCharacteristic? //0x2A19
    
    var bodySensorLocation:CBCharacteristic?  //0x2A38
    
    var heartRateControlPoint:CBCharacteristic?  //0x2A39
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            NSLog("\(service.uuid) : discovered characteristic : \(characteristic.uuid.uuidString)")
            
            if( characteristic.uuid  == heartRateMeasurementUUID){
                NSLog("discovered heart rate measurement charactertistic")
                heartRateMeasurement = characteristic
                
                DispatchQueue.main.async() {
                    self.statusLabel.text = "discovered target characteristic"
                }
            }
            else if( characteristic.uuid  == batteryServiceUUID){
                NSLog("discovered battery charactertistic")
                batteryLevel = characteristic
                
                DispatchQueue.main.async() {
                    self.statusLabel.text = "discovered target characteristic"
                }
            }
            else if( characteristic.uuid == heartRateControlPointUUID ){
                NSLog("discovered heart rate control point charactertistic")
                heartRateControlPoint = characteristic
                
                DispatchQueue.main.async() {
                    self.statusLabel.text = "discovered target characteristic"
                }
            }
        }
        NSLog("Discovered characteristic: \(String(describing: service.characteristics))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("didWriteValueFor : \(characteristic.uuid.uuidString) , \(error.debugDescription)")
        NSLog(" queue name: \(String(describing: currentQueueName()))")
        
        DispatchQueue.main.async() {
            self.statusLabel.text = "wrote target characteristic"
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        NSLog( "centralManagerDidUpdateState :\(central.state.rawValue)");
        
        switch (central.state) {
        case .poweredOff:
            NSLog( "poweredOff");
            break;
            
        case .unauthorized:
            NSLog( "unauthorized");
            break
            
        case .unknown:
            NSLog( "unknown");
            break
            
        case .poweredOn:
            NSLog( "poweredOn");
            //self.startScanning()
            break
            
        case .resetting:
            NSLog( "resetting");
            break;
            
        case .unsupported:
            NSLog( "unsupported");
            break
        }
    }
    
    func currentQueueName() -> String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }
}

