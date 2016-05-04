//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Victor Shurapov on 1/13/16.
//  Copyright © 2016 Victor Shurapov. All rights reserved.
//
import UIKit
import XCTest
@testable import Calculator

class CalculatorTests: XCTestCase {
    private var brain = CalculatorBrain()
    
    func testPushOperandVariable() {
        XCTAssertNil(brain.pushOperand("x"))
        brain.setVariable("x", value: 5.2)
        XCTAssertEqual(5.2, brain.pushOperand("x")!)
        XCTAssertEqual(10.4, brain.performOperation("+")!)
    }
    
    func testDisplayStack() {
        // cos(10)
        XCTAssertEqual(brain.pushOperand(10)!, 10)
        XCTAssertTrue(brain.performOperation("cos")! - -0.839 < 0.1)
        XCTAssertEqual(brain.description, "cos(10)")
        
    }
    
    func testDescription() {
        // 3 - 5
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.performOperation("-")!, -2)
        XCTAssertEqual(brain.description, "3 - 5")
        
        //23.5
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(23.5)!, 23.5)
        XCTAssertEqual(brain.description, "23.5")
        
        // π
        brain = CalculatorBrain()
        XCTAssertEqual(brain.performOperation("π")!, M_PI)
        XCTAssertEqual(brain.description, "π")
        
        // x
        brain = CalculatorBrain()
        XCTAssertNil(brain.pushOperand("x"))
        XCTAssertEqual(brain.description, "x")
        
        // √(10) + 3
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(10)!, 10)
        XCTAssertTrue(brain.performOperation("√")! - 3.162 < 0.1)
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertTrue(brain.performOperation("+")! - 6.162 < 0.1)
        XCTAssertEqual(brain.description, "√(10) + 3")
        
        // √(3 + 5)
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.performOperation("+")!, 8)
        XCTAssertTrue(brain.performOperation("√")! - 2.828 < 0.1)
        XCTAssertEqual(brain.description, "√(3 + 5)")
        
        // 3 + 5 + 4
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.pushOperand(4)!, 4)
        XCTAssertEqual(brain.performOperation("+")!, 9)
        XCTAssertEqual(brain.performOperation("+")!, 12)
        XCTAssertEqual(brain.description, "3 + 5 + 4")
        
        // (3 + 5) × 6
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.performOperation("+")!, 8)
        XCTAssertEqual(brain.pushOperand(6)!, 6)
        XCTAssertEqual(brain.performOperation("×")!, 48)
        XCTAssertEqual(brain.description, "(3 + 5) × 6")

        
        // √(3 + √(5)) ÷ 6
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertTrue(brain.performOperation("√")! - 2.236 < 0.1)
        XCTAssertTrue(brain.performOperation("+")! - 5.236 < 0.1)
        XCTAssertTrue(brain.performOperation("√")! - 2.288 < 0.1)
        XCTAssertEqual(brain.pushOperand(6)!, 6)
        XCTAssertTrue(brain.performOperation("÷")! - 0.381 < 0.1)
        XCTAssertEqual(brain.description, "√(3 + √(5)) ÷ 6")
        
        // ? + 3
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertNil(brain.performOperation("+"))
        XCTAssertEqual(brain.description, "? + 3")
        
        // √(3 + 5), cos(π)
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.performOperation("+")!, 8)
        XCTAssertTrue(brain.performOperation("√")! - 2.828 < 0.1)
        XCTAssertEqual(brain.performOperation("π")!, M_PI)
        XCTAssertEqual(brain.performOperation("cos")!, -1)
        XCTAssertEqual(brain.description, "√(3 + 5), cos(π)")
        
        // 3 * (5 + 4)
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.pushOperand(4)!, 4)
        XCTAssertEqual(brain.performOperation("+")!, 9)
        XCTAssertEqual(brain.performOperation("×")!, 27)
        XCTAssertEqual(brain.description, "3 × (5 + 4)")
        
        
        // 3 - (5 + 4) commutative test
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.pushOperand(4)!, 4)
        XCTAssertEqual(brain.performOperation("+")!, 9)
        XCTAssertEqual(brain.performOperation("-")!, -6)
        XCTAssertEqual(brain.description,"3 - (5 + 4)")
        
        // 3 / (5 × 4) commutative test
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.pushOperand(4)!, 4)
        XCTAssertEqual(brain.performOperation("×")!, 20)
        XCTAssertEqual(brain.performOperation("÷")!, 0.15)
        XCTAssertEqual(brain.description,"3 ÷ (5 × 4)")
        
        // (3 + 5) ÷ (7 + 8)
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.performOperation("+")!, 8)
        XCTAssertEqual(brain.pushOperand(7)!, 7)
        XCTAssertEqual(brain.pushOperand(8)!, 8)
        XCTAssertEqual(brain.performOperation("+")!, 15)
        XCTAssertTrue(brain.performOperation("÷")! - 0.53333 < 0.1)
        XCTAssertEqual(brain.description,"(3 + 5) ÷ (7 + 8)")
        
        // 3 - 5 - (7 - 8)
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.performOperation("-")!, -2)
        XCTAssertEqual(brain.pushOperand(7)!, 7)
        XCTAssertEqual(brain.pushOperand(8)!, 8)
        XCTAssertEqual(brain.performOperation("-")!, -1)
        XCTAssertEqual(brain.performOperation("-")!, -1)
        XCTAssertEqual(brain.description,"3 - 5 - (7 - 8)")
        
        // √((3 + 5) × (7 + 8))
        brain = CalculatorBrain()
        XCTAssertEqual(brain.pushOperand(3)!, 3)
        XCTAssertEqual(brain.pushOperand(5)!, 5)
        XCTAssertEqual(brain.performOperation("+")!, 8)
        XCTAssertEqual(brain.pushOperand(7)!, 7)
        XCTAssertEqual(brain.pushOperand(8)!, 8)
        XCTAssertEqual(brain.performOperation("+")!, 15)
        XCTAssertEqual(brain.performOperation("×")!, 120)
        XCTAssertTrue(brain.performOperation("√")! - 10.9544 < 0.1)
        XCTAssertEqual(brain.description,"√((3 + 5) × (7 + 8))")
    }
    
    func testSharedInstance_Unique() {
        let instance1 = NumberFormatter()
        let instance2 = NumberFormatter.formatter

        XCTAssertFalse(instance1 === instance2)
    }
}
