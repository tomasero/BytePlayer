//
//  RTClassifier.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/19/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import UIKit
import CoreMotion
import CoreML


public class RTClassifier: NSObject {
//    var exoEar = ExoEarController()
    var timer:Timer = Timer()
    //meta parameters
//    var motionManager = CMMotionManager()
    var data: Dictionary<String, Participant> = Dictionary<String, Participant>()
    let knn: KNNDTW = KNNDTW()
    var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
    var trainingData: Dictionary<String, Sample> = Dictionary<String, Sample>()
    
    var sample = Sample(number:0)
    
    struct ModelConstants {
        static let numOfFeatures = 6
        static let predictionWindowSize = 2000
        static let sensorsUpdateInterval = 1.0 / 20.0
        static let flexWindowSize = 100
    }
    //internal data structures
    
    func configure() {
        self.sample = Sample(number: 0)
        self.knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
//        self.knn.train(data_sets: training_samples)
//        self.exoEar.connectExoEar()
    }
    
    func performModelPrediction () -> String? {
        // Perform model prediction
        if training_samples.count < 6 {
            return "Need more training data"
        }
        print("Hold on...")
//        let prediction: knn_certainty_label_pair = knn.predict(curveToTestAccX: self.sample.accX, curveToTestAccY: self.sample.accY.suffix(ModelConstants.flexWindowSize), curveToTestAccZ: self.sample.accZ.suffix(ModelConstants.flexWindowSize), curveToTestGyrX: self.sample.gyrX.suffix(ModelConstants.flexWindowSize), curveToTestGyrY: self.sample.gyrY.suffix(ModelConstants.flexWindowSize), curveToTestGyrZ: self.sample.gyrZ.suffix(ModelConstants.flexWindowSize))
        let prediction: knn_certainty_label_pair = knn.predict(curveToTestAccX: self.sample.accX, curveToTestAccY: self.sample.accY, curveToTestAccZ: self.sample.accZ, curveToTestGyrX: self.sample.gyrX, curveToTestGyrY: self.sample.gyrY, curveToTestGyrZ: self.sample.gyrZ)
        
        print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
        
        print("Begin Gesture Now...")
        return prediction.label
    }
    
    func startTrain(gesture: String, number: Int) {
        let label = gesture + "-" + String(number)
        print("startTrain")
        print(label, number)
        self.trainingData[label] = Sample(number: 0)
        let vc = UIApplication.shared.keyWindow!.rootViewController as! ViewController
        let exoEar = vc.exoEar
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: ModelConstants.sensorsUpdateInterval, repeats: true) { timer in
            let data = exoEar.getData()
            self.trainingData[label]!.accX.append(Float(data[0].0))
            self.trainingData[label]!.accY.append(Float(data[0].1))
            self.trainingData[label]!.accZ.append(Float(data[0].2))
            self.trainingData[label]!.gyrX.append(Float(data[1].0))
            self.trainingData[label]!.gyrY.append(Float(data[1].1))
            self.trainingData[label]!.gyrZ.append(Float(data[1].2))
        }
        self.trainingData[label]?.normalizeVals()
    }
    
    func stopTrain() {
        print("stopTrain")
        self.timer.invalidate()
        self.timer = Timer()
    }
    
    func finalTrain() {
        for (label, sample) in self.trainingData {
            let properLabel = label.components(separatedBy: "-")[0]
            self.training_samples.append(knn_curve_label_pair(curveAccX: sample.accX, curveAccY: sample.accY, curveAccZ: sample.accZ , curveGyrX: sample.gyrX,curveGyrY: sample.gyrY, curveGyrZ: sample.gyrZ, label: properLabel))
        }
        if training_samples.count < 9 {
            print("ERROR: Need more training data")
        } else {
            self.knn.train(data_sets: self.training_samples)
            print("trained")
        }
    }
    
    public func startRecording() {
//        var currentIndexInPredictionWindow = 0
        
        //TODO:
        let vc = UIApplication.shared.keyWindow!.rootViewController as! ViewController
        let exoEar = vc.exoEar
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: ModelConstants.sensorsUpdateInterval, repeats: true) { timer in
            let data = exoEar.getData()
//            NSLog("")
            print(data)
            self.sample.accX.append(Float(data[0].0))
            self.sample.accY.append(Float(data[0].1))
            self.sample.accZ.append(Float(data[0].2))
            self.sample.gyrX.append(Float(data[1].0))
            self.sample.gyrY.append(Float(data[1].1))
            self.sample.gyrZ.append(Float(data[1].2))
        }
    }
    public func doPrediction() -> String {
        self.timer.invalidate()
        self.timer = Timer()
        let label = performModelPrediction()!
        self.sample = Sample(number: 0)
        return label
    }
}
