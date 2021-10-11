//
//  CustomActivityIndicator.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit

open class CustomActivityIndicator: NSObject {
    
    public static let sharedObject = CustomActivityIndicator()
    
    internal static let theme = ThemeManager.theme
    
    internal static var activityIndicatorView = UIActivityIndicatorView()
    
    internal static let activityIndicatorContainer = UIView()
    
    internal static let activityLoadingView = UIView()
    
    internal static var isActivityIndicatorShow: Bool = false
    
    internal static var isDarkMode = SettingsManager.sharedInstance.isDarkMode
    
    public static let controller = getTheMostTopController()
    
    public static var indicatorStyle: UIActivityIndicatorView.Style = UIActivityIndicatorView.Style.large
    
    public static let indicatorBackgroundColor: UIColor = theme.backgroundColor
    
    public static let indicatorColor = theme.accentBackgroundColor
    
    public static let blurIndicatorColor: UIColor = theme.activeTitleTextColor
    
    public static func showActivityIndicator(indicator style: UIActivityIndicatorView.Style = indicatorStyle,
                                             backgroundColor: UIColor = indicatorBackgroundColor,
                                             indicator color: UIColor = indicatorColor, ifNeedPresentCoontroller: UIViewController? = controller,
                                             blurIndicator: Bool = false,
                                             blur styleEffect: UIBlurEffect.Style? = nil, blurIndicatorColor: UIColor = blurIndicatorColor) {
        
        if Utils.isIpad {
            U.notificationCenter.addObserver(self, selector: #selector(update), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        if let controllerToPresent = ifNeedPresentCoontroller {
            let frame = controllerToPresent.view.frame
            let center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
           
            activityIndicatorContainer.frame = frame
            activityIndicatorContainer.center = center
            activityIndicatorContainer.backgroundColor = .clear
        
            activityLoadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            activityLoadingView.center = center
            activityLoadingView.clipsToBounds = true
            activityLoadingView.layer.cornerRadius = 10
            
            if !blurIndicator {
                activityLoadingView.backgroundColor = indicatorBackgroundColor
                activityIndicatorView.color = color
                
            } else {
                activityIndicatorView.color = blurIndicatorColor
                activityLoadingView.setupForSimpleBlurView(blur: .dark)
                activityLoadingView.alpha = 0.8
            }
            
            let loadingViewSize = activityLoadingView.frame.size
            
            activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activityIndicatorView.center = CGPoint(x: loadingViewSize.width / 2, y: loadingViewSize.height / 2)
            activityIndicatorView.style = style
            
            if !isActivityIndicatorShow {
                    activityIndicatorView.startAnimating()
                    activityLoadingView.addSubview(activityIndicatorView)
                    activityIndicatorContainer.addSubview(activityLoadingView)
                    controllerToPresent.view.addSubview(activityIndicatorContainer)
                    controllerToPresent.view.bringSubviewToFront(activityIndicatorContainer)
                    isActivityIndicatorShow = true
            }
        }
    }
    
    public static func hideActivityIndicator() {
        U.UI {
            isActivityIndicatorShow = false
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            activityLoadingView.removeFromSuperview()
            activityIndicatorContainer.removeFromSuperview()
            debugPrint("activity indicator hide")
        }
    }
    
    @objc public static func update() {
        if let topController = topController(), isActivityIndicatorShow {
            hideActivityIndicator()
            showActivityIndicator(ifNeedPresentCoontroller: topController, blurIndicator: true)
        }
    }
}

public enum PresenterPosition {
    case top
    case center
    case bottom
    
    fileprivate func centerPresenterPoint(for presenter: UIView, inSuperview superview: UIView) -> CGPoint {
        
        let  verticalPadding: CGFloat = 10.0
        
        let topPadding: CGFloat = verticalPadding + superview.safeAreaInsets.top
        let bottomPadding: CGFloat = verticalPadding + superview.safeAreaInsets.bottom
        
        switch self {
        case .top:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (presenter.frame.size.height / 2.0) + topPadding)
        case .center:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
        case .bottom:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (superview.bounds.size.height - (presenter.frame.size.height / 2.0)) - bottomPadding)
        }
    }
}

