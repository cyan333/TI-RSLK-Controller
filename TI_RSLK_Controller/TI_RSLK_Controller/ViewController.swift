//
//  ViewController.swift
//  TI_RSLK_Controller
//
//  Created by NingFangming on 7/24/19.
//  Copyright © 2019 fangming. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        leftRightIndicator.text = String(Int(leftRightSliderOutlet.value))
        goBackIndicator.text = String(Int(goBackSliderOutlet.value))
        goBackSliderOutlet.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        
        let birdCategory: UInt32 = 2 << 3
        print(birdCategory)
        
    }

    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    var characteristic:CBCharacteristic!
    
    //UUID and service name
    let BEAN_NAME = "HMSoft"
    let BEAN_CHARACTERISTIC_UUID = CBUUID(string: "FFE1")
    let BEAN_SERVICE_UUID = CBUUID(string: "FFE0")
    
    /////////////////////////
    ///////BLE Functions/////
    /////////////////////////
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Scan for devices
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            //            _ = Timer.scheduledTimer(timeInterval: TimeInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            manager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            print( "Bluetooth on this device is currently powered off.")
        case .unsupported:
            print( "This device does not support Bluetooth Low Energy.")
        case .unauthorized:
            print( "This app is not authorized to use Bluetooth Low Energy.")
        case .resetting:
            print( "The BLE Manager is resetting; a state update is pending.")
        case .unknown:
            print( "The state of the BLE Manager is unknown.")
            
        }
        //        if central.state == CBManagerState.poweredOn{
        //            central.scanForPeripherals(withServices: nil, options: nil)
        //        } else {
        //            print("Bluetooth not avaliable.")
        //        }
    }
    
    //Connect to a device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        print(device ?? "null")
        if device?.contains(BEAN_NAME) == true {
            print("*** PAUSING SCAN...")
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    //Get services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("get service")
        peripheral.discoverServices(nil)
    }
    
    
    
    //Get Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{
            let thisService = service as CBService
            print(service.uuid)
            if service.uuid == BEAN_SERVICE_UUID{
                print("get Char")
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    //setup notification
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            //            var parameter = NSInteger(1)
            //            let data = NSData(bytes: &parameter, length: 1) as Data
            
            let thisCharacteristic = characteristic as CBCharacteristic
            print(thisCharacteristic.uuid)
            if thisCharacteristic.uuid == BEAN_CHARACTERISTIC_UUID {
                //Set notification
                self.peripheral.setNotifyValue(true, for: thisCharacteristic)
                self.characteristic=thisCharacteristic;
                //Write Value
                //                print("send 1")
                //                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
    
//    @IBAction func left(_ sender: Any) {
//        print("left")
//        var value: UInt8 = 1
//
//        let data = NSData(bytes: &value, length: MemoryLayout<UInt8>.size)
//
//        peripheral.writeValue(data as Data, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
//    }
//
//    @IBAction func right(_ sender: Any) {
//        print("right")
//        var value: UInt8 = 2
//
//        let data = NSData(bytes: &value, length: MemoryLayout<UInt8>.size)
//
//        peripheral.writeValue(data as Data, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
//    }
//
//    @IBAction func forward(_ sender: Any) {
//        print("forward")
//        var value: UInt8 = 3
//
//        let data = NSData(bytes: &value, length: MemoryLayout<UInt8>.size)
//
//        peripheral.writeValue(data as Data, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
//    }
//
//    @IBAction func backward(_ sender: Any) {
//        print("backward")
//        var value: UInt8 = 4
//
//        let data = NSData(bytes: &value, length: MemoryLayout<UInt8>.size)
//
//        peripheral.writeValue(data as Data, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
//    }
    
    @IBOutlet var leftRightSliderOutlet: UISlider!
    @IBOutlet var leftRightIndicator: UILabel!
    @IBOutlet var goBackSliderOutlet: UISlider!
    @IBOutlet var goBackIndicator: UILabel!
    
    @IBAction func leftRightSlider(_ sender: UISlider) {
        var leftRightText:String
        leftRightText = String(Int(leftRightSliderOutlet.value))
        leftRightIndicator.text = leftRightText

//        var leftRightValue:Int? = Int(leftRightSliderOutlet.value)
//        print(Int(leftRightText) ?? 0)
//        let data = NSData(bytes: &leftRightValue, length: MemoryLayout<UInt8>.size)
//        peripheral.writeValue(data as Data, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
        combineSlider12(slider1ValueIs: Int(leftRightSliderOutlet.value), slider2ValueIs: Int(goBackSliderOutlet.value))
    }
    
    @IBAction func goBackSlider(_ sender: UISlider) {
        goBackIndicator.text = String(Int(goBackSliderOutlet.value))
        combineSlider12(slider1ValueIs: Int(leftRightSliderOutlet.value), slider2ValueIs: Int(goBackSliderOutlet.value))
    }
    
    func combineSlider12(slider1ValueIs slider1Num:Int, slider2ValueIs slider2Num:Int) {
        //combined = slider2 (MSB) + slider1 (LSB)
        var combinedValue: Int = (slider2Num << 4) + slider1Num
        let data = NSData(bytes: &combinedValue, length: MemoryLayout<UInt8>.size)
        peripheral.writeValue(data as Data, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
    }
    
    
    
}

