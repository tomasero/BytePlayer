//
//  ViewController.swift
//  DTWSwift
//
//  Created by Abishkar Chhetri on 4/9/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import UIKit
import CoreMotion
import SocketIO
import CallKit
import UserNotifications

public class ViewController: UIViewController, CXProviderDelegate{
    
    
    let classifier = RTClassifier()
    let manager = SocketManager(socketURL: URL(string: "http://localhost:5000/")!, config: [.log(false), .compress])
    var socket:SocketIOClient!
    var timer = Timer()
//    let motionManager = CMMotionManager()
//    var gruController = GRUController()
    var gruController = Shared.instance.gruController
    var trained = false
//    var timer:Timer = Timer()
    @IBOutlet weak var doGestureButton: UIButton!
    @IBOutlet weak var vBatLbl: UILabel!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var left1: UIButton!
    @IBOutlet weak var left2: UIButton!
    @IBOutlet weak var left3: UIButton!
    @IBOutlet weak var right1: UIButton!
    @IBOutlet weak var right2: UIButton!
    @IBOutlet weak var right3: UIButton!
    @IBOutlet weak var front1: UIButton!
    @IBOutlet weak var front2: UIButton!
    @IBOutlet weak var front3: UIButton!
    @IBOutlet weak var none1: UIButton!
    @IBOutlet weak var none2: UIButton!
    @IBOutlet weak var none3: UIButton!
    @IBOutlet weak var tryBtn: UIButton!
    @IBOutlet weak var selSampleLbl: UILabel!
    @IBOutlet weak var trainBtn: UIButton!
    @IBOutlet weak var gestureLbl: UILabel!
    @IBOutlet weak var contBtn: UIButton!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var teethImg: UIImageView!
    @IBOutlet weak var headerLine: UIView!
    
    var audioVC: AudioViewController!
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let child = self.children.first
        if let aVC = child as? AudioViewController {
            self.audioVC = aVC
        }
        connectionView.frame.size.width = 25
        connectionView.frame.size.height = 25
        connectionView.backgroundColor = UIColor.red
        connectionView.layer.cornerRadius = connectionView.frame.size.width/2
        self.connectBtn.layer.zPosition = 2
        self.vBatLbl.layer.zPosition = 2
        self.connectionView.layer.zPosition = 2
        self.view.bringSubviewToFront(self.connectBtn)
        self.headerLine.layer.zPosition = 2
        // Do any additional setup after loading the view, typically from a nib.
//        self.gruController.initgruController()

//        let data = Helper.createDataDict(path: "data_csv")
//        print(data)
//        print(data["P1"])
//        print(data["P1"]?.leftSamples)
//        print(data["P1"]?.leftSamples[5].accX)
//        print(data["P1"]?.rightSamples[15].accX)
//        print(data["P1"]?.frontSamples[18].accX)
//        evaluateKNN(data: data)
        
        classifier.configure()
//        classifier.run()

        // Helps UI stay responsive even with timer.
//        startVBatUpdate()
        setupButtons()
        stopVBatUpdate()
        

        
//        let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "GestureClassifier"))
//        provider.setDelegate(self, queue: nil)
//        let update = CXCallUpdate()
//        update.remoteHandle = CXHandle(type: .generic, value: "BytePlayer")
//
        

        //initiate the phone call
//        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })

        
// configure sockets
        socket = manager.defaultSocket
//        socket.onAny {print("Got event: \($0.event), with items: \($0.items!)")}
        
        addHandlers()
        socket.connect()
    }


    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let notificationType = "a notification"
//
//            let alert = UIAlertController(title: "",
//                                          message: "After 5 seconds " + notificationType + " will appear",
//                                          preferredStyle: .alert)
//
//            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                
//                self.appDelegate?.scheduleNotification(notificationType: "Notification")
//            }
            
//            alert.addAction(okAction)
//            present(alert, animated: true, completion: nil)
    }


    
    // provider functions to configure the phone call
    public func providerDidReset(_ provider: CXProvider) {
        }
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
            action.fulfill()
        }
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
            action.fulfill()
        }
    
    func addHandlers() {
        socket.on("to_ios") {[weak self] data, ack in
            print("Received data!!")
            print(data)
            return
        }

        socket.on("my_event") {[weak self] data, ack in
            print("Received data my event!!")
            return
        }
        
        socket.on("my_response") {[weak self] data, ack in
            print("Received data my response!!")
            return
        }
        
        socket.on("trigger_call") {[weak self] data, ack in
            print("Triggering phone call!")
               let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "GestureClassifier"))
               provider.setDelegate(self, queue: nil)
               let update = CXCallUpdate()
               update.remoteHandle = CXHandle(type: .generic, value: "BytePlayer")
                    provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
            return
        }
        
    }
    
    func setupButtons() {
        let btns = [
            self.left1, self.left2, self.left3, self.right1,
            self.right2, self.right3,
            self.front1, self.front2, self.front3,
            self.none1, self.none2, self.none3
        ]
        for btn in btns {
            btn!.backgroundColor = UIColor.white
            btn!.layer.borderColor = UIColor.black.cgColor
            btn!.layer.borderWidth = 1
            btn!.layer.cornerRadius = btn!.frame.size.width/2
        }
    }
    
    func startVBatUpdate() {
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateBattery), userInfo: nil, repeats: true)
    }
    
    func stopVBatUpdate() {
        self.timer.invalidate()
        self.timer = Timer()
        self.vBatLbl.text = "0%"
    }
    
    func peripheralStateChanged(state: String) {
        if state == "Connected" {
            connected()
        } else {
            disconnected()
        }
    }
    
