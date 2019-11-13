//
//  Helper.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/17/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Participant {
    
    var name:String
    var leftSamples = Array<SampleData>()
    var rightSamples = Array<SampleData>()
    var frontSamples = Array<SampleData>()
    
    init(name:String) {
        self.name=name
    }
}

class SampleData {
    
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

class SampleBuffer {
    
    var accX : CircularBuffer
    var accY : CircularBuffer
    var accZ : CircularBuffer
    var gyrX : CircularBuffer
    var gyrY : CircularBuffer
    var gyrZ : CircularBuffer
    
    var number:Int = 0
    init(number:Int, count:Int) {
        self.number = number
        self.accX = CircularBuffer(count: count)
        self.accY = CircularBuffer(count: count)
        self.accZ = CircularBuffer(count: count)
        self.gyrX = CircularBuffer(count: count)
        self.gyrY = CircularBuffer(count: count)
        self.gyrZ = CircularBuffer(count: count)
    }
    
    func normalizeVals() {
        let maxAccX = self.accX.array.max()
        self.accX.array = self.accX.array.map{$0/maxAccX!}
        
        let maxAccY = self.accY.array.max()
        self.accY.array = self.accY.array.map{$0/maxAccY!}
        
        let maxAccZ = self.accZ.array.max()
        self.accZ.array = self.accZ.array.map{$0/maxAccZ!}
        
        //        let maxGyrX = self.gyrX.array.max()
        //        self.gyrX.array = self.gyrX.array.map{$0/maxGyrX!}
        //
        //        let maxGyrY = self.gyrY.array.max()
        //        self.gyrY.array = self.gyrY.array.map{$0/maxGyrY!}
        //
        //        let maxGyrZ = self.gyrZ.array.max()
        //        self.gyrZ.array = self.gyrZ.array.map{$0/maxGyrZ!}
    }
}


public struct CircularBuffer {
    fileprivate var array: [Float]
    fileprivate var writeIndex = 0
    
    public init(count: Int) {
        array = [Float](repeating: 0.0, count: count)
    }
    
    public mutating func write(element: Float) {
        array[writeIndex % array.count] = element
        writeIndex += 1
    }
    
    public func getArray() ->  Array<Float>{
        let readIndexStart = (writeIndex+1) % array.count
        let firstHalf = array[..<readIndexStart]
        let secondHalf = array[readIndexStart...]
        let newArray = secondHalf+firstHalf
        return Array(newArray)
    }
}

class Shared {
    private init() { }
    static let instance = Shared()
//    var gruController: GRUController = GRUController()
    var gruController: GRUController = GRUController()
    let activities = ["still", "walking", "running", "biking"]
    let classifier = RTClassifier()
    
    func getVC(name: String) -> UIViewController? {
        let children = UIApplication.shared.windows[0].rootViewController?.children
        for chichildren in children! {
            for child in chichildren.children {
                let vcName = NSStringFromClass(child.classForCoder).components(separatedBy: ".").last!
                if vcName == name {
                    return child
                }
            }
        }
        return nil
    }
    
//    func loadData(entityName: String) -> [NSManagedObject]? {
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return nil
//        }
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: entityName)
//        do {
//            let dataArray = try managedContext.fetch(fetchRequest)
//            return dataArray
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//        return nil
//    }
}
