//
//  Helper.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/17/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import Foundation


class Helper{
    static func readDataFromCSV(fileName:String, fileType: String, path:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType, inDirectory: path)
            else {
                print("first")
                return nil
        }
        
        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    static func listFilesInDirectory(path:String) -> Array<String> {
        var files = Array<String>()
        
        let fm = FileManager.default
        let root_path = Bundle.main.resourcePath!
        do {
            let items = try fm.contentsOfDirectory(atPath: root_path + "/" + path)
            
            for item in items {
                files.append(item)
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print("Unexpected error: \(error).")
        }
        return files
    }
    
    static func populateValues(sampleData:String, sample:Sample) -> () {
        var dataArray = sampleData.components(separatedBy: "\n")
        dataArray.removeFirst(1)
        for row in dataArray {
            if row.count > 0 {
                let rowArray = row.components(separatedBy: ",").map {Float($0)}
                sample.accX.append(rowArray[0]!)
                sample.accY.append(rowArray[1]!)
                sample.accZ.append(rowArray[2]!)
                sample.gyrX.append(rowArray[3]!)
                sample.gyrY.append(rowArray[4]!)
                sample.gyrZ.append(rowArray[5]!)
            }
        }
        sample.normalizeVals()
    }
    static func createDataDict(path:String) -> Dictionary<String, Participant> {
        var data: [String: Participant] = [:]
        let participantFiles = listFilesInDirectory(path: path)
        
        for participantfileName in participantFiles { //P1-FT, P2-LT, ....
            let participantfileNameArr = participantfileName.components(separatedBy: "-")
            let participantName = participantfileNameArr[0]
            let gestureDirection = participantfileNameArr[1]
            
            let participantPath = path+"/"+participantfileName
            let sampleFiles = self.listFilesInDirectory(path: participantPath)
            
            if !data.keys.contains(participantName) {
                data[participantName] = Participant(name: participantName)
            }
            
            let participant = data[participantName]!
            
            var participantGesture = Array<Sample>()
            var n = 0
            for sampleFileName in sampleFiles {
                let sampleFileNameWithoutExt = sampleFileName.components(separatedBy: ".")[0]
                let sampleData = readDataFromCSV(fileName: sampleFileNameWithoutExt, fileType: "csv", path: participantPath)
                
                let sampleFileNameWithoutExtArr = sampleFileNameWithoutExt.components(separatedBy: "-")
                
                var sample:Sample
                
                if sampleFileNameWithoutExtArr.count == 2 {
                    sample = Sample(number: Int(sampleFileNameWithoutExtArr[1])!)
                } else {
//                    sample = Sample(number: 0)
                    sample = Sample(number: n)
                }
                populateValues(sampleData: sampleData!, sample: sample)
                participantGesture.append(sample)
                n+=1
            }
            n = 0
            
            switch gestureDirection {
            case "FT":
                participant.frontSamples = participantGesture
            case "LT":
                participant.leftSamples = participantGesture
            case "RT":
                participant.rightSamples = participantGesture
            default:
                print("Wrong Value in Participant Gesture")
                participantGesture = Array<Sample>()
            }
        }
        
        return data
    }

}


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
