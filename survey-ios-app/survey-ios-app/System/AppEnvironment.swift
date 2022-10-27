//
//  AppEnvironment.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import Foundation
import Combine

enum BaseURLConstants {
    static let baseURL = "https://powerful-peak-54206.herokuapp.com"
}

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let session = configuredURLSession()
        let webRepositories = configuredWebRepositories(session: session)
        let dbRepositories = configuredDBRepositories()
        let interactors = configuredInteractors(
            webRepositories: webRepositories,
            dbRepositories: dbRepositories)
        let diContainer = DIContainer(interactors: interactors)
        return AppEnvironment(container: diContainer)
    }

    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }

    private static func configuredWebRepositories(session: URLSession) -> DIContainer.WebRepositories {
        let surveyRepository = DefSurveyRepository(
            session: session,
            baseURL: BaseURLConstants.baseURL)
        return .init(surveyRepository: surveyRepository)
    }

    private static func configuredDBRepositories() -> DIContainer.DBRepositories {
        let stack = CoreDataStack(modelName: "SurveyModel")
        let surveyDBRepository = DefSurveyDBRepository(persistentStore: stack)
        return .init(surveyDBRepository: surveyDBRepository)
    }

    private static func configuredInteractors(
        webRepositories: DIContainer.WebRepositories,
        dbRepositories: DIContainer.DBRepositories
    ) -> DIContainer.Interactors {
        let homeViewModel = HomeViewModel(
            surveyRepository: webRepositories.surveyRepository,
            surveyDBRepository: dbRepositories.surveyDBRepository)
        let surveyViewModel = SurveyViewModel(
            surveyRepository: webRepositories.surveyRepository,
            surveyDBRepository: dbRepositories.surveyDBRepository)
        return .init(
            homeViewModel: homeViewModel,
            surveyViewModel: surveyViewModel
        )
    }
}

extension DIContainer {
    struct WebRepositories {
        let surveyRepository: SurveyRepository
    }

    struct DBRepositories {
        let surveyDBRepository: SurveyDBRepository
    }
}
