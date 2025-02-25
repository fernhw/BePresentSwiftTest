//
//  SkeletonCellViewTests.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import XCTest
@testable import BePresent
import SwiftUI

class SkeletonCellViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitializationWithBaseDelay() {
        // Arrange & Act
        let view0 = SkeletonCellView(baseDelay: 0)
        let view100 = SkeletonCellView(baseDelay: 100)
        
        // Assert
        XCTAssertNotNil(view0)
        XCTAssertNotNil(view100)
    }
}
