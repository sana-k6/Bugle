import SwiftUI

// 1. Data Model matching your dataset features
struct BugProblem: Identifiable, Codable {
    var id: String { slug }
    let slug: String
    let category: String
    let question: String
    let buggy_code: String
    let solution: String
    let hint: String
    let bug_explanation: String
    let level: String
    let language: String
    let examples: [String]
    let subtype: String
}

struct ContentView: View {
    // State variables to track game progress
    @State private var currentProblem: BugProblem?
    @State private var attempts = 5
    @State private var showSolution = false
    @State private var showHint = false
    @State private var userGuess = ""
    let aiService = AIHintService()
    var body: some View {
        NavigationSplitView {
            // Sidebar for Stats
            VStack(alignment: .leading, spacing: 20) {
                Text("🪲 Bugdle")
                    .font(.largeTitle).bold()
                
                Divider()
                
                StatRow(label: "Lives", value: String(repeating: "❤️", count: attempts))
                StatRow(label: "Difficulty", value: currentProblem?.level.capitalized ?? "Loading...")
                StatRow(label: "Language", value: currentProblem?.language.uppercased() ?? "...")
                
                Spacer()
                
                Button("New Problem") {
                    loadNewProblem()
                }
                .keyboardShortcut("r", modifiers: .command)
                .controlSize(.large)
            }
            .padding()
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            
        } detail: {
            // Main Game Area
            HSplitView {
                // Left Side: Problem Description
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Problem").font(.headline)
                        Text(currentProblem?.question ?? "Click 'New Problem' to start.")
                            .font(.system(.body, design: .serif))
                        
                        Text("Examples").font(.headline).padding(.top)
                        ForEach(currentProblem?.examples ?? [], id: \.self) { example in
                            Text(example)
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    .padding()
                }
                .frame(minWidth: 300)

                // Right Side: Buggy Code & Debugging
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        ScrollView {
                            Text(currentProblem?.buggy_code ?? "// Select a problem")
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        
                        if showHint {
                            Text("Hint: \(currentProblem?.subtype ?? "")")
                                .padding(8)
                                .background(.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                                .padding()
                        }
                    }

                    // Bottom Input Area
                    VStack(spacing: 12) {
                        TextField("What line is the bug?", text: $userGuess)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { checkGuess() }
                        
                        HStack {
                            Button("Use Hint (-1 ❤️)") {
                                useHint()
                            }
                            .disabled(attempts <= 1 || showHint)
                            
                            Spacer()
                            
                            Button("Submit Fix") {
                                checkGuess()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    .background(.windowBackground)
                }
            }
        }
        .sheet(isPresented: $showSolution) {
            SolutionView(problem: currentProblem)
        }
    }

    // --- Game Logic ---
    func loadNewProblem() {
        // Here you would normally fetch from your JSON/Dataset
        // Placeholder data for demonstration:
        currentProblem = BugProblem(
            slug: "single-number",
            category: "logic error",
            question: "Given a non-empty array of integers nums, every element appears twice except for one. Find that single one.",
            buggy_code: "for(int i=0;i<nums.size();i++){\n  mp[nums[i]] = 1; \n}",
            solution: "mp[nums[i]]++;",
            hint: 
            bug_explanation: "Instead of incrementing the map's value, we are setting it to 1 each time.",
            level: "Easy",
            language: "cpp",
            examples: ["Input: [2,2,1] Output: 1"],
            subtype: "operation error"
        )
        attempts = 5
        showSolution = false
        showHint = false
        userGuess = ""
    }

    func useHint() {
        attempts -= 1
        showHint = true
    }

    func checkGuess() {
        // Logic to reveal the answer
        showSolution = true
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundColor(.secondary)
            Text(value).font(.body).bold()
        }
    }
}

struct SolutionView: View {
    let problem: BugProblem?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Bug Analysis").font(.title)
            
            if let p = problem {
                VStack(alignment: .leading, spacing: 10) {
                    Text("The Bug:").bold()
                    Text(p.bug_explanation)
                    
                    Text("Correct Logic:").bold()
                    Text(p.solution).font(.system(.body, design: .monospaced))
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button("Got it") { dismiss() }
        }
        .padding()
        .frame(width: 400)
    }
}
VStack {
            if isFetchingHint {
                ProgressView("AI is analyzing the bug...")
                    .controlSize(.small)
            } else if !aiHint.isEmpty {
                Text(aiHint)
                    .italic()
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }

            Button("Ask AI for a Hint (-1 Life)") {
                Task {
                    await getAIHint()
                }
            }
            .disabled(attempts <= 1 || isFetchingHint)
        }
    }

    func getAIHint() async {
        guard let problem = currentProblem else { return }
        
        isFetchingHint = true
        attempts -= 1
        
        let fetchedHint = await aiService.fetchHint(
            buggyCode: problem.buggy_code,
            explanation: problem.bug_explanation
        )
        
        await MainActor.run {
            self.aiHint = fetchedHint
            self.isFetchingHint = false
        }
    }

