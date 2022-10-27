//
//  HomeView.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    var body: some View {
        ZStack {
            titleView
            submitButton
            surveyNavigation()
        }
        .background(.gray)
        .banner(type: .error, show: $viewModel.displayFailure) {
            viewModel.startSurvey()
        }
    }
}

private extension HomeView {
    var titleView: some View {
        VStack {
            Divider()
            Text(Constants.Titles.welcomeString)
            Spacer()
        }
    }

    var submitButton: some View {
        Button(action: {
            viewModel.startSurvey()
        }, label: {
            Text(Constants.Titles.startString)
                .foregroundColor(.blue)
                .frame(width: Constants.Sizes.submitButtonWidth)
                .padding()
                .foregroundColor(Color.black)
        })
        .background(.white)
        .cornerRadius(5)
    }

    func surveyNavigation() -> some View {
        NavigationLink(
            destination: SurveyView(viewModel:
                                        SurveyViewModel(surveyRepository: viewModel.surveyRepository,
                                                               surveyDBRepository: viewModel.surveyDBRepository)),
            isActive: $viewModel.openDetails) { }
    }
}

// swiftlint:disable nesting
private extension HomeView {
    enum Constants {
        enum Titles {
            static let welcomeString = "Hello, World!"
            static let startString = "Start survey"
        }
        enum Sizes {
            static let submitButtonWidth = 250.0
        }
    }
}
// swiftlint:enable nesting
