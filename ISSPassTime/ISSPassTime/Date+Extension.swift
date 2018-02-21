//
//  Date+Extension.swift
//  ISSPassTime
//
//  Created by Pooya Samizadeh on 2018-02-21.
//  Copyright © 2018 Pooya Samizadeh. All rights reserved.
//

import Foundation

extension Date {
    /// helper method for formatting the date to string
    var formatDataPointDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm:ss a z"
        return dateFormatter.string(from: self)
    }
}
