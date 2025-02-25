//
//  Colors.swift
//  BePresent
//
//  Created by Fernando Holguin on 24/2/25.
//

import SwiftUI

// Namespace to avoid collisions
struct BPColor {
    private init() {} // Prevent instantiation
}

// Extensions for BP namespace
extension BPColor {
    static let background = Color("Background")
    static let customBlack = Color("Custom Black")
    static let customGrey = Color("Custom Grey")
    static let customWhite = Color("Custom White")
    static let primaryBlue = Color("Primary blue")
    static let secondaryBlue = Color("Secondary Blue")
    // Secondary Blue is not adhering to the design at all using an alternative
    static let blueButton = Color("Blue Button")
}
