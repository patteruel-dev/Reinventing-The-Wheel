import UIKit

struct PatInt: CustomStringConvertible {
    let isNegative: Bool
    let wholeNumberDigits: [Int8]
    let description: String
    let absolute: String
    init(_ raw: String) {
        guard raw.contains(try! Regex(#"^(-)?\d+$"#)) else {
            wholeNumberDigits = [0]
            description = "0"
            absolute = description
            isNegative = false
            return
        }
        isNegative = raw.contains(try! Regex(#"^-"#))
        var trimmed = raw.trimmingPrefix(try! Regex(#"^-"#))
        trimmed = trimmed.trimmingPrefix(try! Regex(#"^0+"#))
        wholeNumberDigits = trimmed.compactMap({Int8(String($0))})
        absolute = wholeNumberDigits.map{"\($0)"}.joined()
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
        let digits = max(lWholeDigits.count, rWholeDigits.count) + 1
        while lWholeDigits.count < digits {
            lWholeDigits.insert(0, at: 0)
        }
        while rWholeDigits.count < digits {
            rWholeDigits.insert(0, at: 0)
        }
        var idx = digits - 1
        var carried: Int8 = 0
        var newWholeDigits: [Int8] = []
        while idx >= 0 {
            let lDigit = lWholeDigits[idx]
            let rDigit = rWholeDigits[idx]
            let res = lDigit + rDigit + carried
            let lastDigit = res % 10
            carried = res / 10
            newWholeDigits.insert(lastDigit, at: 0)
            idx -= 1
        }
        let isNegative = lhs.isNegative || rhs.isNegative
        let final = (isNegative ? "-" : "") + newWholeDigits.map({"\($0)"}).joined()
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
        print("Initial: \(lWholeDigits.map {"\($0)"}.joined()), \(rWholeDigits.map {"\($0)"}.joined())")
        let digits = max(lWholeDigits.count, rWholeDigits.count) + 1
        while lWholeDigits.count < digits {
            lWholeDigits.insert(0, at: 0)
        }
        while rWholeDigits.count < digits {
            rWholeDigits.insert(0, at: 0)
        }
        var isNegative = lhs.isNegative
        for idx in 0..<digits {
            if(lWholeDigits[idx] == rWholeDigits[idx]) {
                continue
            }
            if(rWholeDigits[idx] > lWholeDigits[idx]) {
                isNegative = !rhs.isNegative
                // swap
                var temp = lWholeDigits
                lWholeDigits = rWholeDigits
                rWholeDigits = temp
            }
            break
        }
        print("Evaluating: \(lWholeDigits.map {"\($0)"}.joined()), \(rWholeDigits.map {"\($0)"}.joined())")
        var idx = digits - 1
        var borrowed: Int8 = 0
        var newWholeDigits: [Int8] = []
        while idx >= 0 {
            var lDigit = lWholeDigits[idx] - borrowed
            borrowed = 0
            if lDigit < 0 {
                borrowed = 1
                lDigit += 10
            }
            let rDigit = rWholeDigits[idx]
            if(lDigit < rDigit) {
                borrowed = 1
                lDigit += 10
            }
            let res = lDigit - rDigit
            let lastDigit = res % 10
            newWholeDigits.insert(lastDigit, at: 0)
            idx -= 1
        }
        let final = (isNegative ? "-" : "") + newWholeDigits.map({"\($0)"}).joined()
        return PatInt(final)
    }
}

//print("P: \(PatInt("-0125"))")

let sum: PatInt = PatInt("-135") + PatInt("-6223")
print("Result: \(sum)")
//
//
//let diff: PatInt = PatInt("6203") - PatInt("135")
//print("Result: \(diff)")
let diff: PatInt = PatInt("135") - PatInt("6203")
print("Result: \(diff)")

var success = true
for _ in 0..<100 {
    let l = Int.random(in: -100...2000)
    let r = Int.random(in: -100...2000)
    let s = l + r

    print("+!++++++")
    let pl = PatInt("\(l)")
    let pr = PatInt("\(r)")
    let ps: PatInt = pl + pr

    let isEqual = "\(s)" == "\(ps)"
    success = success && isEqual
    print("\(s) == \(ps) ? \(isEqual)")
    if !isEqual {
        print("Debug:")
        print("L = \(l)")
        print("R = \(r)")
        print("PL = \(pl)")
        print("PR = \(pr)")
    }
    print("++++++!+")
}
for _ in 0..<100 {
    let l = Int.random(in: -1000...2000)
    let r = Int.random(in: -1000...2000)
    let d = l - r
    
    print("-!------")
    let pl = PatInt("\(l)")
    let pr = PatInt("\(r)")
    let pd: PatInt = pl - pr
    let isEqual = "\(d)" == "\(pd)"
    success = success && isEqual
    print("\(d) == \(pd) ? \(isEqual)")
    if !isEqual {
        print("Debug:")
        print("L = \(l)")
        print("R = \(r)")
        print("PL = \(pl)")
        print("PR = \(pr)")
    }
    print("------!-")
}
print("All Succeeded? \(success)")
