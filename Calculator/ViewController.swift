//
//  ViewController.swift
//  Calculator
//
//  Created by Victor Shurapov on 11/24/15.
//  Copyright © 2015 Victor Shurapov. All rights reserved.
//
import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var separator: UIButton! {
        didSet {
            separator.setTitle(decimalSeparator, forState: .Normal)
        }
    }
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    let decimalSeparator = NumberFormatter.formatter.decimalSeparator ?? "."
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            // against second separator
            if digit == decimalSeparator && display.text?.rangeOfString(decimalSeparator) != nil {
                return
            }
            // against leading zeros
            if digit == "0" && ((display.text == "0") || (display.text == "-0")) {
                return
            }
            if digit != decimalSeparator && ((display.text == "0") || (display.text == "-0")) {
                display.text = digit; return
            }
            
            display.text = display.text! + digit
        } else {
            
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
            
        }
    }
    
    @IBAction func clearAll(sender: AnyObject) {
        brain.clearAll()
        displayResult = brain.evaluateAndReportErrors()
    }
    
    
    
    @IBAction func backSpace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.characters.count > 1 {
                display.text = String(display.text!.characters.dropLast())
            } else {
                display.text = "0"
            }
        } else {
            brain.popStack()
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    @IBAction func plusMinus(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.rangeOfString("-") != nil {
                display.text = String(display.text!.characters.dropFirst())
            } else {
                display.text = "-" + display.text!
            }
        } else {
            operate(sender)
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
            displayResult = brain.evaluateAndReportErrors()
        }
        
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let value = displayValue {
            brain.pushOperand(value)
        }
        displayResult = brain.evaluateAndReportErrors()
    }
    
    
    @IBAction func setVariable(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        
        let symbol = String(sender.currentTitle!.characters.dropFirst())
        if let value = displayValue {
            brain.setVariable(symbol, value: value)
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    
    @IBAction func pushVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        brain.pushOperand(sender.currentTitle!)
        displayResult = brain.evaluateAndReportErrors()
    }
    
    
    var displayResult: CalculatorBrain.Result = .Value(0.0) {
        didSet {
            display.text = displayResult.description
            userIsInTheMiddleOfTypingANumber = false
            history.text = brain.description + "="
        }
    }
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                return NumberFormatter.formatter.numberFromString(displayText)?.doubleValue
            }
            return nil
        }
    }
}