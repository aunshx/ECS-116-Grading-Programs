import pandas as pd

# Load the CSV files
results_path = 'results/results_aggs.csv'
results_ind_path = 'results/results_ind.csv'

# Read CSV files
results_df = pd.read_csv(results_path)
results_ind_df = pd.read_csv(results_ind_path)

# Merge the dataframes on 'Student Folder Name'
combined_df = pd.merge(results_df, results_ind_df, on='Student Name', how='inner')

# Calculate the average of 'Percentage FS IND' and 'Percentage FS AGGS'
combined_df['Total Correctness'] = combined_df[['Percentage FS AGGS', 'Percentage FS IND']].mean(axis=1)

for col in ['Percentage FS AGGS', 'Percentage FS IND', 'Total Correctness']:
    combined_df[col] = combined_df[col].round(2)

# Save the combined dataframe to a new CSV file
combined_df.to_csv('results/main_results.csv', index=False)
print("Combined results have been saved to: results/combined_results.csv")
