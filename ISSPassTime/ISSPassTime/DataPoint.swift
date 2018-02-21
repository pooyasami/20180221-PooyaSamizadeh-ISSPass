//
//  DataPoint.swift
//  ISSPassTime
//
//  Created by Pooya Samizadeh on 2018-02-21.
//  Copyright © 2018 Pooya Samizadeh. All rights reserved.
//

import UIKit

struct DataPoint: Codable {
    var risetime: Int?
    
    var riseTimeDate: Date? {
        if let riseTime = risetime {
            return Date(timeIntervalSince1970: TimeInterval(riseTime))
        }
        
        return nil
    }
    
    var duration: Int?
}
