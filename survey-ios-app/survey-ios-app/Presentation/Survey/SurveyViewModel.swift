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
    @Published var answer: String = ""

    @Published var prevDisabled: Bool = true
    @Published var nextDisabled: Bool = true

    @Published var displayFailure: Bool = false
    @Published var displaySuccess: Bool = false

    init(
        surveyRepository: SurveyRepository,
        surveyDBRepository: SurveyDBRepository
    ) {
        self.surveyRepository = surveyRepository
        self.surveyDBRepository = surveyDBRepository
    }

    func fetchData() {
        questions = surveyDBRepository.fetchQuestions()
        updatedDataSource()
    }

    func prev() {
        selectedQuestionIndex -= 1
        updatedDataSource()
    }

    func next() {
        selectedQuestionIndex += 1
        updatedDataSource()
    }

    func submitAnswer() {
        guard let question = selectedQuestion, !answer.isEmpty else { return }
        AppLogger.log(message: "submit answer", category: .api, type: .info)
        surveyRepository.submitAnswer(id: Int(question.id), answer: answer)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let error) = result {
                    AppLogger.log(message: "submit answer error: \(error)", category: .api, type: .info)
                    self?.displayFailure = true
                }
            }, receiveValue: { [weak self] _ in
                question.answer = self?.answer
                question.submited = true
                try? question.managedObjectContext?.save()
                self?.displaySuccess = true
                self?.refreshSubmittedCounter()
            })
            .store(in: &cancellables)
    }
}

private extension SurveyViewModel {
    func updatedDataSource() {
        updateAnswer()
        refreshSelection()
        refreshSubmittedCounter()
    }

    func updateAnswer() {
        if !answer.isEmpty {
            selectedQuestion?.answer = answer
            try? selectedQuestion?.managedObjectContext?.save()
        }
    }

    func refreshSelection() {
        selectedQuestion = questions[selectedQuestionIndex]
        prevDisabled = selectedQuestionIndex == 0
        nextDisabled = selectedQuestionIndex == questions.count - 1
        answer = selectedQuestion?.answer ?? ""
    }

    func refreshSubmittedCounter() {
        submittedQuestions = questions.filter { $0.submited == true }.count
    }
}
