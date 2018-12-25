//
//  SensorConnector.swift
//  dnp.hackathon2018
//
//  Created by tofubook on 2018/12/08.
//  Copyright © 2018年 tofubook. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMotion
import CoreLocation

class SensorConnector {
    // Camera
    var captureSession = AVCaptureSession()// デバイスからの入力と出力を管理するオブジェクトの作成
    var mainCamera: AVCaptureDevice?// メインカメラの管理オブジェクトの作成
    // var innerCamera: AVCaptureDevice?// インカメの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?// 現在使用しているカメラデバイスの管理オブジェクトの作成
    var photoOutput : AVCapturePhotoOutput?// キャプチャーの出力データを受け付けるオブジェクト
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?// プレビュー表示用のレイヤ
    
    let motionManager: CMMotionManager = CMMotionManager()
    let locationManager:CLLocationManager = CLLocationManager()
    
    func setupCamera() -> AVCaptureVideoPreviewLayer? {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
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
        
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        return cameraPreviewLayer
    }
    
    func startCameraSesstion() {
        captureSession.startRunning()
    }
    
    
    func setupDeviceMotion() {
        motionManager.deviceMotionUpdateInterval = 0.1
    }
    
    func startDeviceMotion(callback: @escaping (CMDeviceMotion) -> Void) {
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            if let _motion = motion {
                callback(_motion)
            }
        }
    }
    
    func stopDeviceMotion() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func setupLocation(delegateTarget:CLLocationManagerDelegate) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置情報取得の精度
        locationManager.distanceFilter = 1; // 位置情報取得する間隔、1m単位とする
        locationManager.delegate = delegateTarget
        
        // 認証チェック
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
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingLocation()
        }
    }
    
    func startLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func setupHeading (delegateTarget:CLLocationManagerDelegate) {
        // 何度動いたら更新するか（デフォルトは1度）
        locationManager.headingFilter = kCLHeadingFilterNone
        // デバイスのどの向きを北とするか（デフォルトは画面上部）
        locationManager.headingOrientation = .portrait
        locationManager.delegate = delegateTarget
        
        // 認証チェック
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
            locationManager.startUpdatingHeading()
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingHeading()
        }
    }
    
    func startHeading() {
        locationManager.startUpdatingHeading()
    }
}
