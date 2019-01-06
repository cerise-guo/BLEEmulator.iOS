//
//  CBCentralManagerDelegate.swift
//  BLESimFramework
//
//  Created by CeriseGuo on 4/16/18.
//  Copyright © 2018 CeriseGuo. All rights reserved.
//

import Foundation

@objc public protocol CBCentralManagerDelegate : NSObjectProtocol {

    //@available(iOS 5.0, *)
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    
    //@objc @available(iOS 5.0, *)
    @objc optional func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any])
    
    
    //@objc @available(iOS 5.0, *)
    @objc optional func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    
    
    /*!
     *  @method centralManager:didConnectPeripheral:
     *
     *  @param central      The central manager providing this information.
     *  @param peripheral   The <code>CBPeripheral</code> that has connected.
     *
     *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
     *
     */
    @objc @available(iOS 5.0, *)
    optional func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    
    
    /*!
     *  @method centralManager:didFailToConnectPeripheral:error:
     *
     *  @param central      The central manager providing this information.
     *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
     *  @param error        The cause of the failure.
     *
     *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
     *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
     *
     */
    @objc @available(iOS 5.0, *)
    optional func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    
    
    /*!
     *  @method centralManager:didDisconnectPeripheral:error:
     *
     *  @param central      The central manager providing this information.
     *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
     *  @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
     *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
     *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
     *
     */
    @objc @available(iOS 5.0, *)
    optional func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
}
