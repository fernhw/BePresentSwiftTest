//
//  DateFormatter.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

import Foundation

extension DateFormatter {
    static let mmddyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
}