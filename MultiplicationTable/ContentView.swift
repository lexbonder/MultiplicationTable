//
//  ContentView.swift
//  MultiplicationTable
//
//  Created by Alex Bonder on 7/23/23.
//

import SwiftUI

struct Background: View {
    var body: some View {
        RadialGradient(colors: [.red, .blue, .green], center: .top, startRadius: 80, endRadius: 600)
            .ignoresSafeArea()
    }
}

struct CustomStepper: View {
    @Binding var value: Int
    let min: Int
    let max: Int
    
    var body: some View {
        HStack{
            Button("⬇️") { value -= 1 }
                .disabled(value == min)
                .opacity(value == min ? 0.5 : 1)
            Text("\(value)")
            Button("⬆️") { value += 1 }
                .disabled(value == max)
                .opacity(value == max ? 0.5 : 1)
        }
        .font(.system(size: 80))
    }
}

struct PreGameQuestions: View {
    @Binding var timesTablesMax: Int
    @Binding var numQuestions: Int
    @Binding var showingPreGameQuestions: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("I want to practice times tables up to...")
                .font(.title)
                .multilineTextAlignment(.center)
            
            CustomStepper(value: $timesTablesMax, min: 2, max: 12)
            
            Text("I want to answer this many questions...")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Picker("Number of questions", selection: $numQuestions) {
                ForEach([5, 10, 20], id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()
            
            Button { showingPreGameQuestions.toggle() } label: {
                Text("Next ➡️")
                    .font(.title)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct ContentView: View {
    @State private var showingPreGameQuestions = true // Make me true to play the game!
    @State private var timesTablesMax = 5
    @State private var numQuestions = 10
    
    @State private var currentQuestion = 1
    @State private var userScore = 0
    @State private var userGuess = ""
    
    @FocusState private var showingKeyboard: Bool
    @State private var leftNum = 0
    @State private var rightNum = 0
    
    @State private var showingGuessAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var showingNewGameAlert = false
    
    init() {
        UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .title1)], for: .normal)
    }

    
    var body: some View {
        
        ZStack {
            if showingPreGameQuestions {
                PreGameQuestions(
                    timesTablesMax: $timesTablesMax,
                    numQuestions: $numQuestions,
                    showingPreGameQuestions: $showingPreGameQuestions
                )
            } else {
                VStack {
                    HStack {
                        Text("Question \(currentQuestion)/\(numQuestions)")
                        Spacer()
                        Text("Score: \(userScore)")
                        Spacer()
                        Button("New Game") { showingNewGameAlert = true }
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(.ultraThickMaterial)
                    
                    Spacer()
                    
                    HStack {
                        Text("\(leftNum) x \(rightNum) = ")
                        TextField("?", text: $userGuess)
                            .onChange(of: userGuess) { newValue in
                                userGuess = String(newValue.prefix(3))
                            }
                            .frame(maxWidth: 120)
                            .keyboardType(.numberPad)
                            .focused($showingKeyboard)
                    }
                    .font(.system(size: 60))

                    Spacer()
                }
                .onAppear() {
                    leftNum = Int.random(in: 0...timesTablesMax)
                    rightNum = Int.random(in: 0...timesTablesMax)
                    showingKeyboard = true
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button {
                            checkGuess()
                        } label: {
                            Text("Let's Go!")
                                .padding(5)
                                .background(.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                }
                .alert(alertTitle, isPresented: $showingGuessAlert) {
                    Button("Next", action: nextQuestion)
                } message: {
                    Text(alertMessage)
                }
                .alert("New Game", isPresented: $showingNewGameAlert) {
                    Button("New Game", role: .destructive) {
                        userScore = 0
                        userGuess = ""
                        timesTablesMax = 5
                        numQuestions = 10
                        showingPreGameQuestions = true
                    }
                } message: {
                    Text("Are you sure you want to start a new game?")
                }
            }
        }
    }
    
    func checkGuess() {
        guard let userInt = Int(userGuess) else { return }
        
        if userInt == leftNum * rightNum {
            userScore += 1
            
            alertTitle = "Correct!"
            alertMessage = "Well done! Your score is now \(userScore)"
        } else {
            alertTitle = "Sorry!"
            alertMessage = "\(leftNum) x \(rightNum) is \(leftNum * rightNum)... Keep trying!"
        }
        
        showingGuessAlert = true
    }
    
    func nextQuestion() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
