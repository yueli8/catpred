import pandas as pd
import numpy as np

df = pd.read_csv('output/legu419_output_kcat.csv')

# 10个模型列
model_cols = [f'log10kcat_max_model_{i}' for i in range(10)]

# SD_epistemic = 10个模型预测值的标准差（认知不确定性）
df['SD_epistemic'] = df[model_cols].std(axis=1, ddof=0)

# SD_aleatoric 需要 MVE 输出，这里用 NaN 占位
df['SD_aleatoric'] = np.nan

# SD_total（没有 MVE 时，近似 = 认知不确定性）
df['SD_total'] = df['SD_epistemic']

# Prediction
df['Prediction_(s^(-1))'] = 10 ** df['log10kcat_max']
df['Prediction_log10'] = df['log10kcat_max']

df.to_csv('output/legu419_out_kcat.csv', index=False)
print("完成！列名：")
print(df.columns.tolist())
print("\n前2行：")
print(df[['log10kcat_max', 'SD_epistemic', 'Prediction_(s^(-1))']].head(2))
