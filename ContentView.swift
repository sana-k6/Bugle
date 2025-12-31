//
//  ContentView.swift
//  
//
//  Created by Sana Kulkarni on 31/12/2025.
//

import SwiftUI

struct BugLevel {
    let code: [String]
    let bugLine: Int
    let hint: String
}

struct ContentView: View {
    // Sample Levels
    let levels = [
        BugLevel(code: ["func add(a, b) {", "  return a + c", "}"], bugLine: 1, hint: "Undefined variable"),
        BugLevel(code: ["for i in 0...5 {", "  print(items[i])", "}"], bugLine: 1, hint: "Out of bounds"),
        BugLevel(code: ["if x = 10 {", "  print(\"Hi\")", "}"], bugLine: 0, hint: "Assignment vs Equality"),
        BugLevel(code: ["let name: String", "print(name)", "name = \"Dev\""], bugLine: 1, hint: "Used before initialized")
    ]
    
    @State private var currentLevelIndex = 0
    @State private var guesses: [Int] = []
    @State private var currentGuess: String = ""
    @State private var gameOver = false
    @State private var message = "Find the line with the bug!"

    var currentLevel: BugLevel { levels[currentLevelIndex] }

    var body: some View {
        VStack(spacing: 20) {
            Text("BUGLE")
                .font(.system(size: 32, weight: .black, design: .monospaced))
                .tracking(5)
            
            // Code Display Area
            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<currentLevel.code.count, id: \.self) { index in
                    HStack {
                        Text("\(index)")
                            .font(.caption.monospaced())
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        Text(currentLevel.code[index])
                            .font(.system(.body, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(colorForLine(index).opacity(0.2))
                    .cornerRadius(4)
                }
            }
            .padding()
            .background(Color.black.opacity(0.05))
            .cornerRadius(8)

            // Guess Input
            HStack {
                TextField("Line #", text: $currentGuess)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                
                Button("Submit Guess") {
                    submitGuess()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(gameOver)
            }

            // Feedback Grid (Wordle Style)
            HStack {
                ForEach(0..<6) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(i < guesses.count ? feedbackColor(guesses[i]) : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                }
            }

            Text(message)
                .font(.callout)
                .foregroundColor(gameOver ? .primary : .secondary)

            if gameOver {
                Button("Next Bug") {
                    resetGame()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
        .frame(minWidth: 500, minHeight: 600)
    }

    // Logic
    func submitGuess() {
        guard let guessInt = Int(currentGuess), guessInt < currentLevel.code.count else { return }
        
        guesses.append(guessInt)
        
        if guessInt == currentLevel.bugLine {
            message = "Correct! You fixed the bug! 🎉"
            gameOver = true
        } else if guesses.count >= 6 {
            message = "Game Over! Bug was on line \(currentLevel.bugLine)."
            gameOver = true
        } else {
            message = guessInt < currentLevel.bugLine ? "Try a higher line number." : "Try a lower line number."
        }
        currentGuess = ""
    }

    func feedbackColor(_ guess: Int) -> Color {
        if guess == currentLevel.bugLine { return .green }
        if abs(guess - currentLevel.bugLine) == 1 { return .yellow }
        return .gray
    }
    
    func colorForLine(_ index: Int) -> Color {
        if guesses.contains(index) {
            return feedbackColor(index)
        }
        return Color.clear
    }

    func resetGame() {
        currentLevelIndex = (currentLevelIndex + 1) % levels.count
        guesses = []
        gameOver = false
        message = "Find the line with the bug!"
    }
}

