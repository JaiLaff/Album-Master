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
                print("Network Connection Found")
                print("Using expensive path: \(path.isExpensive)")
                isConnectedToNetwork = true
            } else {
                print("Network Connection Lost")
                
                isConnectedToNetwork = false
            }
        }
        
        print("Starting Network Handler...")

        monitor.start(queue: queue)
    }
    
    
}


