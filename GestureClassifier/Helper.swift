//
//  Helper.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/17/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import Foundation

class Participant {
    
    var name:String
    var leftSamples = Array<Sample>()
    var rightSamples = Array<Sample>()
    var frontSamples = Array<Sample>()
    
    init(name:String) {
        self.name=name
    }
}

class Sample {
    
    var number:Int = 0
    init(number:Int) {
        self.number = number
    }
    
    var accX = Array<Float>()
    var accY = Array<Float>()
    var accZ = Array<Float>()
    var gyrX = Array<Float>()
    var gyrY = Array<Float>()
    var gyrZ = Array<Float>()
    
    func normalizeVals() {
        let maxAccX = self.accX.max()
        self.accX = self.accX.map{$0/maxAccX!}
        
        let maxAccY = self.accY.max()
        self.accY = self.accY.map{$0/maxAccY!}
        
        let maxAccZ = self.accZ.max()
        self.accZ = self.accZ.map{$0/maxAccZ!}
        
        let maxGyrX = self.gyrX.max()
        self.gyrX = self.gyrX.map{$0/maxGyrX!}
        
        let maxGyrY = self.gyrY.max()
        self.gyrY = self.gyrY.map{$0/maxGyrY!}
        
        let maxGyrZ = self.gyrZ.max()
        self.gyrZ = self.gyrZ.map{$0/maxGyrZ!}
    }
}
