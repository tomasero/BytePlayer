//
//  Socket.swift
//  GestureClassifier
//
//  Created by Shardul Sapkota on 7/2/20.
//  Copyright © 2020 Abishkar Chhetri. All rights reserved.
//

import Foundation
import UIKit

protocol SocketDelegate: class {
  func received(message: String)
}

class Socket: NSObject, StreamDelegate{
     //1
     var inputStream: InputStream!
     var outputStream: OutputStream!
     
     weak var delegate: SocketDelegate?
     
     //2
     var username = ""
     
     //3
     let maxReadLength = 4096
     
     func setupNetworkCommunication() {
       // 1
        print("Setting up!!!")
       var readStream: Unmanaged<CFReadStream>?
       var writeStream: Unmanaged<CFWriteStream>?
       
       // 2
       CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                          "localhost" as CFString,
                                          5000,
                                          &readStream,
                                          &writeStream)
       
       inputStream = readStream!.takeRetainedValue()
       outputStream = writeStream!.takeRetainedValue()
       
       inputStream.delegate = self
       
       inputStream.schedule(in: .current, forMode: .common)
       outputStream.schedule(in: .current, forMode: .common)
       
       inputStream.open()
       outputStream.open()
     }
    
    
}
