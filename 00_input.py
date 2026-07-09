
import pandas as pd
import json

df = pd.read_csv('legumain_dlkcat_input.csv')

# 用字典格式：{pdbpath: {"seq": ...}}
records = {}
for i, row in df.iterrows():
    pdb = row['pdbpath']
    records[pdb] = {
        'seq': row['sequence'],
        'pdbpath': pdb
    }

with open('output/legumain_protein.json', 'w') as f:
    json.dump(records, f, indent=2)

print(f"✅ 已创建字典格式 JSON，{len(records)} 个条目")
print("Keys:", list(records.keys())[:3])

