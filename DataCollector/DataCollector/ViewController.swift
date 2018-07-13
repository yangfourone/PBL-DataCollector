//
//  ViewController.swift
//  DataCollector
//
//  Created by 41 on 2018/5/23.
//  Copyright © 2018年 41. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Xaxis: UITextField!
    @IBOutlet weak var Yaxis: UITextField!
    @IBOutlet weak var CollectTime: UITextField!
    
    let LM = CLLocationManager()
    
    /** DEFINITION **/
    let uuid = UUID(uuidString: "D9F08C92-6C39-486F-A245-D65D36695AF3") // 太和光
    var CollectEnable:Bool = false
    var CollectionCompleted:Bool = false
    var CollectCount:Int = 0
    var BeaconsCount:Int = 0
    
    /** Text File Content **/
    var ResultMessage:String = ""
    var InitialMessage:String = ""
    
    /** 判斷是否需要設定 Index **/
    var FirstTimeEnter:Bool = true
    
    /** 建築判斷 **/
    var index:Int = 0
    
    /** 各建築 Beacon 數量 **/
    let EE01_Beacon_Quantity = 4
    let IB01_Beacon_Quantity = 6
    let IB11_Beacon_Quantity = 4
    var Beacon_Quantity:[Int] = []
    
    /** 各建築定義之 Major **/
    let EE01_Major = 7051
    let IB01_Major = 18
    let IB11_Major = 28
    var Building_Major:[Int] = []
    
    /** TableView 之 Title & Subtitle **/
    var UUIDText = [String]()
    var ContentText = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /** Definition Array **/
        Beacon_Quantity = [EE01_Beacon_Quantity,IB01_Beacon_Quantity,IB11_Beacon_Quantity]
        Building_Major = [EE01_Major,IB01_Major,IB11_Major]
        
        /** close keyboard when click anywhere **/
        self.hideKeyboardWhenTappedAround()
        
        /** location **/
        LM.requestAlwaysAuthorization()
        LM.delegate = self
        
        let region = CLBeaconRegion(proximityUUID: uuid!, identifier: "MyRegion")
        
        LM.startMonitoring(for: region)
    }
    
    /** TableView Setting **/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UUIDText.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = ContentText[indexPath.row]
        cell.detailTextLabel?.text = UUIDText[indexPath.row]
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /** Enter CLRegion **/
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Enter \(region.identifier)")
    }
    
    /** Exit CLRegion **/
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit \(region.identifier)")
    }
    
    /** Monitoring Mode **/
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion){
        print("StartMonitoring")
        let region = CLBeaconRegion(proximityUUID: uuid!, identifier: "MyRegion")
        LM.startRangingBeacons(in: region)
    }
    
    /** didRangeBeacons **/
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        guard beacons.count > 0 else {
            FirstTimeEnter = true
            print("no any beacon")
            return
        }
        
        /** 根據第一次進來所偵測到的 Major 判斷人處於哪個建築內做相對應的初始化 **/
        if FirstTimeEnter {
            FirstTimeEnter = false
            switch Int(beacons[0].major) {
            case EE01_Major:
                index = 0
                UUIDText = Array(repeating: "", count: EE01_Beacon_Quantity)
                ContentText = Array(repeating: "", count: EE01_Beacon_Quantity)
                InitialMessage = "Class,Beacon1,Beacon2,Beacon3,Beacon4,Time,LocalKnnLabel\n"
            case IB01_Major:
                index = 1
                UUIDText = Array(repeating: "", count: IB01_Beacon_Quantity)
                ContentText = Array(repeating: "", count: IB01_Beacon_Quantity)
                InitialMessage = "Class,Beacon1,Beacon2,Beacon3,Beacon4,Beacon5,Beacon6,Time,LocalKnnLabel\n"
            case IB11_Major:
                index = 2
                UUIDText = Array(repeating: "", count: IB11_Beacon_Quantity)
                ContentText = Array(repeating: "", count: IB11_Beacon_Quantity)
                InitialMessage = "Class,Beacon1,Beacon2,Beacon3,Beacon4,Time,LocalKnnLabel\n"
            default:
                index = 0
                UUIDText = Array(repeating: "", count: EE01_Beacon_Quantity)
                ContentText = Array(repeating: "", count: EE01_Beacon_Quantity)
                InitialMessage = "Class,Beacon1,Beacon2,Beacon3,Beacon4,Time,LocalKnnLabel\n"
            }
        }
        else {
            
        }
        
        /** 在 TableView 輸出掃到的 Beacon 資訊（ Rssi為0時，補-120 ） **/
        for i in 0..<beacons.count {
            //print("Beacon\(i): Major-> \(beacons[i].major), Minor-> \(beacons[i].minor), RSSI-> \(beacons[i].rssi)")
            if beacons[i].rssi == 0 {
                UUIDText[i] = "USBeacon: \(beacons[i].proximityUUID)"
                ContentText[i] = "Rssi: -120, Major: \(beacons[i].major), Minor: \(beacons[i].minor)"
            }
            else {
                UUIDText[i] = "USBeacon: \(beacons[i].proximityUUID)"
                ContentText[i] = "Rssi: \(beacons[i].rssi), Major: \(beacons[i].major), Minor: \(beacons[i].minor)"
            }
        }
        //print("----------------------------------")
        //print(UUIDText)
        //print(ContentText)
        
        /** 更新 TableView 的資料 **/
        tableView.reloadData()
        
        /** 判斷是否按下收集按鍵 **/
        if CollectEnable {
            if String(CollectCount) == CollectTime.text {
                print("done")
                CollectionCompleted = true
                CollectEnable = false
            } else {
                CollectCount = CollectCount + 1
            }
        }
        
        /** 抓取現在時間 **/
        let now:Date = Date()
        let dateFormat:DateFormatter = DateFormatter() // 建立時間格式
        dateFormat.dateFormat = "HH:mm:ss"
        let dateString:String = dateFormat.string(from: now) // 將當下時間轉換成設定的時間格式
        
        
        /** 製作輸出檔案的內容 **/
        var reg:[Int] = []
        reg = Array(repeating: -120, count: Beacon_Quantity[index])
        if CollectionCompleted {
            // alert
            CollectResult()
            // initial
            CollectionCompleted = false
        }
        ResultMessage += "\(Xaxis.text!)-\(Yaxis.text!),"
        for k in 0..<beacons.count {
            if beacons[k].rssi == 0 {
                reg[Int(beacons[k].minor)-1] = -120
            } else {
                reg[Int(beacons[k].minor)-1] = Int(beacons[k].rssi)
            }
        }
        var rssi_reg = "\(reg)"
        rssi_reg = rssi_reg.replacingOccurrences(of: "[", with: "", options: .literal, range: nil)
        rssi_reg = rssi_reg.replacingOccurrences(of: "]", with: "", options: .literal, range: nil)
        rssi_reg = rssi_reg.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        ResultMessage += rssi_reg
        ResultMessage += ",\(dateString),\(Xaxis.text!)\(Yaxis.text!)\n"
        
        BeaconsCount = beacons.count
    }
    
    /** Collection Completed **/
    func CollectResult() {
        let alertController = UIAlertController(title: "收集完成", message: ResultMessage, preferredStyle: .alert) //設定為 alert action
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) in
            self.dismiss (animated: true, completion: nil)
            self.CollectEnable = false
        }
        alertController.addAction(okAction)
        show(alertController, sender: self)
        
        /** 儲存收集好的資料 **/
        print("Result Message: \(ResultMessage)")
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(Xaxis.text!)-\(Yaxis.text!).txt"
        print(documentPath)
        do {
            try ResultMessage.write(toFile: documentPath, atomically: true, encoding: .utf8)
        }
        catch {
            print("Not save correctly")
        }
    }
    
    /** Collect Enable **/
    @IBAction func OK(_ sender: Any) {
        if Xaxis.text == "" || Yaxis.text == "" || CollectTime.text == "" {
            let alertController = UIAlertController(title: "ERROR", message: "請輸入正確的探索區域及時間", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                (action) in
                self.dismiss (animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            show(alertController, sender: self)
        }
        else {
            ResultMessage = InitialMessage
            CollectEnable = true
            CollectCount = 0
            print("X axis: \(Xaxis.text!), Y axis: \(Yaxis.text!), Collection Time: \(CollectTime.text!)")
        }
    }
}

/** Close Keyboard **/
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
