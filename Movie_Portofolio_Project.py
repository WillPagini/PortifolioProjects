import os
import pandas as pd
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure
import seaborn as sns

matplotlib.rcParams['figure.figsize'] = (12,8)

base_dir = os.path.dirname(os.path.abspath(__file__))
data_dir = os.path.join(base_dir, 'dataset')

files_names = [i for i in os.listdir(data_dir) if i.endswith('.csv')]

df_dic = {}
for i in files_names:
    df_dic["df_%s" %i] = pd.read_csv(os.path.join( data_dir, i))

df = df_dic["df_" + files_names[0]]

#Data Cleaning

#Check and drop empty data
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, pct_missing))

df.dropna(inplace = True)
print(df.isnull().sum())

#Datatypes for columns
print(df.dtypes)

#Change to a proper dataype
#erro de comversao por causa dos valores NULL que nao tratei (ou verificar se eh pq o type eh object)
df['budget'] = df['budget'].astype('int64')
df['gross'] = df['gross'].astype('int64')

aux_df = df['released'].str.split(',', expand=True)
df['correctYear'] = aux_df[1].str[1:5]
print(df.head())

#Drop duplicates
df.drop_duplicates()

##Data Correlations
#Budget high correlation
#Company high correlation

#Scatter plot with budget vs gross
plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget vs Gross Earning')
plt.xlabel('Gross Earning')
plt.ylabel('Budget for Film')
plt.show()

# Plot budget vs gross using seaborn
sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color": "red"}, line_kws={"color":"blue"})

#Looking for correlation (pearson, kendall, spearman)
df.corr(method='pearson')

#Plot correlation matrix into heatmap
correlation_matrix = df.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.xlabel('Movie Features')
plt.ylabel('Budget for Film')
plt.show()