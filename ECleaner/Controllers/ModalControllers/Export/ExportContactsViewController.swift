//
//  ExportContactsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.11.2021.
//

import UIKit

class ExportContactsViewController: UIViewController {
    
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var topShevronView: UIView!
    @IBOutlet weak var controllerTitleTextLabel: UILabel!
    @IBOutlet weak var helperTopView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var bottomButtonView: BottomButtonBarView!
    @IBOutlet weak var mainContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftButtonView: ReuseShadowView!
    @IBOutlet weak var rightButtonView: ReuseShadowView!
    
    public var leftExportFileFormat: ExportContactsAvailibleFormat = .none
    public var rightExportFileFormat: ExportContactsAvailibleFormat = .none
    
    public var selectExportFormatCompletion: ((_ selectedFormat: ExportContactsAvailibleFormat) -> Void)?
    public var selectExtraOptionalOption: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateColors()
        setupDelegate()
    }
    
    override func viewDidLayoutSubviews() {
        
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
    }
    
    @IBAction func didTapLeftActionButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.selectExportFormatCompletion?(self.leftExportFileFormat)
        }
    }
    
    @IBAction func didTapRightActionButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.selectExportFormatCompletion?(self.rightExportFileFormat)
        }
    }
}

extension ExportContactsViewController: Themeble {
    
    private func setupUI() {
        
        let containerHeight: CGFloat = Device.isSafeAreaiPhone ? 380 : 360
        self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
        mainContainerHeightConstraint.constant = containerHeight
        
        mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
        topShevronView.setCorner(3)
        
        controllerTitleTextLabel.text = "select format of file"
        controllerTitleTextLabel.font = .systemFont(ofSize: 16.8, weight: .heavy)
    
        leftButton.setTitleColor(theme.titleTextColor, for: .normal)
        leftButton.titleLabel?.font = .systemFont(ofSize: 40, weight: .heavy)
        rightButton.setTitleColor(theme.titleTextColor, for: .normal)
        rightButton.titleLabel?.font = .systemFont(ofSize: 40, weight: .heavy)
        
        leftButton.setTitle(leftExportFileFormat.formatRowValue, for: .normal)
        rightButton.setTitle(rightExportFileFormat.formatRowValue, for: .normal)
        
        bottomButtonView.title("google contacts".uppercased())
        bottomButtonView.actionButton.imageSize = CGSize(width: 25, height: 20)
        bottomButtonView.setImage(I.systemItems.defaultItems.refresh)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = .clear
        mainContainerView.backgroundColor = theme.backgroundColor
        topShevronView.backgroundColor = theme.subTitleTextColor
        controllerTitleTextLabel.textColor = theme.titleTextColor
        leftButton.setTitleColor(theme.titleTextColor, for: .normal)
        rightButton.setTitleColor(theme.titleTextColor, for: .normal)
        bottomButtonView.buttonColor = theme.cellBackGroundColor
        bottomButtonView.buttonTintColor = theme.secondaryTintColor
        bottomButtonView.buttonTitleColor = theme.titleTextColor
        bottomButtonView.configureShadow = true
        bottomButtonView.addButtonShadow()
        bottomButtonView.updateColorsSettings()
    }

    private func setupDelegate() {
        
        bottomButtonView.delegate = self
    }
}

extension ExportContactsViewController: BottomActionButtonDelegate {
    
    func didTapActionButton() {
        selectExtraOptionalOption?()
    }
}


