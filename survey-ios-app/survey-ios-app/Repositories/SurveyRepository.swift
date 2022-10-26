//
//  SurveyRepository.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import Foundation
import Combine

protocol SurveyRepository: WebRepository {
    func fetchQuestions() -> AnyPublisher<[Question], Error>
    func submitAnswer(id: Int, answer: String) -> AnyPublisher<Bool, Error>
}

struct DefSurveyRepository: SurveyRepository {
    let session: URLSession
    let baseURL: String

    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }

    func fetchQuestions() -> AnyPublisher<[Question], Error> {
        call(endpoint: API.fetch)
    }

    func submitAnswer(id: Int, answer: String) -> AnyPublisher<Bool, Error> {
        Result.Publisher(true).eraseToAnyPublisher()
    }
}

// MARK: - Endpoints

extension DefSurveyRepository {
    enum API {
        case fetch
        case submit(Int, String)
    }
}

extension DefSurveyRepository.API: APICall {
    var path: String {
        switch self {
        case .fetch:
            return "/questions"
        case .submit:
            return "/question/submit"
        }
    }

    var method: HTTPMethodType {
        switch self {
        case .fetch:
            return .get
        case .submit:
            return .post
        }
    }

    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Connection": "keep-alive",
            "Accept": "*/*"
        ]
    }

    func body() throws -> Data? {
        switch self {
        case let .submit(id, answer):
            return try? JSONSerialization.data(withJSONObject: ["id": id, "answer": answer])
        default:
            return nil
        }
    }
}
