import json
from datasets import load_dataset

# 1. Load the dataset (Test or Train split)
print("📥 Downloading dataset...")
ds = load_dataset("Rtian/DebugBench", split='test')

# 2. Convert to a list of dictionaries
# We'll take the first 100 problems
processed_data = list(ds)

# 3. Save directly to JSON
with open("BugdleData.json", "w") as f:
    json.dump(processed_data, f, indent=4)

print(f"✅ Success! 'BugdleData.json' created with {len(processed_data)} problems.")
