//
//  GroupContactTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.10.2021.
//

import UIKit
import Contacts

protocol GroupContactSelectableDelegate: AnyObject {
    
    func didSelecMeregeSection(at index: Int)
}

class GroupContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sectionShadowView: SectionShadowView!
    @IBOutlet weak var shadowRoundedReuseView: ReuseShadowRoundedView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var contactTitleTextLabel: UILabel!
    @IBOutlet weak var contactSubtitleTextLabel: UILabel!
    @IBOutlet weak var selectableButton: UIButton!
    @IBOutlet weak var topBaseViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBaseViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectableContactImageView: UIImageView!
	@IBOutlet weak var selectableContactImageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var shadowRoundedViewHeightConstraint: NSLayoutConstraint!
	
	private var customSeparator = UIView()
    private let helperSeparatorView = UIView()

    private var isFirstRowInSection: Bool = false
    private var isLastRowInSection: Bool = false

    private var isSelectableSection: Bool = false
    
    public var delegate: GroupContactSelectableDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.superReuseElemnt()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        updateColors()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didTapSelectSection(_ sender: Any) {
    
        delegate?.didSelecMeregeSection(at: tag)
        checkSelecttion()
    }
}

extension GroupContactTableViewCell {
    
    public func updateContactCell(_ contact: CNContact, rowPosition: RowPosition, sectionIndex: Int, isSelected: Bool) {
        
        self.tag = sectionIndex
        self.showCellInset(at: rowPosition)
        self.isSelectableSection = isSelected
        self.sectionShadowView.sectionRowPosition = rowPosition
        self.setupContact(contact)
        
        switch rowPosition {
            case .top:
                self.setBestContactMerge(isShow: true)
                self.setupForCustomSeparator()
            case .middle:
                self.setBestContactMerge(isShow: false)
                self.setupForCustomSeparator()
            default:
                self.setBestContactMerge(isShow: false)
        }
    }
    
    private func setupContact(_ contact: CNContact) {
        
        let contactFullName = CNContactFormatter.string(from: contact, style: .fullName)
        
        contactTitleTextLabel.text = contactFullName
        
        let numbers = contact.phoneNumbers.map({$0.value.stringValue})
    
        contactSubtitleTextLabel.text = numbers.joined(separator: numbers.count > 1 ? ", " : "")
    
        if let imageData = contact.thumbnailImageData, let image = UIImage(data: imageData) {
            shadowRoundedReuseView.setImage(image)
        } else {
            shadowRoundedReuseView.setImage(I.personalisation.contacts.contactPhoto)
        }
    }
    
    private func setBestContactMerge(isShow: Bool) {
        
        selectableButton.isEnabled = isShow
        
        if isShow {
            selectableContactImageView.image = self.isSelectableSection ? I.personalisation.contacts.sectionSelect : I.personalisation.contacts.deselectContact
            selectableContactImageView.isHidden = false
        } else {
            selectableContactImageView.image = nil
            selectableContactImageView.isHidden = true
        }
    }
    
    private func checkSelecttion() {
        
        guard selectableButton.isEnabled else { return }
        
        self.isSelectableSection = !self.isSelectableSection
        setBestContactMerge(isShow: true)
    }
}

extension GroupContactTableViewCell: Themeble {

    private func setupUI() {
        
        selectionStyle = .none
		contactTitleTextLabel.font = FontManager.contactsFont(of: .cellTitle)
		contactSubtitleTextLabel.font = FontManager.contactsFont(of: .cellSubtitle)
		shadowRoundedViewHeightConstraint.constant = U.UIHelper.AppDimensions.Contacts.Collection.helperImageViewWidth
		selectableContactImageViewWidthConstraint.constant = U.UIHelper.AppDimensions.Contacts.Collection.selectableGoupAssetViewWidth
    }
    
    func updateColors() {

        sectionShadowView.backgroundColor = .clear
        baseView.backgroundColor = .clear
        
        contactTitleTextLabel.textColor = theme.titleTextColor
        contactSubtitleTextLabel.textColor = theme.contactsTintColor

        customSeparator.backgroundColor = theme.separatorMainColor
        helperSeparatorView.backgroundColor = theme.separatorHelperColor
        
        shadowRoundedReuseView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor.withAlphaComponent(0.5))
    }
    
    /// `inset` for first and last cell in section for extra shadow
    private func showCellInset(at position: RowPosition) {
        
        self.topBaseViewConstraint.constant = position == .top ? 20 : 0
        self.bottomBaseViewConstraint.constant = position == .bottom ? 20 : 0
        self.baseView.layoutIfNeeded()
    }
        
    public func setupForCustomSeparator() {
                
        self.baseView.addSubview(customSeparator)
        customSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        customSeparator.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 23).isActive = true
        customSeparator.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -23).isActive = true
        customSeparator.heightAnchor.constraint(equalToConstant: 3).isActive = true
        customSeparator.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: 0).isActive = true
        
        customSeparator.addSubview(helperSeparatorView)
        helperSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        helperSeparatorView.leadingAnchor.constraint(equalTo: customSeparator.leadingAnchor).isActive = true
        helperSeparatorView.trailingAnchor.constraint(equalTo: customSeparator.trailingAnchor).isActive = true
        helperSeparatorView.bottomAnchor.constraint(equalTo: customSeparator.bottomAnchor).isActive = true
        helperSeparatorView.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
    }

    private func superReuseElemnt() {
        
        /// for best reuse background shadows and reuse corners radii need renove somer parsts of ui
        /// in section shadow need remove layers with corners radii
        
        isSelected = false
        
        contactTitleTextLabel.text = nil
        contactSubtitleTextLabel.text = nil
        selectableContactImageView.image = nil
        
        shadowRoundedReuseView.setImage()
        sectionShadowView.prepareForReuse()
        
        customSeparator.removeFromSuperview()
        helperSeparatorView.removeFromSuperview()
        
        topBaseViewConstraint.constant = 0
        bottomBaseViewConstraint.constant = 0
    }
}
