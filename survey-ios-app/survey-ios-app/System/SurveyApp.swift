//
//  SurveyApp.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import SwiftUI

@main
struct SurveyApp: App {
    let environment: AppEnvironment

    init() {
        environment = AppEnvironment.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView(viewModel: environment.container.interactors.homeViewModel)
            }
        }
    }
}
