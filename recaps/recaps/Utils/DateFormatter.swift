//
//  DateFormatter.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 21/11/25.
//

import Foundation

extension Date {
    var ddMMyyyy: String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df.string(from: self)
    }
}
