//Copyright (c) 2018 pikachu987 <pikachu77769@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import UIKit

/*
 It conveys the state change and touch of the NotificationView.
 */
internal protocol NotificationViewDelegate: class {
    /// Called when NotificationView is willAppear.
    func notificationViewWillAppear(_ notificationView: NotificationView)
    /// Called when NotificationView is didAppear.
    func notificationViewDidAppear(_ notificationView: NotificationView)
    /// Called when NotificationView is willDisappear.
    func notificationViewWillDisappear(_ notificationView: NotificationView)
    /// Called when NotificationView is didDisappear.
    func notificationViewDidDisappear(_ notificationView: NotificationView)
    /// Called when the NotificationView is touched.
    func notificationViewDidTap(_ notificationView: NotificationView)
}

internal extension NotificationViewDelegate {
    func notificationViewWillAppear(_ notificationView: NotificationView) { }
    func notificationViewDidAppear(_ notificationView: NotificationView) { }
    func notificationViewWillDisappear(_ notificationView: NotificationView) { }
    func notificationViewDidDisappear(_ notificationView: NotificationView) { }
    func notificationViewDidTap(_ notificationView: NotificationView) { }
}

/*
 Status of the NotificationView.
 */
internal enum NotificationViewState {
    case willAppear, didAppear, willDisappear, didDisappear, tap
}

/*
 Theme for NotificationView.
 */
internal enum NotificationViewTheme {
    case `default`
    case dark
    case custom
    
    var backgroundColor: UIColor? {
        switch self {
        case .default:
            return UIColor(white: 253/255, alpha: 0.98)
        case .dark:
            return UIColor(white: 3/255, alpha: 0.98)
        default:
            return nil
        }
    }
    var appNameColor: UIColor? {
        switch self {
        case .default:
            return UIColor(white: 80/255, alpha: 1)
        case .dark:
            return UIColor(white: 220/255, alpha: 1)
        default:
            return nil
        }
    }
    var dateColor: UIColor? {
        switch self {
        case .default:
            return UIColor(white: 110/255, alpha: 1)
        case .dark:
            return UIColor(white: 180/255, alpha: 1)
        default:
            return nil
        }
    }
    var titleColor: UIColor? {
        switch self {
        case .default:
            return UIColor.black
        case .dark:
            return UIColor.white
        default:
            return nil
        }
    }
    var subtitleColor: UIColor? {
        switch self {
        case .default:
            return UIColor.black
        case .dark:
            return UIColor.white
        default:
            return nil
        }
    }
    var bodyColor: UIColor? {
        switch self {
        case .default:
            return UIColor.black
        case .dark:
            return UIColor.white
        default:
            return nil
        }
    }
}

internal class NotificationView: NSObject {
    
    // MARK: delegate
    
    /// Connect the delegate to detect when the NotificationView touches or changes state
    weak var delegate: NotificationViewDelegate?
    
    
    // MARK: default
    
    /// The default View for NotificationView. Since it is static, you can call it anywhere.
    static let `default` = NotificationView()
    
    
    // MARK: Properties
    
    /// Theme for NotificationView. There are dark mode and default mode.
    var theme: NotificationViewTheme = NotificationViewTheme.default {
        willSet {
            self.backgroundColor = self.theme.backgroundColor
            self.appNameLabel.textColor = self.theme.appNameColor
            self.dateLabel.textColor = self.theme.dateColor
            self.titleLabel.textColor = self.theme.titleColor
            self.subtitleLabel.textColor = self.theme.subtitleColor
            self.bodyLabel.textColor = self.theme.bodyColor
        }
    }
    
    /// The time at the top right of NotificationView.
    var date: String? {
        set {
            self.dateLabel.text = newValue
        }
        get {
            return self.dateLabel.text
        }
    }
    
    /// The title of the NotificationView.
    var title: String? {
        set {
            self.bannerView.textContainerView.title = newValue
        }
        get {
            return self.bannerView.textContainerView.title
        }
    }
    
    /// The subtitle of the NotificationView.
    var subtitle: String? {
        set {
            self.bannerView.textContainerView.subtitle = newValue
        }
        get {
            return self.bannerView.textContainerView.subtitle
        }
    }
    
    /// The body of the NotificationView.
    var body: String? {
        set {
            self.bannerView.textContainerView.body = newValue
        }
        get {
            return self.bannerView.textContainerView.body
        }
    }
    
    /// The image of the NotificationView.
    var image: UIImage? {
        set {
            self.bannerView.textContainerView.image = newValue
        }
        get {
            return self.bannerView.textContainerView.image
        }
    }
    
    /// The background color of the NotificationView.
    var backgroundColor: UIColor? {
        set {
            self.bannerView.containerView.backgroundColor = newValue
        }
        get {
            return self.bannerView.containerView.backgroundColor
        }
    }
    
    /// It is a dictionary that can contain any data.
    var param: [AnyHashable : Any]?
    
    /// The identifier for the NotificationView.
    var identifier = ""
    
    /// The time until the NotificationView is shown and then disappears.
    var hideDuration: TimeInterval = 7
    
    /// An UIImageView that displays the AppIcon image.
    var iconImageView: UIImageView {
        return self.bannerView.iconImageView
    }
    
