//
//  WebViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.10.2022.
//

import UIKit
import WebKit

class WebViewController: UIViewController, Storyboarded {

	@IBOutlet weak var mainNavigationBar: NavigationBar!
	@IBOutlet weak var navigationBar: StartingNavigationBar!
	@IBOutlet weak var navigationTopConstraint: NSLayoutConstraint!

	private weak var webView: WKWebView!
	private var activityIndicator = UIActivityIndicatorView(style: .large)
	
	private var margin: CGFloat = 20
	
	public var url: URL?

	public var coordinator: ApplicationCoordinator?
	public var presentationType: PresentedType = .present

	public var urlDidLoading: Bool = false {
		didSet {
			urlDidLoading ? activityIndicator.startAnimating() :  activityIndicator.stopAnimating()
			activityIndicator.isHidden = !urlDidLoading
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupNavigationBar()
		setupUI()
		updateColors()
		setupWeb()
		loadWeb(from: url)
    }

	private func loadWeb(from url: URL?) {
		
		urlDidLoading = true
		webView.loadUrlPage(url)
	}
}

extension WebViewController: StartingNavigationBarDelegate, NavigationBarDelegate {
	
	private func close() {
		self.coordinator?.closeWeb(controller: self, navigation: self.navigationController)
	}
	
	func didTapLeftBarButtonItem(_ sender: UIButton) {
		self.close()
	}
	
	func didTapRightBarButtonItem(_ sender: UIButton) {
		self.close()
	}
	
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.close()
	}
	
	func didTapRightBarButton(_ sender: UIButton) {
		self.close()
	}
}

extension WebViewController: UpdateColorsDelegate {
	
	private func setupWeb() {
		
		let webView = WKWebView()
		webView.translatesAutoresizingMaskIntoConstraints = false
		webView.navigationDelegate = self
		
		self.view.insertSubview(webView, at: 0)
		self.webView = webView
		webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		webView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
	}
	
	private func setupUI() {

	}
	
	private func addHelperNavigationViews() {
		
		let helperView = UIView()
		helperView.backgroundColor = theme.navigationBarBackgroundColor
		self.navigationBar.addSubview(helperView)
		helperView.translatesAutoresizingMaskIntoConstraints = false
		
		helperView.leadingAnchor.constraint(equalTo: self.navigationBar.leadingAnchor).isActive = true
		helperView.trailingAnchor.constraint(equalTo: self.navigationBar.trailingAnchor).isActive = true
		helperView.topAnchor.constraint(equalTo: self.navigationBar.topAnchor, constant: -40).isActive = true
		helperView.bottomAnchor.constraint(equalTo: self.navigationBar.topAnchor, constant: margin).isActive = true
		
		navigationBar.dropShadow = true
	}
	
	private func setupActivityIndicator() {
		
		self.view.addSubview(activityIndicator)
		
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
	}
	
	private func setupNavigationBar() {
		
		self.navigationController?.navigationBar.isHidden = true
		
		switch presentationType {
			case .window, .present:
				mainNavigationBar.isHidden = true
				navigationBar.delegate = self
				self.addHelperNavigationViews()
				navigationBar.setUpNavigation(title: title, rightImage: Images.systemItems.navigationBarItems.dissmiss)
			case .push:
				navigationBar.isHidden = true
				mainNavigationBar.delegate = self
				mainNavigationBar.setupNavigation(title: title, leftBarButtonImage: Images.systemItems.navigationBarItems.back, rightBarButtonImage: nil, contentType: .none)
		}
	}
	
	func updateColors() {
		
		navigationBar.backgroundColor = theme.navigationBarBackgroundColor
		self.view.backgroundColor = theme.backgroundColor
		self.activityIndicator.backgroundColor = theme.actionTintColor
	}
}

extension WebViewController: WKNavigationDelegate {
	
	func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		urlDidLoading = true
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		urlDidLoading = false
	}
}


extension WKWebView {
	
	func loadUrlPage(_ url: URL?) {
		
		guard let url = url else { return }
		
		load(URLRequest(url: url))
	}
}
