//
//  HomeView.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isActive: Bool = false
    var body: some View {
        ZStack {
            titleView
            submitButton
        }
        .background(.gray)
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
        NavigationLink(
            destination: SurveyView(viewModel:
                                        SurveyViewModel(surveyRepository: viewModel.surveyRepository,
                                                               surveyDBRepository: viewModel.surveyDBRepository)),
            isActive: $isActive) {
                Button(action: {
                    isActive.toggle()
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
    }
}

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