//    var date = Date.timeIntervalSinceReferenceDate
    @objc func updateBattery() {
        let vBat = self.gruController.getVBat()
        self.vBatLbl.text = String(vBat) + "%"
    }

    @IBAction func connect(_ sender: UIButton) {
        print(self.gruController.getPeripheralState())
        if self.gruController.getPeripheralState() == "Disconnected" {
            self.gruController.connect()
            sender.setTitle("Connecting", for: .normal)
        } else {
            self.gruController.disconnect()
            sender.setTitle("Disconnecting", for: .normal)
        }
    }
    
    func disconnected() {
        self.connectionView.backgroundColor = UIColor.red
        self.connectBtn.setTitle("Connect", for: .normal)
        stopVBatUpdate()
    }

    func connected() {
        self.connectionView.backgroundColor = UIColor.green
        self.connectBtn.setTitle("Disconnect", for: .normal)
        startVBatUpdate()
    }
    
    var cmds = ["l": "left", "r": "right", "f": "front", "n": "none"]
    var activeBtn: UIButton?
    @IBAction func selectSample(_ sender: UIButton) {
        if let id = sender.restorationIdentifier {
            let cmd = cmds[String(id.prefix(1))]!
            let num = id.dropFirst().prefix(1)
            print(cmd, num)
            if let prev = activeBtn {
                if prev == sender {
                    prev.backgroundColor = UIColor.white
                    activeBtn = nil
                    self.selSampleLbl.text = "None"
                    return
                } else {
                    if prev.backgroundColor == UIColor.lightGray {
                        prev.backgroundColor = UIColor.white
                    }
                }
            }
            sender.backgroundColor = UIColor.lightGray
            activeBtn = sender
            self.selSampleLbl.text = cmd.capitalized + " " + String(num)
        }
    }
    
    var isRecording = false
    @IBAction func gatherSample(_ sender: UIButton) {
        if self.gruController.getPeripheralState() == "Disconnected" {
            let alert = UIAlertController(title: "Please connect GRU", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //         alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if activeBtn == nil {
            let alert = UIAlertController(title: "Please select a sample", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if sender.title(for: .normal) == "Record" {
            activeBtn?.backgroundColor = UIColor.red
            sender.setTitle("Stop", for: .normal)
            if let active = self.activeBtn {
                let id = active.restorationIdentifier
                let cmd = cmds[String(id!.prefix(1))]!
                let num = id!.dropFirst().prefix(1)
                self.classifier.startTrain(gesture: cmd, number: Int(String(num))!)
            }
        } else {
            activeBtn?.backgroundColor = UIColor.darkGray
            sender.setTitle("Record", for: .normal)
            self.classifier.stopTrain()
        }
    }

    @IBAction func trainGestures(_ sender: UIButton) {
        let btns = [
                    self.left1, self.left2, self.left3,
                    self.right1, self.right2, self.right3,
                    self.front1, self.front2, self.front3,
                    self.none1, self.none2, self.none3
        ]
        for btn in btns {
            if btn!.backgroundColor != UIColor.darkGray {
                let alert = UIAlertController(title: "Please record all samples", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        }
        self.classifier.finalTrain()
        self.trained = true
    }
    
//        let vBat = self.gruController.getVBat()
////        let vBat = Date.timeIntervalSinceReferenceDate
//        self.vBatLabel.text = String(vBat) + "%"
//    }
//
    var cleanTimer = Timer()
    func cleanAfter(seconds: Double) {
        self.cleanTimer.invalidate()
        self.cleanTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { (timer) in
            self.teethImg.image = UIImage(named: "teeth.jpeg")
            self.gestureLbl.text = ""
        })
    }
    
    var isGesturing = false
    @IBAction func doGesture(_ sender: UIButton) {
        if !trained {
            let alert = UIAlertController(title: "Please train first", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if !isGesturing {
            sender.setTitle("Stop", for: .normal)
            classifier.startRecording()
            isGesturing = true
        } else {
            isGesturing = false
            var label = classifier.doPrediction()
                switch label {
            case "front":
                teethImg.image = UIImage(named: "front.jpeg")
                cleanAfter(seconds: 3.0)
                self.audioVC.playOrPauseMusic(self)
            case "left":
                teethImg.image = UIImage(named: "left.jpeg")
                cleanAfter(seconds: 3.0)
                self.audioVC.rewind(self)
            case "right":
                teethImg.image = UIImage(named: "right.jpeg")
                cleanAfter(seconds: 3.0)
                self.audioVC.fastforward(self)
            default:
                label = ""
            }
            self.gestureLbl.text = label
            sender.setTitle("Try", for: .normal)
        }
    }

}


//extension ViewController: UNUserNotificationCenterDelegate {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        switch response.actionIdentifier {
//        case Notification.Action.readLater:
//            print("Save Content For Later")
//        default:
//            print("Other Action")
//        }
//
//        completionHandler()
//    }
//}
