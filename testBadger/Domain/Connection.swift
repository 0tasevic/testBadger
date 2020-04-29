//
//  Connection.swift
//  testBadger
//
//  Created by Milos Otasevic on 29/04/2020.
//  Copyright © 2020 Milos Otasevic. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreGraphics

protocol ConnectionSearchingDelegate{
    func searchStart()
    func searchEnd(userDeviceFound: Bool)
}

class Connection: NSObject{
    var device = Device()
    private var centralManager = CBCentralManager()
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic?
    var searchingDelegate: ConnectionSearchingDelegate?
    var peripherals = [CBPeripheral]()
    var myCharasteristic: CBCharacteristic?
    
    
    
    func setCentral(){
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connectToPeriferal(position: Int) {
        peripheral = peripherals[position]
        device.name = peripheral.name ?? ""
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil);
    }
    
    func writeValue() {
        let myImage = UIImage(named: "amplitudo")!
        
        let imgData = myImage.jpegData(compressionQuality: 1)
        var broj = 0
        
        var tenBytes = [[UInt8]]()
        var pomocni = [UInt8]()
        
        for byte in imgData! {
            broj += 1
            pomocni.append(byte)
            if pomocni.count == 256{
                tenBytes.append(pomocni)
                pomocni = [UInt8]()
            }
        }
        if pomocni.count != 0 {
           tenBytes.append(pomocni)
            pomocni = [UInt8]()
        }
        
        
        var cmd: UInt8 = 5
        let imagePosition: UInt8 = 1
        let size1 = UInt8((broj & 0xf00) >> 8)
        let size2 = UInt8((broj & 0x0f0) >> 4)
        let size3 = UInt8(broj & 0x00f)
        
        let chunksNumber1 = UInt8(tenBytes.count)
        
        
        
        var theData: [UInt8] = [cmd, imagePosition, size1,size2,size3,chunksNumber1, UInt8(0), UInt8(0),UInt8(1)]
        let data = NSData(bytes: &theData, length: theData.count)
        if myCharasteristic == nil {
            print("nije pronadjena char")
            return
        }
        self.peripheral.writeValue(Data(referencing: data), for: myCharasteristic!, type: CBCharacteristicWriteType.withoutResponse)
        print(Data(referencing: data))
        
        cmd = 6
        var brojac: UInt8 = 0
        for bytes in tenBytes{
            broj += 1
            theData = [cmd, brojac, UInt8(bytes.count)] + bytes
            self.peripheral.writeValue(Data(referencing: data), for: myCharasteristic!, type: CBCharacteristicWriteType.withoutResponse)
            print(Data(referencing: data))

        }
    }
}

extension Connection: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            //            self.bTDisconnectionFeedback?.bTPoweredOff()
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
            self.centralManager.scanForPeripherals(withServices: nil)
            self.searchingDelegate?.searchStart()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripherals.append(peripheral)
        if let periperalName = peripheral.name, let myDeviceName = UserDefaults.standard.value(forKey: "MyDevice") as? String{
            if periperalName == myDeviceName{
                if let indexOfPeriperal = self.peripherals.firstIndex(of: peripheral){
                    self.connectToPeriferal(position: indexOfPeriperal)
                    self.searchingDelegate?.searchEnd(userDeviceFound: true)
                    return
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.centralManager.stopScan()
            self.searchingDelegate?.searchEnd(userDeviceFound: false)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        disconnectionFeedback?.deviceDisconnect()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        self.peripheral.discoverServices(nil)
    }
    
    
}

extension Connection: CBPeripheralDelegate{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("service------------->", service)
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.write){
                if characteristic.uuid.uuidString ==  "00000000-1000-1200-8000-FF805F9B34FA"{
                    myCharasteristic = characteristic
                }
                        self.characteristic = characteristic
            }
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard let characteristicData = characteristic.value else { return }
//        device.reload(with: characteristicData)
//        deviceFeedback?.deviceUpdate()
    }
}


