//
//  HomeViewModel.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    private(set) var surveyRepository: SurveyRepository
    let surveyDBRepository: SurveyDBRepository
    private var cancellables = Set<AnyCancellable>()

    init(
        surveyRepository: SurveyRepository,
        surveyDBRepository: SurveyDBRepository
    ) {
        self.surveyRepository = surveyRepository
        self.surveyDBRepository = surveyDBRepository
    }

    func startSurvey() {
        if !surveyDBRepository.hasLoadedData() {
            fetchQuestions()
        }
    }
}

private extension HomeViewModel {
    func fetchQuestions() {
        AppLogger.log(message: "fetch questions", category: .api, type: .info)
        surveyRepository.fetchQuestions()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { result in
                if case .failure(let error) = result {
                    AppLogger.log(message: "fetch questions error: \(error)", category: .api, type: .info)
                }
            }, receiveValue: { [weak self] questions in
                AppLogger.log(message: "fetch questions \(questions)", category: .api, type: .info)
                self?.surveyDBRepository.store(questions: questions)
            })
            .store(in: &cancellables)
    }
}
