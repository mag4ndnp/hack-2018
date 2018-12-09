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
import SceneKit
import SpriteKit

struct SearchResult: Codable {
    let sort_type: String
    let results: [Result]
}
struct Result: Codable {
    let id: String
    let geometry: Geometry
}
struct Geometry: Codable {
    let lat:Double
    let lng:Double
}


class ARViewController: UIViewController, CLLocationManagerDelegate ,SCNSceneRendererDelegate {
    @IBOutlet weak var pitchLabel:UILabel!
    @IBOutlet weak var rollLabel:UILabel!
    @IBOutlet weak var yawLabel:UILabel!
    @IBOutlet weak var gpsXLabel:UILabel!
    @IBOutlet weak var gpsYLabel:UILabel!
    @IBOutlet weak var gpsHLabel:UILabel!
    @IBOutlet weak var headingLabel:UILabel!
    @IBOutlet weak var cameraView:UIView!
    @IBOutlet weak var navigationBar:UINavigationBar!
    
    @IBOutlet weak var sceneView: SCNView!
    
    var pitch:Double = 0.0
    var roll:Double = 0.0
    var yaw:Double = 0.0
    var heading:Double = 0.0
    var geoLat:Double = 0.0
    var getLng:Double = 0.0
    
    var searchResultData:Data?
    var searchResultJSON:SearchResult?
    
    var searchText:String?
    //var searchDistanceIndex:Int?
    
    var nodes:Array<SCNNode> = []
    
    let connector:SensorConnector = SensorConnector()
    
    
    // create and add a camera t the scene
    var cameraNode = SCNNode()
    
    
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
        
        loadJSON()
    
        //
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera t the scene
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x:0, y:0, z:0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLight.LightType.ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        sceneView.scene = scene
        sceneView.delegate = self
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        // show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.clear
        sceneView.overlaySKScene = OverlayScene(size:sceneView.bounds.size)
    }
    
    class OverlayScene: SKScene {
        var labelNode = SKLabelNode()
        var cursorNode: SKSpriteNode?
        
        override public init(size: CGSize){
            super.init(size: size)
            
            self.scaleMode = SKSceneScaleMode.resizeFill
            self.backgroundColor = UIColor.clear
            
            //テキストラベル
            labelNode.fontSize = 20
            labelNode.position.y = 0
            labelNode.position.x = 0
            self.addChild(labelNode)
            
            //カーソル
            cursorNode = SKSpriteNode(imageNamed: "pin_selected.png")
            cursorNode?.size = CGSize.init(width: 50, height: 71)
            self.addChild(cursorNode!)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didRenderScene scene: SCNScene,
                  atTime time: TimeInterval) {
        
        for node in nodes {
            if let overlay = sceneView.overlaySKScene as? OverlayScene {
                
                //ノードの現在地を2Dに変換
                let p = sceneView.projectPoint(node.presentation.position)
                
                //テキストに３Dモデルのx y zを記述
                overlay.labelNode.text = String(format: "%03.1f, %03.1f, %03.1f",
                                                node.presentation.position.x,
                                                node.presentation.position.y,
                                                node.presentation.position.z)
                
                let x = p.x
                let y = p.y
                
                //カーソルをx y に移動
                overlay.cursorNode?.position = CGPoint(x:CGFloat(x),
                                                       y:sceneView.bounds.maxY - CGFloat(y))
                
                //ラベルをx y に移動
                overlay.labelNode.position = CGPoint(x:CGFloat(x),
                                                     y:sceneView.bounds.maxY - CGFloat(y) + 40)
            }
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
    
    func loadJSON(){
        guard let data = try? getJSONData() else { return }
        let decoder: JSONDecoder = JSONDecoder()
        do {
            let json = try decoder.decode(SearchResult.self, from: data!)
        } catch let error {
            print("Error = \(error)")
        }
        //guard let json = try? decoder.decode(SearchResult.self, from: data!) else { return }
        
        //searchResultData = data
        //searchResult = json
        //createCoodinate()
    }
    
    func getJSONData() throws -> Data? {
        guard let path = Bundle.main.path(forResource: "geolocation", ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        return try Data(contentsOf: url)
    }
    
    func createCoodinate() {
        let results = searchResultJSON?.results as! Array<Result>
        self.nodes.removeAll()
        
        for var result in results {
            let lat = result.geometry.lat - geoLat
            let lng = result.geometry.lng - getLng
            
            // create and add a 3D box to the scene
            let boxNode = SCNNode()
            boxNode.geometry = SCNBox(width:1, height:1, length:1, chamferRadius:0.02)
            boxNode.position = SCNVector3(lng, 0, lat)
            boxNode.isHidden = true
            sceneView.scene?.rootNode.addChildNode(boxNode)
            print(boxNode.position)
            /*
             // create and configure a material
             let material = SCNMaterial()
             material.diffuse.contents = UIImage(named:"texture")
             material.specular.contents = UIColor.gray
             material.locksAmbientWithDiffuse = true
             
             // set the material to the 3D object geometry
             //boxNode.geometry?.firstMaterial = material
             */
            
            self.nodes.append(boxNode)
        }
    }
    
    
    func updateDeviceMotion(motion: CMDeviceMotion) {
        // ジャイロセンサー
        self.pitchLabel.text = String(format: "%0.2f", motion.attitude.pitch)
        self.rollLabel.text = String(format: "%0.2f", motion.attitude.roll * 180.0 / Double.pi)
        self.yawLabel.text = String(format: "%0.2f", motion.attitude.yaw * 180.0 / Double.pi)
        
        pitch = motion.attitude.pitch
        roll = motion.attitude.roll
        yaw = motion.attitude.yaw
        
        setPinRotation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.headingLabel.text = String(format: "%0.2f", newHeading.magneticHeading)
        heading = newHeading.magneticHeading
        
        setPinRotation()
    }
    
    // 位置情報が取得されると呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 最新の位置情報を取得 locationsに配列で入っている位置情報の最後が最新となる
        let location : CLLocation = locations.last!;
        self.gpsXLabel.text = String(format: "%0.10f", location.coordinate.latitude)
        self.gpsYLabel.text = String(format: "%0.10f", location.coordinate.latitude)
        self.gpsHLabel.text = String(format: "%0.10f", location.altitude)
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
    
    func setPinRotation() {
        let _pitch = pitch - (90 * (Double.pi / 180))
        let _heading = heading * (Double.pi / 180)
        cameraNode.eulerAngles = SCNVector3(_pitch, -_heading, 0)
    }
}

