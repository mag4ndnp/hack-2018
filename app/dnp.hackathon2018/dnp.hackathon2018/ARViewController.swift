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
    
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    // var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput?
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    // create instance of MotionManager
    let motionManager: CMMotionManager = CMMotionManager()
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startCaptureSesstion()
        
        setupGyro()
        startGyro()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置情報取得の精度
        locationManager.distanceFilter = 1; // 位置情報取得する間隔、1m単位とする
        
        // 何度動いたら更新するか（デフォルトは1度）
        locationManager.headingFilter = kCLHeadingFilterNone
        // デバイスのどの向きを北とするか（デフォルトは画面上部）
        locationManager.headingOrientation = .portrait
        
        locationManager.delegate = self
        
        // 位置情報の認証チェック
        let status = CLLocationManager.authorizationStatus()
        if (status == .notDetermined) {
            print("許可、不許可を選択してない");
            // 常に許可するように求める
            locationManager.requestAlwaysAuthorization();
        }
        else if (status == .restricted) {
            print("機能制限している");
            // 常に許可するように求める
            locationManager.requestAlwaysAuthorization();
        }
        else if (status == .denied) {
            print("許可していない");
            // 常に許可するように求める
            locationManager.requestAlwaysAuthorization();
        }
        else if (status == .authorizedWhenInUse) {
            print("このアプリ使用中のみ許可している");
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
    }
    
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.unspecified
        )
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            }
            /*
            else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }*/
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.cameraView.layer.insertSublayer(self.cameraPreviewLayer!, at: 1)
        self.view.sendSubviewToBack(self.cameraView)
    }
    
    func startCaptureSesstion() {
        captureSession.startRunning()
    }
    
    func setupGyro() {
        motionManager.deviceMotionUpdateInterval = 1/60
    }
    
    func startGyro() {
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            if let _motion = motion {
              self.updateMotion(motion: _motion)
            }
        }
    }
    
    
    func updateMotion(motion: CMDeviceMotion) {
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
            locationManager.startUpdatingLocation();
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingLocation();
        }
    }
}

