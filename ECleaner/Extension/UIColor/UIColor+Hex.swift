//
//  UIColor+Hex.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import UIKit

extension UIColor {
    
    func colorFromHexString (_ hex: String) -> UIColor {
        
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func toHex() -> String {
        
        let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)!
        let colorRef = cgColorInRGB.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha
        
        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a * 255)))
        }
        color.removeFirst()
        return color.lowercased()
    }
}

//
extension UIColor {

    public convenience init(hex: String) {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        let red: CGFloat = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green: CGFloat = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue: CGFloat = CGFloat(rgbValue & 0x0000FF) / 255.0
        let alpha: CGFloat = CGFloat(1.0)

        self.init(red: red, green: green, blue: blue, alpha: alpha)
        return
    }
}

//typealias HexadecimalString = String
//
//extension UIColor {
//
//    convenience init(hex: HexadecimalString) {
//        var hexProcessed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexProcessed = hexProcessed.replacingOccurrences(of: "#", with: "")
//
//        //set up variables
//        //-
//        //unsigned integer
//        var rgb: UInt64 = 0
//        var r: CGFloat = 0.0
//        var g: CGFloat = 0.0
//        var b: CGFloat = 0.0
//        //alpha default = 1.0
//        var a: CGFloat = 1.0
//        let length = hexProcessed.count
//
//        //Scanning the string with scanner for unsigned values
//        guard Scanner(string: hexProcessed).scanHexInt64(&rgb) else { return }
//
//        //extract colors based on hex lenght
//        if length == 6 {
//            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//            b = CGFloat(rgb & 0x0000FF) / 255.0
//        } else if length == 8 {
//            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
//            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
//            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
//            a = CGFloat(rgb & 0x000000FF) / 255.0
//        } else {
//            return
//        }
//
//        //Creating UIColor instance with extracted values
//        self.init(red: r, green: g, blue: b, alpha: a)
//    }
//
//
//    // MARK: - Computed Properties
//
//    var hexString: HexadecimalString? {
//        return hexString()
//    }
//
//    // MARK: - From UIColor to Hex String
//
//    //One param: indicates if alpha value is included or not (bool)
//
//    func hexString(alpha: Bool = false) -> HexadecimalString? {
//
//        //Safely unwrapping because components property is type [CGFloat]?
//        //Also mage sure that it contains a minimum of 3 components
//        guard let components = cgColor.components, components.count >= 3 else {
//            return nil
//        }
//
//        //extract colors
//        let r = Float(components[0])
//        let g = Float(components[1])
//        let b = Float(components[2])
//        var a = Float(1.0)
//
//        //if there is an alpha value extract it too
//        if components.count >= 4 {
//            a = Float(components[3])
//        }
//
//        //create return string, round values with lroundf
//        //REMEMBER: - String formats:
//        // % defines the format specifier
//        // 02 defines the length of the string
//        // l casts the value to an unsigned long
//        // X prints the value in hexadecimal
//        if alpha {
//            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
//        }
//        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
//    }
//}
//
//
