//
//  AIHintService.swift
//  Bugle
//
//  Created by Sana Kulkarni on 31/12/2025.
//


import Foundation

class AIHintService {
    // Replace with your actual API endpoint/key logic
    func fetchHint(buggyCode: String, explanation: String) async -> String {
        let prompt = """
        You are a programming coach for a game called Bugdle. 
        The bug is: \(explanation)
        The code is: \(buggyCode)
        Provide a short, one-sentence hint that doesn't give away the answer but points them in the right direction.
        """
        
        // This is a placeholder for your API request logic (Gemini/OpenAI)
        // For now, it simulates a network delay
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        return "Think about how you are updating the map values—are you incrementing or overwriting?"
    }
}