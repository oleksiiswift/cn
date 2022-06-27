//
//  OnboardingPages.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2022.
//

import SwiftUI

enum OnboardingPage: CaseIterable {
	 case welcome
	 case newFeature
	 case permissions
	 case sales
	 
	 static let fullOnboarding = OnboardingPage.allCases
	 
	 var shouldShowNextButton: Bool {
		 switch self {
		 case .welcome, .newFeature:
			 return true
		 default:
			 return false
		 }
	 }
	 
	 @ViewBuilder
	 func view(action: @escaping () -> Void) -> some View {
		 switch self {
		 case .welcome:
			 Text("Welcome")
		 case .newFeature:
			 Text("See this new feature!")
		 case .permissions:
			 HStack {
				 Text("We need permissions")
				 
				 // This button should only be enabled once permissions are set:
				 Button(action: action, label: {
					 Text("Continue")
				 })
			 }
		 case .sales:
			 Text("Become PRO for even more features")
		 }
	 }
 }

struct OnboardingView: View {
	
	@State private var currentPage: OnboardingPage = .welcome
	private let pages: [OnboardingPage]
	
	init(pages: [OnboardingPage]) {
		self.pages = pages
	}
	
	var body: some View {
		VStack {
			ForEach(pages, id: \.self) { page in
				if page == currentPage {
					page.view(action: showNextPage)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.transition(AnyTransition.asymmetric(
										insertion: .move(edge: .trailing),
										removal: .move(edge: .leading))
									)
						.animation(.default)
				}
			}
			
			if currentPage.shouldShowNextButton {
				HStack {
					Spacer()
					Button(action: showNextPage, label: {
						Text("Next")
					})
				}
				.padding(EdgeInsets(top: 0, leading: 50, bottom: 50, trailing: 50))
				.transition(AnyTransition.asymmetric(
								insertion: .move(edge: .trailing),
								removal: .move(edge: .leading))
							)
				.animation(.default)
			}
		}
			.frame(width: 800, height: 600)
			.onAppear {
				self.currentPage = pages.first!
			}
	}
	
	private func showNextPage() {
		guard let currentIndex = pages.firstIndex(of: currentPage), pages.count > currentIndex + 1 else {
			return
		}
		currentPage = pages[currentIndex + 1]
	}
}
