//
//  UIAlertController+Colors.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.11.2021.
//

import UIKit

extension UIAlertController{

func addColorInTitleAndMessage(color:UIColor, titleFontSize:CGFloat = 18, messageFontSize: CGFloat = 13){

    let attributesTitle = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: titleFontSize)]
    let attributesMessage = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: messageFontSize)]
    let attributedTitleText = NSAttributedString(string: self.title ?? "", attributes: attributesTitle)
    let attributedMessageText = NSAttributedString(string: self.message ?? "", attributes: attributesMessage)

    self.setValue(attributedTitleText, forKey: "attributedTitle")
    self.setValue(attributedMessageText, forKey: "attributedMessage")

}}
