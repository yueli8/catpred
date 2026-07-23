library(dplyr)
library(factoextra)
library(cluster)
library(ggplot2)
setwd("/home/li/CatPred-main/")

# 读取数据
data <- read.table("tmp.txt", header = TRUE, sep = "\t")

# 提取Kcat值并标准化
kcat_values <- data$Kcat
names(kcat_values) <- data$Substrate
kcat_scaled <- scale(kcat_values)

# 计算距离矩阵
dist_matrix <- dist(kcat_scaled, method = "euclidean")

# 执行层次聚类（使用Ward方法）
hc <- hclust(dist_matrix, method = "ward.D2")

# ============================================
# 导出为PDF文件
# ============================================

pdf("层次聚类树状图.pdf", width = 16, height = 10)

# 绘制树状图
plot(hc, 
     main = "层次聚类树状图 (Ward linkage)", 
     xlab = "底物", 
     ylab = "距离",
     cex = 0.28,  # 从0.3改为0.28，稍微小一点点
     hang = -1,
     sub = paste("共", nrow(data), "个样本"))

# 在树状图上添加聚类分组（分为3组）
rect.hclust(hc, k = 3, border = 2:4)

# 添加图例
legend("topright", 
       legend = c("Cluster 1", "Cluster 2", "Cluster 3"), 
       fill = 2:4, 
       title = "聚类分组",
       cex = 0.8)

dev.off()

cat("PDF文件已保存为: 层次聚类树状图.pdf\n")
cat("文件保存在:", getwd(), "\n")

# 加载必要包
library(cluster)

# 读取数据
data <- read.table("tmp.txt", header = TRUE, sep = "\t")

# 提取Kcat值并标准化
kcat_values <- data$Kcat
names(kcat_values) <- data$Substrate
kcat_scaled <- scale(kcat_values)

# 计算距离矩阵
dist_matrix <- dist(kcat_scaled, method = "euclidean")

# 执行层次聚类（使用Ward方法）
hc <- hclust(dist_matrix, method = "ward.D2")

# ============================================
# 导出为PDF文件
# ============================================

pdf("层次聚类树状图.pdf", width = 16, height = 10)

# 绘制树状图
plot(hc, 
     main = "层次聚类树状图 (Ward linkage)", 
     xlab = "底物", 
     ylab = "距离",
     cex = 0.28,
     hang = -1,
     sub = paste("共", nrow(data), "个样本"))

# 在树状图上添加聚类分组（分为3组）
rect.hclust(hc, k = 3, border = 2:4)

# 添加图例
legend("topright", 
       legend = c("Cluster 1", "Cluster 2", "Cluster 3"), 
       fill = 2:4, 
       title = "聚类分组",
       cex = 0.8)

dev.off()

cat("PDF文件已保存为: 层次聚类树状图.pdf\n")
cat("文件保存在:", getwd(), "\n\n")

# ============================================
# 获取聚类分组并导出完整列表
# ============================================

# 获取聚类标签（分为3组）
cluster_labels <- cutree(hc, k = 3)

# 将聚类结果添加到数据框
data$Cluster <- cluster_labels

# 计算每个聚类的平均Kcat值，用于命名
cluster_means <- aggregate(Kcat ~ Cluster, data = data, FUN = mean)
cluster_means <- cluster_means[order(cluster_means$Kcat), ]  # 按Kcat值排序
cluster_means$Cluster_Type <- c("低活性", "中活性", "高活性")  # 分配标签

# 将聚类类型映射到数据
data$Cluster_Type <- factor(data$Cluster, 
                            levels = cluster_means$Cluster,
                            labels = cluster_means$Cluster_Type)

# 按聚类类型排序
data <- data[order(data$Cluster_Type, -data$Kcat), ]

# ============================================
# 导出每个聚类的完整列表
# ============================================

# 获取每个聚类类型
cluster_types <- unique(data$Cluster_Type)

for (cluster_type in cluster_types) {
  # 提取当前聚类的数据
  cluster_data <- data[data$Cluster_Type == cluster_type, ]
  
  # 根据聚类类型确定文件名
  if (cluster_type == "低活性") {
    filename <- "Cluster1_低活性底物完整列表.txt"
  } else if (cluster_type == "中活性") {
    filename <- "Cluster2_中活性底物完整列表.txt"
  } else if (cluster_type == "高活性") {
    filename <- "Cluster3_高活性底物完整列表.txt"
  }
  
  # 准备输出数据（只保留Substrate和Kcat两列）
  output_data <- cluster_data[, c("Substrate", "Kcat")]
  
  # 添加统计信息作为注释
  stats_info <- sprintf(
    "# %s底物列表\n# 样本数: %d\n# 平均Kcat: %.4f\n# 最小Kcat: %.4f\n# 最大Kcat: %.4f\n# 标准差: %.4f\n# ========================================\n",
    cluster_type,
    nrow(cluster_data),
    mean(cluster_data$Kcat),
    min(cluster_data$Kcat),
    max(cluster_data$Kcat),
    sd(cluster_data$Kcat)
  )
  
  # 写入文件
  cat(stats_info, file = filename)
  write.table(output_data, file = filename, append = TRUE, 
              quote = FALSE, sep = "\t", row.names = FALSE)
  
  cat("已生成:", filename, "\n")
}

# ============================================
# 打印聚类统计信息
# ============================================

cat("\n========== 聚类统计信息 ==========\n")
for (cluster_type in cluster_types) {
  cluster_data <- data[data$Cluster_Type == cluster_type, ]
  cat(sprintf("\n%s聚类:\n", cluster_type))
  cat(sprintf("  样本数: %d\n", nrow(cluster_data)))
  cat(sprintf("  平均Kcat: %.4f\n", mean(cluster_data$Kcat)))
  cat(sprintf("  中位数Kcat: %.4f\n", median(cluster_data$Kcat)))
  cat(sprintf("  最小Kcat: %.4f\n", min(cluster_data$Kcat)))
  cat(sprintf("  最大Kcat: %.4f\n", max(cluster_data$Kcat)))
  cat(sprintf("  标准差: %.4f\n", sd(cluster_data$Kcat)))
  cat(sprintf("  Kcat范围: %.4f - %.4f\n", min(cluster_data$Kcat), max(cluster_data$Kcat)))
}

# ============================================
# 可选：导出所有聚类的汇总表
# ============================================

# 创建汇总统计表
summary_stats <- aggregate(Kcat ~ Cluster_Type, data = data, 
                           FUN = function(x) c(Count = length(x),
                                               Mean = mean(x),
                                               Median = median(x),
                                               Min = min(x),
                                               Max = max(x),
                                               SD = sd(x)))
summary_df <- data.frame(
  Cluster_Type = summary_stats$Cluster_Type,
  Count = summary_stats$Kcat[, "Count"],
  Mean = summary_stats$Kcat[, "Mean"],
  Median = summary_stats$Kcat[, "Median"],
  Min = summary_stats$Kcat[, "Min"],
  Max = summary_stats$Kcat[, "Max"],
  SD = summary_stats$Kcat[, "SD"]
)

write.table(summary_df, "聚类统计汇总.txt", 
            quote = FALSE, sep = "\t", row.names = FALSE)
cat("\n已生成: 聚类统计汇总.txt\n")

# ============================================
# 可选：导出完整带聚类标签的数据
# ============================================

write.table(data[, c("Substrate", "Kcat", "Cluster_Type")], 
            "全部底物_带聚类标签.txt", 
            quote = FALSE, sep = "\t", row.names = FALSE)
cat("已生成: 全部底物_带聚类标签.txt\n")

cat("\n所有文件已保存到:", getwd(), "\n")
