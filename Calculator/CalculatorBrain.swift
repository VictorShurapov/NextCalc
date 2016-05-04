//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Victor Shurapov on 12/8/15.
//  Copyright © 2015 Victor Shurapov. All rights reserved.
//

import Foundation


class CalculatorBrain {
    
    enum Result: CustomStringConvertible {
        case Value(Double)
        case Error(String)
        
        var description: String {
            switch self {
            case .Value(let value):
                return NumberFormatter.formatter.stringFromNumber(value) ?? ""
            case .Error(let errorMessage):
                return errorMessage
            }
        }
    }
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case ConstantOperation(String, () -> Double)
        case UnaryOperation(String, Double -> Double, (Double -> String?)?)
        case BinaryOperation(String, Int, Bool, (Double, Double) -> Double, ((Double, Double) -> String?)?)
        case Variable(String)
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .ConstantOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _, _, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                    
                }
            }
        }
        
        var precedence: Int {
            get {
                switch self {
                case .BinaryOperation(_, let precedence, _, _, _):
                    return precedence
                default:
                    return Int.max
                }
            }
        }
        
        var commutative: Bool {
            get {
                switch self {
                case .BinaryOperation(_, _, let commutative, _, _):
                    return commutative
                default:
                    return true
                }
            }
        }
    }
    
    
    
    
    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    private var variableValues = [String: Double]()
    
    
    func getVariable(symbol: String) -> Double? {
        return variableValues[symbol]
    }
    
    func setVariable(symbol: String, value: Double) {
        variableValues[symbol] = value
    }
    
    func clearVariables() {
        variableValues.removeAll()
    }
    
    func clearStack() {
        opStack.removeAll()
    }
    
    func clearAll() {
        clearVariables()
        clearStack()
    }
    
    init() {
        
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", 2, true, *, nil))
        learnOp(Op.BinaryOperation("÷", 2, false, { $1 / $0 }, { divisor, _ in return divisor == 0.0 ? "Division by zero" : nil }))
        learnOp(Op.BinaryOperation("+", 1, true, +, nil))
        learnOp(Op.BinaryOperation("-", 1, false, { $1 - $0 }, nil))
        learnOp(Op.UnaryOperation("√", sqrt, { $0 < 0 ? "√negative number" : nil }))
        learnOp(Op.UnaryOperation("sin", sin, nil))
        learnOp(Op.UnaryOperation("cos", cos, nil))
        learnOp(Op.UnaryOperation("±", { -$0 }, nil))
        learnOp(Op.ConstantOperation("π", { M_PI }))
        
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList { // guaranteed to be a PropertyList
        get {
            return opStack.map({ $0.description })
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NumberFormatter.formatter.numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    
    var description: String {
        get {
            var (result, remainder) = ("", opStack)
            var current: String
            repeat {
                (current, remainder, _) = description(remainder)
                result = result == "" ? current : "\(current), \(result)"
            } while remainder.count > 0
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String, remainingOps: [Op], precedence: Int) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
                
            case .Operand(let operand):
                return (NumberFormatter.formatter.stringFromNumber(operand) ?? "", remainingOps, op.precedence)
            case .ConstantOperation(let symbol, _):
                return (symbol, remainingOps, op.precedence)
            case .UnaryOperation(let symbol, _, _):
                let (operand, remainingOps, _) = description(remainingOps)
                    return ("\(symbol)(\(operand))", remainingOps, op.precedence)
            case .BinaryOperation(let symbol, _, _, _, _):
                
                var (operand1, remainingOps, precedenceOperand1) = description(remainingOps)
                if op.precedence > precedenceOperand1 || (op.precedence == precedenceOperand1 && !op.commutative) {
                    operand1 = "(\(operand1))"
                }
                
                var (operand2, remainingOpsOperand2, precedenceOperand2) = description(remainingOps)
                if op.precedence > precedenceOperand2 {
                    operand2 = "(\(operand2))"
                }
                return ("\(operand2) \(symbol) \(operand1)", remainingOpsOperand2, op.precedence)
                
            case .Variable(let symbol):
                return (symbol, remainingOps, op.precedence)
                
            }
        }
        return ("?", ops, Int.max)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .ConstantOperation(_, let operation):
                return (operation(), remainingOps)
            case .UnaryOperation(_, let operation, _):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, _, let operation, _):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return (nil, ops)
    }
    
    //    func displayStack() -> String? {
    //        return opStack.isEmpty ? nil : opStack.map{ $0.description }.joinWithSeparator(" ")
    //    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        if result != nil {
            if result!.isNaN || result!.isInfinite {
                return nil
            }
        }
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func popStack() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
    // recursive auxiliary function for evaluateAndReportErrors method
    
    private func evaluateResult(ops: [Op]) -> (result: Result, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (.Value(operand), remainingOps)
                
            case .Variable(let variable):
                if let varValue = variableValues[variable] {
                    return (.Value(varValue), remainingOps)
                }
                return (.Error("\(variable) didn`t set"), remainingOps)
                
            case .ConstantOperation(_, let operation):
                return (Result.Value(operation()), remainingOps)
                
            case .UnaryOperation(_, let operation, let errorTest):
                let operandEvaluation = evaluateResult(remainingOps)
                switch operandEvaluation.result {
                case .Value(let operand):
                    if let errMessage = errorTest?(operand) {
                        return (.Error(errMessage), remainingOps)
                    }
                    return (.Value(operation(operand)),
                        operandEvaluation.remainingOps)
                case .Error(let errMessage):
                    print(1)
                    return (.Error(errMessage), remainingOps)
                }
            case .BinaryOperation(_, _, _, let operation, let errorTest):
                let op1Evaluation = evaluateResult(remainingOps)
                switch op1Evaluation.result {
                    
                case .Value(let operand1):
                    let op2Evaluation = evaluateResult(op1Evaluation.remainingOps)
                    switch op2Evaluation.result {
                        
                    case .Value(let operand2):
                        if let errMessage = errorTest?(operand1, operand2) {
                            return (.Error(errMessage), op1Evaluation.remainingOps)
                        }
                        return (.Value(operation(operand1, operand2)),
                            op2Evaluation.remainingOps)
                    case .Error(let errMessage):
                        print(2)
                        return (.Error(errMessage), op1Evaluation.remainingOps)
                    }
                    
                    
                case .Error(let errMessage):
                    print(3)
                    return (.Error(errMessage), remainingOps)
                }
            }
        }
        return (.Error("Lack of operands"), ops)
    }
    
    // public method which is returning the evaluation of stack using Type Result
    
    func evaluateAndReportErrors() -> Result {
        if !opStack.isEmpty {
            return evaluateResult(opStack).result
        }
        return .Value(0)
    }
}

class NumberFormatter: NSNumberFormatter {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init() {
        super.init()
        self.locale = NSLocale.currentLocale()
        self.numberStyle = .DecimalStyle
        self.maximumFractionDigits = 10
        self.notANumberSymbol = "Error"
        self.groupingSeparator = " "
    }
    static var formatter = NumberFormatter()
}

