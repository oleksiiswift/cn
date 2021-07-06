//
//  CustomDoneHud.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit

//open class CustomDoneHud: NSObject {
//
//    public let sharedObject = CustomDoneHud()
//
//    internal static let theme = ThemeManager.currentTheme
//
//    internal static let isDarkMode = SettingsManager.sharedInstance.isDarkMode
//
//    internal static let style = ToastManager.shared.style
//
//    public static let checkmarkColor: UIColor = theme.mainSendButtonsBackgroundColor
//
//    public static let toastBackgroundColor: UIColor = theme.thumbBackgroundColor
//
//    static func showDoneHud() {
//
//        let toastView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
//        let toastViewSize = toastView.bounds.size
//        toastView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
//
//        let checkMarkImageView = UIImageView(image: I.ServiceItems.defaultCheckmark)
//        checkMarkImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        checkMarkImageView.center = CGPoint(x: toastViewSize.width / 2, y: toastViewSize.height / 2)
//        checkMarkImageView.tintColor = checkmarkColor
//
//        toastView.addSubview(checkMarkImageView)
//
//        toastView.clipsToBounds = true
//        toastView.layer.cornerRadius = style.cornerRadius
//        toastView.backgroundColor = toastBackgroundColor
//        U.delay(1) {
//            if let topController = getTheMostTopController()() {
//                topController.view.showToast(toastView, duration: 1.0, position: )
//            }
//        }
//    }
//}
//
//extension CustomDoneHud: Themeble {
//
//    func updateColors() {}
//}
//
//
