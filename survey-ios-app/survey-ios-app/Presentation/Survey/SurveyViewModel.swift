//
//  SurveyViewModel.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import Foundation
import Combine

final class SurveyViewModel: ObservableObject {
    private var surveyRepository: SurveyRepository
    private let surveyDBRepository: SurveyDBRepository
    private var cancellables = Set<AnyCancellable>()
    
    @Published var questions: [QuestionMO] = []
    
    @Published var selectedQuestionIndex: Int = 0
    @Published var selectedQuestion: QuestionMO?
    
    @Published var submittedQuestions: Int = 0
    
    @Published var prevDisabled: Bool = true
    @Published var nextDisabled: Bool = true
    
    @Published var displayFailure: Bool = true
    @Published var displaySuccess: Bool = true
    
    @Published var answer: String = ""

    init(
        surveyRepository: SurveyRepository,
        surveyDBRepository: SurveyDBRepository
    ) {
        self.surveyRepository = surveyRepository
        self.surveyDBRepository = surveyDBRepository
    }
    
    func fetchData() {
        questions = surveyDBRepository.fetchQuestions()
        submittedQuestions = questions.filter { $0.submited == true }.count
        selectQuestion()
    }
    
    func prev() {
        selectedQuestionIndex -= 1
        selectQuestion()
    }
    
    func next() {
        selectedQuestionIndex += 1
        selectQuestion()
    }
    
    func submitAnswer() {
        guard let question = selectedQuestion else { return }
        AppLogger.log(message: "submit answer", category: .api, type: .info)
        surveyRepository.submitAnswer(id: Int(question.id), answer: answer)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { result in
                if case .failure(let error) = result {
                    AppLogger.log(message: "submit answer error: \(error)", category: .api, type: .info)
                }
            }, receiveValue: { [weak self] success in
                question.answer = self?.answer
                question.submited = true
               // AppLogger.log(message: "submit answer \(questions)", category: .api, type: .info)
               // self?.surveyDBRepository.store(questions: questions)
            })
            .store(in: &cancellables)
    }
    
    private func selectQuestion() {
        if !answer.isEmpty {
            selectedQuestion?.answer = answer
        }
        selectedQuestion = questions[selectedQuestionIndex]
        prevDisabled = selectedQuestionIndex == 0
        nextDisabled = selectedQuestionIndex == questions.count - 1
        answer = selectedQuestion?.answer ?? ""
    }
}
