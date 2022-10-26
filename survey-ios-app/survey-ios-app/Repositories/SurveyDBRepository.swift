//
//  SurveyDBRepository.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import Foundation

protocol SurveyDBRepository {
    func hasLoadedData() -> Bool
    func store(questions: [Question])
    func fetchQuestions() -> [QuestionMO]
}

struct DefSurveyDBRepository: SurveyDBRepository {
    let persistentStore: CoreDataStack

    func hasLoadedData() -> Bool {
        persistentStore.getRecordsCount(name: RecordType.question) > 0
    }

    func store(questions: [Question]) {
        let bgContext = persistentStore.bgMOC
        questions.forEach { question in
            let newRecord = QuestionMO(context: bgContext)
            newRecord.id = Int32(question.id)
            newRecord.question = question.question
        }
        persistentStore.save(context: bgContext, wait: true)
        persistentStore.saveViewContext()
    }

    func fetchQuestions() -> [QuestionMO] {
        persistentStore.fetch(
            entityName: RecordType.question,
            predicate: nil,
            sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)],
            context: nil
        ) as? [QuestionMO] ?? []
    }
}
