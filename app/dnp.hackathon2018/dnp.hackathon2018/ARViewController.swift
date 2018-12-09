//
//  ARViewController.swift
//  dnp.hackathon2018
//
//  Created by tofubook on 2018/12/05.
//  Copyright © 2018年 tofubook. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import CoreLocation

class ARViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var pitchLabel:UILabel!
    @IBOutlet weak var rollLabel:UILabel!
    @IBOutlet weak var yawLabel:UILabel!
    @IBOutlet weak var gpsXLabel:UILabel!
    @IBOutlet weak var gpsYLabel:UILabel!
    @IBOutlet weak var gpsHLabel:UILabel!
    @IBOutlet weak var headingLabel:UILabel!
    @IBOutlet weak var cameraView:UIView!
    @IBOutlet weak var navigationBar:UINavigationBar!
    
    var searchText:String?
    var searchDistanceIndex:Int?
    
    let connector:SensorConnector = SensorConnector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let cameraPreviewLayer:AVCaptureVideoPreviewLayer? = connector.setupCamera()
        cameraPreviewLayer?.frame = cameraView.bounds
        cameraView.layer.addSublayer(cameraPreviewLayer!)
        connector.startCameraSesstion()
        
        connector.setupDeviceMotion()
        connector.startDeviceMotion(callback: updateDeviceMotion)
        
        connector.setupHeading(delegateTarget: self)
        connector.setupLocation(delegateTarget: self)
        
        // titleの設定
        if let title = searchText {
            navigationBar.topItem?.title = title
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        connector.stopDeviceMotion()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if (segue.identifier=="myRewindSegue") {//ここでB4でつけた名前を用いる。
            let vcA = segue.destination as! SearchViewController;// destinationViewController;
        }*/
    }
    
    
    func updateDeviceMotion(motion: CMDeviceMotion) {
        // ジャイロセンサー
        self.pitchLabel.text = String(format: "%0.2f", motion.attitude.pitch * 180.0 / Double.pi)
        self.rollLabel.text = String(format: "%0.2f", motion.attitude.roll * 180.0 / Double.pi)
        self.yawLabel.text = String(format: "%0.2f", motion.attitude.yaw * 180.0 / Double.pi)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.headingLabel.text = String(format: "%0.2f", newHeading.magneticHeading)
    }
    
    // 位置情報が取得されると呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 最新の位置情報を取得 locationsに配列で入っている位置情報の最後が最新となる
        let location : CLLocation = locations.last!;
        self.gpsXLabel.text = String(format: "%0.2f", location.coordinate.longitude)
        self.gpsYLabel.text = String(format: "%0.2f", location.coordinate.latitude)
        self.gpsHLabel.text = String(format: "%0.2f", location.altitude)
    }
    
    // 位置情報の取得に失敗すると呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .restricted) {
            print("機能制限している");
        }
        else if (status == .denied) {
            print("許可していない");
        }
        else if (status == .authorizedWhenInUse) {
            print("このアプリ使用中のみ許可している");
            connector.startHeading()
            connector.startLocation()
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            connector.startHeading()
            connector.startLocation()
        }
    }
}

