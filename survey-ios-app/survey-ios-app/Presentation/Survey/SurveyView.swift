//
//  SurveyView.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import SwiftUI

struct SurveyView: View {
    @ObservedObject var viewModel: SurveyViewModel
    var body: some View {
        VStack {
            Spacer()
            Text("Questions submitted: \(viewModel.submittedQuestions)")
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.white)
            Spacer()

            if let question = viewModel.selectedQuestion {
                VStack {
                    Text(question.question ?? "")

                    if question.submited {
                        Text(question.answer ?? "")
                            .padding()

                        Spacer()
                    } else {
                        TextEditor(text: $viewModel.answer)

                        Button(action: {
                            viewModel.submitAnswer()
                        }, label: {
                            Text("Submit")
                                .foregroundColor(.blue)
                                .frame(width: 100)
                                .padding()
                                .foregroundColor(Color.black)
                        })
                        .background(.white)
                        .cornerRadius(5)
                    }
                }
                .padding()
            }
        }
        .background(.gray)
        .onAppear {
            viewModel.fetchData()
        }
        .navigationTitle("Question: \(viewModel.selectedQuestionIndex + 1)/\(viewModel.questions.count)")
        .toolbar {
            Button("< Prev") {
                viewModel.prev()
            }
            .disabled(viewModel.prevDisabled)
            Button("Next >") {
                viewModel.next()
            }
            .disabled(viewModel.nextDisabled)
        }
        .banner(type: .success, show: $viewModel.displaySuccess)
        .banner(type: .error, show: $viewModel.displayFailure) {
            viewModel.submitAnswer()
        }

    }
}