    /// An UILabel that displays the AppName text.
    var appNameLabel: UILabel {
        return self.bannerView.appNameLabel
    }
    
    /// An UILabel that displays the Date text.
    var dateLabel: UILabel {
        return self.bannerView.dateLabel
    }
    
    /// An UILabel that displays the Title text.
    var titleLabel: UILabel {
        return self.bannerView.textContainerView.titleLabel
    }
    
    /// An UILabel that displays the Subtitle text.
    var subtitleLabel: UILabel {
        return self.bannerView.textContainerView.subtitleLabel
    }
    
    /// An UILabel that displays the Body text.
    var bodyLabel: UILabel {
        return self.bannerView.textContainerView.bodyLabel
    }
    
    /// An UIImageView that displays the Image.
    var imageView: UIImageView {
        return self.bannerView.textContainerView.imageView
    }
    
    
    // MARK: Private Properties
    
    /// NotificationBannerView
    private lazy var bannerView: NotificationBannerView = {
        return NotificationBannerView(self)
    }()
    
    /// Callback function passing NotificationViewState
    private var handler: ((NotificationViewState) -> Void)?
    
    /// NotificationView Top Margin Value
    static var topHeight: CGFloat {
        return max(UIApplication.shared.statusBarFrame.height, 20)
    }
    
    
    // MARK: Life Cycle
    
    override init() {
        super.init()
        self.bannerView.delegate = self
    }
    
    init(_ title: String?, subtitle: String? = nil, body: String? = nil, image: UIImage? = nil, param: [AnyHashable : Any]? = nil, identifier: String = "") {
        super.init()
        self.bannerView.delegate = self
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.image = image
        self.param = param
        self.identifier = identifier
    }
    
    
    // MARK: Method
    
    /**
     A NotificationView is show.
     - Parameters:
     - handler: Callbacks to get NotificationViewState
     */
    func show(_ handler: ((NotificationViewState) -> Void)? = nil) {
        self.showAfter(0, handler: handler)
    }
    
    /**
     A NotificationView is show.
     - Parameters:
     - duration: Displayed after duration
     - handler: Callbacks to get NotificationViewState
     */
    func showAfter(_ duration: TimeInterval, handler: ((NotificationViewState) -> Void)? = nil) {
        self.handler = handler
        self.bannerView.theme = self.theme
        self.bannerView.setEntity(self.hideDuration)
        if self.bannerView.superview != nil { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            guard let window = UIApplication.shared.keyWindow else { return }
            self.delegate?.notificationViewWillAppear(self)
            self.handler?(.willAppear)
            window.addSubview(self.bannerView)
            self.bannerView.translatesAutoresizingMaskIntoConstraints = false
            let leadingConstraint = NSLayoutConstraint(item: window, attribute: .leading, relatedBy: .equal, toItem: self.bannerView, attribute: .leading, multiplier: 1, constant: -6)
            let trailingConstraint = NSLayoutConstraint(item: window, attribute: .trailing, relatedBy: .equal, toItem: self.bannerView, attribute: .trailing, multiplier: 1, constant: 6)
            leadingConstraint.priority = UILayoutPriority(950)
            trailingConstraint.priority = UILayoutPriority(950)
            let centerXConstraint = NSLayoutConstraint(item: window, attribute: .centerX, relatedBy: .equal, toItem: self.bannerView, attribute: .centerX, multiplier: 1, constant: 0)
            
            let topConstraint = NSLayoutConstraint(item: window, attribute: .top, relatedBy: .equal, toItem: self.bannerView, attribute: .top, multiplier: 1, constant: self.bannerView.height)
            topConstraint.priority = UILayoutPriority(950)
            let topLimitConstraint = NSLayoutConstraint(item: window, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.bannerView, attribute: .top, multiplier: 1, constant: -NotificationView.topHeight)
            window.addConstraints([
                leadingConstraint, trailingConstraint, topConstraint, topLimitConstraint, centerXConstraint
                ])
            
            window.layoutIfNeeded()
            topConstraint.constant = -NotificationView.topHeight
            UIView.animate(withDuration: 0.4, animations: {
                window.layoutIfNeeded()
            }, completion: { (_) in
                self.delegate?.notificationViewDidAppear(self)
                self.handler?(.didAppear)
            })
        }
    }
    
    /**
     A NotificationView is hide.
     */
    func hide() {
        self.hideAfter(0)
    }
    
    /**
     A NotificationView is hide.
     - Parameters:
     - duration: After duration, it disappears.
     */
    func hideAfter(_ duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.bannerView.hide()
        }
    }
}

// MARK: NotificationBannerViewDelegate
extension NotificationView: NotificationBannerViewDelegate {
    func notificationBannerViewDidDisappear(_ notificationBannerView: NotificationBannerView) {
        self.delegate?.notificationViewDidDisappear(self)
        self.handler?(.didDisappear)
    }
    func notificationBannerViewWillDisappear(_ notificationBannerView: NotificationBannerView) {
        self.delegate?.notificationViewWillDisappear(self)
        self.handler?(.willDisappear)
    }
    func notificationBannerViewDidTap(_ notificationBannerView: NotificationBannerView) {
        self.delegate?.notificationViewDidTap(self)
        self.handler?(.tap)
    }
}
