//
//  Data.py
//  Bugle
//
//  Created by Sana Kulkarni on 31/12/2025.
//
import json
from datasets import load_dataset
import google.generativeai as genai

# 1. Setup Gemini API
genai.configure(api_key="YOUR_GEMINI_API_KEY")
model = genai.GenerativeModel('gemini-1.5-flash')

# 2. Load Dataset
ds = load_dataset("Rtian/DebugBench", split='train')

processed_data = []

# Loop through the first 50 for a quick test (remove [:50] for the full set)
for entry in ds.select(range(50)):
    prompt = f"""
    You are a coding tutor. Look at this buggy code and the explanation of the bug.
    Provide a one-sentence, clever hint for a 'Wordle' style game. 
    Don't give the answer away, just nudge the player.
    
    Code: {entry['buggy_code']}
    Bug Explanation: {entry['bug_explanation']}
    """
    
    try:
        response = model.generate_content(prompt)
        entry['ai_hint'] = response.text.strip()
        processed_data.append(entry)
        print(f"Generated hint for: {entry['slug']}")
    except Exception as e:
        print(f"Error on {entry['slug']}: {e}")

# 3. Save to JSON for Xcode
with open("BugdleData.json", "w") as f:
    json.dump(processed_data, f, indent=4)
