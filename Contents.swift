import UIKit

let negativeSignRegex = try! Regex(#"^-"#)

struct PatInt: CustomStringConvertible {
    let isNegative: Bool
    let wholeNumberDigits: [Int8]
    let decimalDigits: [Int8]
    let description: String
    let absolute: String
    init(_ raw: String) {
        guard raw.contains(try! Regex(#"^(-)?\d+(.\d+)?$"#)) else {
            wholeNumberDigits = [0]
            decimalDigits = [0]
            description = "0"
            absolute = description
            isNegative = false
            return
        }
        isNegative = raw.contains(negativeSignRegex)
        var numberText = raw.trimmingPrefix(negativeSignRegex).trimmingPrefix(try! Regex(#"^0+"#))
        if numberText.isEmpty {
            wholeNumberDigits = [0]
            decimalDigits = [0]
            description = "0"
            absolute = description
            return
        }
        if numberText.contains(try! Regex(#"\."#)) {
            numberText = numberText.replacing(try! Regex(#"0+$"#), with: "")
        } else {
            numberText += ".0"
        }
        let numberComponents = numberText.split(separator: ".")
        let wholeNumbersText = numberComponents[0] // this should be sure
        let decimalText: String
        if numberComponents.count > 1 {
            decimalText = String(numberComponents[1])
        } else {
            decimalText = "0"
        }
        
        wholeNumberDigits = wholeNumbersText.compactMap({Int8(String($0))})
        decimalDigits = decimalText.compactMap({Int8(String($0))})
        var absolute = wholeNumberDigits.map{"\($0)"}.joined()
        
        for digit in decimalDigits.reversed() {
            if(digit == 0) {
                continue
            }
            absolute += "." + decimalDigits.map{"\($0)"}.joined()
            break
        }
        self.absolute = absolute
        description = (isNegative ? "-" : "") + absolute
    }
    
    static func +(lhs: PatInt, rhs: PatInt) -> PatInt {
        guard lhs.isNegative == rhs.isNegative else {
            if lhs.isNegative {
                return rhs - PatInt(lhs.absolute)
            } else {
                return lhs - PatInt(rhs.absolute)
            }
        }
        var lWholeDigits = lhs.wholeNumberDigits
        var rWholeDigits = rhs.wholeNumberDigits
        let wholeDigits = max(lWholeDigits.count, rWholeDigits.count) + 1
        while lWholeDigits.count < wholeDigits {
            lWholeDigits.insert(0, at: 0)
        }
        while rWholeDigits.count < wholeDigits {
            rWholeDigits.insert(0, at: 0)
        }
        
        var lDecimalDigits = lhs.decimalDigits
        var rDecimalDigits = rhs.decimalDigits
        let decimalDigits = max(lDecimalDigits.count, rDecimalDigits.count)
        while lDecimalDigits.count < decimalDigits {
            lDecimalDigits.append(0)
        }
        while rDecimalDigits.count < decimalDigits {
            rDecimalDigits.append(0)
        }
        
        var decimalIdx = decimalDigits - 1
        var carried: Int8 = 0
        var newDecimalDigits: [Int8] = []
        while decimalIdx >= 0 {
            let lDigit = lDecimalDigits[decimalIdx]
            let rDigit = rDecimalDigits[decimalIdx]
            let res = lDigit + rDigit + carried
            let lastDigit = res % 10
            carried = res / 10
            newDecimalDigits.insert(lastDigit, at: 0)
            decimalIdx -= 1
        }
        
        var wholeIdx = wholeDigits - 1
        var newWholeDigits: [Int8] = []
        while wholeIdx >= 0 {
            let lDigit = lWholeDigits[wholeIdx]
            let rDigit = rWholeDigits[wholeIdx]
            let res = lDigit + rDigit + carried
            let lastDigit = res % 10
            carried = res / 10
            newWholeDigits.insert(lastDigit, at: 0)
            wholeIdx -= 1
        }
        let isNegative = lhs.isNegative || rhs.isNegative
        var final = (isNegative ? "-" : "") + newWholeDigits.map({"\($0)"}).joined()
        
        for digit in newDecimalDigits.reversed() {
            if(digit == 0) {
                continue
            }
            final += "." + newDecimalDigits.map{"\($0)"}.joined()
            break
        }
        
        return PatInt(final)
    }
    
    static func -(lhs: PatInt, rhs: PatInt) -> PatInt {
        switch (lhs.isNegative,rhs.isNegative) {
        case (true, false): return lhs + PatInt("-\(rhs)")
        case (false, true): return lhs + PatInt(rhs.absolute)
        default: break
        }
        var lWholeDigits = lhs.wholeNumberDigits
        var rWholeDigits = rhs.wholeNumberDigits
        
        let wholeDigits = max(lWholeDigits.count, rWholeDigits.count) + 1
        while lWholeDigits.count < wholeDigits {
            lWholeDigits.insert(0, at: 0)
        }
        while rWholeDigits.count < wholeDigits {
            rWholeDigits.insert(0, at: 0)
        }
        
        var lDecimalDigits = lhs.decimalDigits
        var rDecimalDigits = rhs.decimalDigits
        let decimalDigits = max(lDecimalDigits.count, rDecimalDigits.count)
        while lDecimalDigits.count < decimalDigits {
            lDecimalDigits.append(0)
        }
        while rDecimalDigits.count < decimalDigits {
            rDecimalDigits.append(0)
        }
        
        var isNegative = lhs.isNegative
        let allDigits = wholeDigits + decimalDigits
        let allLDigits = lWholeDigits + lDecimalDigits
        let allRDigits = rWholeDigits + rDecimalDigits
        print(allLDigits)
        print(allRDigits)
        for idx in 0..<allDigits {
            if(allLDigits[idx] == allRDigits[idx]) {
                continue
            }
            if(allRDigits[idx] > allLDigits[idx]) {
                isNegative = !rhs.isNegative
                // swap
                var temp = lWholeDigits
                lWholeDigits = rWholeDigits
                rWholeDigits = temp
                
                temp = lDecimalDigits
                lDecimalDigits = rDecimalDigits
                rDecimalDigits = temp
            }
            break
        }
        
        var decimalIdx = decimalDigits - 1
        var borrowed: Int8 = 0
        var newDecimalDigits: [Int8] = []
        while decimalIdx >= 0 {
            var lDigit = lDecimalDigits[decimalIdx] - borrowed
            borrowed = 0
            if lDigit < 0 {
                borrowed = 1
                lDigit += 10
            }
            let rDigit = rDecimalDigits[decimalIdx]
            if(lDigit < rDigit) {
                borrowed = 1
                lDigit += 10
            }
            let res = lDigit - rDigit
            let lastDigit = res % 10
            newDecimalDigits.insert(lastDigit, at: 0)
            decimalIdx -= 1
        }
        
        var wholeIdx = wholeDigits - 1
        var newWholeDigits: [Int8] = []
        while wholeIdx >= 0 {
            var lDigit = lWholeDigits[wholeIdx] - borrowed
            borrowed = 0
            if lDigit < 0 {
                borrowed = 1
                lDigit += 10
            }
            let rDigit = rWholeDigits[wholeIdx]
            if(lDigit < rDigit) {
                borrowed = 1
                lDigit += 10
            }
            let res = lDigit - rDigit
            let lastDigit = res % 10
            newWholeDigits.insert(lastDigit, at: 0)
            wholeIdx -= 1
        }
        var final = (isNegative ? "-" : "") + newWholeDigits.map({"\($0)"}).joined()
        
        for digit in newDecimalDigits.reversed() {
            if(digit == 0) {
                continue
            }
            final += "." + newDecimalDigits.map{"\($0)"}.joined()
            break
        }
        return PatInt(final)
    }
    
    static func *(lhs: PatInt, rhs: PatInt) -> PatInt {
        let lWholeDigits = lhs.wholeNumberDigits
        let rWholeDigits = rhs.wholeNumberDigits
        let lDecimalDigits = lhs.decimalDigits
        let rDecimalDigits = rhs.decimalDigits
        let allDecimalCount = lDecimalDigits.count + rDecimalDigits.count
        let allLDigits = [0] + lWholeDigits + lDecimalDigits
        let allRDigits = [0] + rWholeDigits + rDecimalDigits
        
        
        print("All R Digits = \(allRDigits)")
        print("All L Digits = \(allLDigits)")
        var rIdx = allRDigits.count - 1
        var addableDigitsSet: [String] = []
        while rIdx >= 0 {
            let rDigit = allRDigits[rIdx]
            
            var lIdx = allLDigits.count - 1
            var carried: Int8 = 0
            var additionDigits: [Int8] = []
            while lIdx >= 0 {
                let lDigit = allLDigits[lIdx]
                let res = lDigit * rDigit + carried
                let lastDigit = res % 10
                carried = res / 10
                additionDigits.insert(lastDigit, at: 0)
                lIdx -= 1
            }
            let iddx = allRDigits.count - 1 - rIdx
            if iddx > 0 {
                for _ in 0..<iddx {
                    additionDigits.append(0)
                }
            }
            print("\(allLDigits) * \(rDigit) = \(additionDigits)")
            addableDigitsSet.append(additionDigits.map({"\($0)"}).joined())
            rIdx -= 1
        }
        
        var sum = PatInt("")
        for addableDigit in addableDigitsSet {
            print("sum: \(sum) + \(addableDigit)")
            sum = sum + PatInt(addableDigit)
        }
        // fix decimal
        var newDigits = sum.wholeNumberDigits
        let decimalIdx = newDigits.count - allDecimalCount
        let newWhole = newDigits[0..<decimalIdx]
        let newDecimal = newDigits[decimalIdx..<newDigits.count]
        
        let isNegative = lhs.isNegative != rhs.isNegative
        let finalText = (isNegative ? "-" : "") + newWhole.map {"\($0)"}.joined() + "." + newDecimal.map {"\($0)"}.joined()
        print("Final Text: \(finalText)")
        return PatInt(finalText)
    }
}

let product: PatInt = PatInt("239.23") * PatInt("51.54")
print("Result: \(product)")

//print("P: \(PatInt("-0125"))")

//let sum: PatInt = PatInt("-135") + PatInt("-6223")
//print("Result: \(sum)")

//let sum: PatInt = PatInt("-135.44") + PatInt("-6223.753")
//print("Result: \(sum)")
//
//let diff: PatInt = PatInt("6203.72") - PatInt("135.69")
//print("Result: \(diff)")
//
//
//let diff: PatInt = PatInt("6203") - PatInt("135")
//print("Result: \(diff)")
//let diff: PatInt = PatInt("135") - PatInt("6203")
//print("Result: \(diff)")

var success = true
//for _ in 0..<100 {
//    let l = Double.random(in: -100...2000)
//    let r = Double.random(in: -100...2000)
//    let s = l + r
//
//    print("+!++++++")
//    let pl = PatInt("\(l)")
//    let pr = PatInt("\(r)")
//    let ps: PatInt = pl + pr
//
//    let isEqual = "\(s)" == "\(ps)"
//    success = success && isEqual
//    print("\(s) == \(ps) ? \(isEqual)")
//    if !isEqual {
//        print("Debug:")
//        print("L = \(l)")
//        print("R = \(r)")
//        print("PL = \(pl)")
//        print("PR = \(pr)")
//    }
//    print("++++++!+")
//}
//for _ in 0..<100 {
//    let l = Double.random(in: -1000...2000)
//    let r = Double.random(in: -1000...2000)
//    let d = l - r
//
//    print("-!------")
//    let pl = PatInt("\(l)")
//    let pr = PatInt("\(r)")
//    let pd: PatInt = pl - pr
//    let isEqual = "\(d)" == "\(pd)"
//    success = success && isEqual
//    print("\(d) == \(pd) ? \(isEqual)")
//    if !isEqual {
//        print("Debug:")
//        print("L = \(l)")
//        print("R = \(r)")
//        print("PL = \(pl)")
//        print("PR = \(pr)")
//    }
//    print("------!-")
//}

//for _ in 0..<100 {
//    let l = Int.random(in: -100...2000)
//    let r = Int.random(in: -100...2000)
//    let p = l * r
//
//    print("*!******")
//    let pl = PatInt("\(l)")
//    let pr = PatInt("\(r)")
//    let pp: PatInt = pl * pr
//
//    let isEqual = "\(p)" == "\(pp)"
//    success = success && isEqual
//    print("\(p) == \(pp) ? \(isEqual)")
//    if !isEqual {
//        print("Debug:")
//        print("L = \(l)")
//        print("R = \(r)")
//        print("PL = \(pl)")
//        print("PR = \(pr)")
//    }
//    print("******!*")
//}
//print("All Succeeded? \(success)")
