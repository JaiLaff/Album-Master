//
//  NetworkHandler.swift
//  TableView
//
//  Created by Jai Lafferty on 12/6/19.
//  Copyright © 2019 Jai Lafferty. All rights reserved.
//

import Foundation
import Network
import UIKit

var isConnectedToNetwork = false

final class NetworkHandler {
    
    let monitor = NWPathMonitor()
    
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    init() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
                isConnectedToNetwork = true
            } else {
                print("No connection.")
                
                isConnectedToNetwork = false
            }
            
            print("Using expensive path: \(path.isExpensive)")
        }
        
        monitor.start(queue: queue)
    }
    
    
}


