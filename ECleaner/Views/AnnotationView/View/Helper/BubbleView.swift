//
//  BubbleView.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.08.2022.
//

import UIKit

class BubbleView: UIView {
		
	let bubleSize: CGFloat = 70
	let offset: CGFloat = 3
	
	var lineWidth:    CGFloat = 1
	var cornerRadius: CGFloat = 10
	var triangleSize:  CGFloat = 5
	var fillColor:    UIColor = .clear
	var strokeColor:  UIColor = .clear
	
	private var imageView: UIImageView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		configure()
	}
		
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configure() {
		
		self.backgroundColor = UIColor.clear
		self.fillColor = theme.cellBackGroundColor
	}
	
	override func draw(_ rect: CGRect) {
		 let rect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
		 let path = UIBezierPath()

		 /// `lower left corner`
		 path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - triangleSize))
		 path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - triangleSize - cornerRadius), controlPoint: CGPoint(x: rect.minX, y: rect.maxY - triangleSize))

		 /// `left`
		 path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))

		 /// `upper left corner`
		 path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY), controlPoint: CGPoint(x: rect.minX, y: rect.minY))

		 /// `top`
		 path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))

		 /// `upper right corner`
		 path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius), controlPoint: CGPoint(x: rect.maxX, y: rect.minY))

		 /// `right`
		 path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - triangleSize - cornerRadius))

		 /// `lower right corner`
		 path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - triangleSize), controlPoint: CGPoint(x: rect.maxX, y: rect.maxY - triangleSize))

		 /// `bottom`
		 path.addLine(to: CGPoint(x: rect.midX + triangleSize, y: rect.maxY - triangleSize))
		 path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
		 path.addLine(to: CGPoint(x: rect.midX - triangleSize, y: rect.maxY - triangleSize))
		 path.close()

		 fillColor.setFill()
		 path.fill()

		 strokeColor.setStroke()
		 path.lineWidth = lineWidth
		 path.stroke()
	 }
}
