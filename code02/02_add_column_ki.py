import pandas as pd
import numpy as np

df = pd.read_csv('output/legu419_output_ki.csv')

# 10个模型列（mean 不是 max）
model_cols = [f'log10ki_mean_model_{i}' for i in range(10)]

# SD_epistemic = 10个模型预测值的标准差（认知不确定性）
df['SD_epistemic'] = df[model_cols].std(axis=1, ddof=0)

# SD_aleatoric 需要 MVE 输出，这里用 NaN 占位
df['SD_aleatoric'] = np.nan

# SD_total（没有 MVE 时，近似 = 认知不确定性）
df['SD_total'] = df['SD_epistemic']

# Prediction - 这里也要改！mean 不是 max
df['Prediction_(μM)'] = 10 ** df['log10ki_mean']  # ← 改这里
df['Prediction_log10'] = df['log10ki_mean']        # ← 改这里

df.to_csv('output/legu419_out_ki.csv', index=False)
print("完成！")
print(df[['log10ki_mean', 'SD_epistemic', 'Prediction_(μM)']].head(2))
