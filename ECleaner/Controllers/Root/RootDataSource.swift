//
//  RootDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.10.2022.
//

import Foundation

class RootDataSource: NSObject {
	
	public var rootViewModel: RootViewModel
	public var didSelectModel: ((MediaContentType) -> Void) = {_ in }
	
	public var delegate: RootViewModelDelegate?
	
	init(rootViewModel: RootViewModel) {
		self.rootViewModel = rootViewModel
	}
	
	private func configure(_ cell: MediaTypeCollectionViewCell, at indexPath: IndexPath) {
		let mediaContentype = rootViewModel.getRootModel(at: indexPath)
		let diskInUse = rootViewModel.getDiskSpace(of: mediaContentype)
		let itemCount = rootViewModel.getContentCount(of: mediaContentype)

		cell.configureCell(mediaType: mediaContentype, contentCount: itemCount, diskSpace: diskInUse)
	}
}

extension RootDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return rootViewModel.numberOfSections()
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return rootViewModel.numberOfRows(in: section)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.identifiers.cells.mediaTypeCell, for: indexPath) as! MediaTypeCollectionViewCell
		self.configure(cell, at: indexPath)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let content = rootViewModel.getRootModel(at: indexPath)
		self.didSelectModel(content)
	}
}
