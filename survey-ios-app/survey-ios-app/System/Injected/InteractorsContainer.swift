//
//  InteractorsContainer.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import Foundation

extension DIContainer {
    class Interactors: ObservableObject {
        let homeViewModel: HomeViewModel
        let surveyViewModel: SurveyViewModel

        init(
            homeViewModel: HomeViewModel,
            surveyViewModel: SurveyViewModel
        ) {
            self.homeViewModel = homeViewModel
            self.surveyViewModel = surveyViewModel
        }
    }
}
