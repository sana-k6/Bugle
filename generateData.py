import json
import time
from datasets import load_dataset
from google import genai

# 1. Setup Gemini API Client
# Ensure your API key is correct
client = genai.Client(api_key="AIzaSyCkpX0D8VZNZRmS9HbCVjqvJDeFr_LBaWA")

print("🔍 Loading Dataset...")
# DebugBench features: question, buggy_code, bug_explanation, etc.
ds = load_dataset("Rtian/DebugBench", split='test') 

processed_data = []

# Select a sample of 30 problems to test
sample_size = 20
print(f"✨ Generating AI Hints for {sample_size} problems...")

for entry in ds.select(range(sample_size)):
    prompt = f"""
    You are a coding tutor. Look at this buggy code and the explanation of the bug and the type of error.
    Provide a one-sentence, clever hint for a 'Wordle' style game. 
    Don't give the answer away, just nudge the player toward the logic error.
    
    Buggy Code: {entry['buggy_code']}
    Actual Bug: {entry['bug_explanation']}
    Syntax Error: {entry['category']}
    """
    
    try:
        # FIX: Explicitly use keyword arguments 'model' and 'contents'
        response = client.models.generate_content(
            model="gemini-2.0-flash", 
            contents=prompt
        )
        
        # Add the generated hint to the entry
        entry['hint'] = response.text.strip()
        processed_data.append(entry)
        print(f"✅ Generated hint for: {entry['slug']}")
        
        # To avoid rate limits on free tier, wait 4 seconds between requests
        time.sleep(4)
        
    except Exception as e:
        print(f"❌ Error on {entry['slug']}: {e}")
        if "429" in str(e):
            print("⏳ Rate limit hit. Sleeping for 30 seconds...")
            time.sleep(30)

# 3. Save to JSON for Xcode
with open("BugdleData.json", "w") as f:
    json.dump(processed_data, f, indent=4)

print("\n🚀 Finished! Your 'BugdleData.json' is ready for Xcode.")