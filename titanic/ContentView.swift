//
//  ContentView.swift
//  titanic
//
//  Created by Timur Ramazanov on 13.09.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var age = 1
    @State private var pclass = 1
    @State private var sibsp = 0
    @State private var parch = 0
    @State private var sex = "male"
    @State private var embarked = ""
    @State private var prediction = "S"
    @State private var isAlert = false
    let predictionOptions = ["😔 You're dead", "YAY! You survived"]
    
    func makePrediction() -> Void {
        do {
            let config = MLModelConfiguration()
            let model = try TitanicClassifier(configuration: config)
            let mPred = try model.prediction(Pclass: Int64(pclass),
                                             Sex: sex,
                                             Age: Double(age),
                                             SibSp: Int64(sibsp),
                                             Parch: Int64(parch),
                                             Embarked: embarked)
            let predLabel = predictionOptions[Int(mPred.Survived)]
            let percent = (mPred.SurvivedProbability[mPred.Survived] ?? 0) * 100
            
            prediction = predLabel + " with \(Int(percent))% chance"
        } catch {
            prediction = "Prediction failed"
        }
        isAlert = true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("pclass", selection: $pclass) {
                        Text("1st")
                            .tag(1)
                        Text("2nd")
                            .tag(2)
                        Text("3rd")
                            .tag(3)
                    }
                } footer: {
                    Text("A proxy for socio-economic status (SES)\n1st = Upper\n2nd = Middle\n3rd = Lower")
                }
                Section {
                    Picker("sex", selection: $sex) {
                        Text("Male")
                            .tag("male")
                        Text("Female")
                            .tag("female")
                    }
                }
                Section {
                    Picker("age", selection: $age) {
                        ForEach(1..<100) { Text("\($0) years").tag($0) }
                    }
                }
                Section {
                    Stepper("sibsp \(sibsp)", value: $sibsp, in: 0...100)
                } footer: {
                    Text("# of siblings / spouses aboard the Titanic")
                }
                Section {
                    Stepper("parch \(parch)", value: $parch, in: 0...100)
                } footer: {
                    Text("# of parents / children aboard the Titanic")
                }
                Section {
                    Picker("embarked", selection: $embarked) {
                        Text("Cherbourg")
                            .tag("C")
                        Text("Queenstown")
                            .tag("Q")
                        Text("Southampton")
                            .tag("S")
                    }
                } footer: {
                    Text("Port of Embarkation")
                }
            }
            .navigationTitle("Survival on Titanic")
            .toolbar {
                Button("Predict") { makePrediction() }
            }
            .alert("Your prediction", isPresented: $isAlert) {
                Button("OK") {}
            } message: {
                Text(prediction)
            }
        }
    }
}

#Preview {
    ContentView()
}
