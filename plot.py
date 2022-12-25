import matplotlib.pyplot as plt
import pandas as pd

# Load data from US Bureau of Labor Statistics
df = pd.read_csv("https://download.bls.gov/pub/time.series/cu/cu.data.1.AllItems", sep='\t')

# Convert year column to datetime
df['year'] = pd.to_datetime(df['year'], format='%Y')

# Set year column as index
df.set_index('year', inplace=True)

# Resample data to monthly frequency and forward-fill missing values
df_monthly = df.resample('M').mean().ffill()
print(df_monthly)
# Calculate absolute inflation percentage
df_monthly['abs_inflation'] = df_monthly['value'].abs()

# Extract month and absolute inflation percentage data
months = df_monthly.index.strftime('%b').tolist()
inflation = df_monthly['abs_inflation'].tolist()

# Plot the chart
plt.plot(months, inflation)
plt.xlabel('Month')
plt.ylabel('Absolute Inflation Percentage')
plt.title('Average Absolute Inflation Percentage by Month')
plt.show()