import os
import pandas as pd

# Paths to reference CSV files
ref_csv1_path = 'base_data/gdp_energy_with_fs_indicators.csv'

# Directory containing student submissions
submissions_dir = 'submissions'

# ! Change this value after running part_3.py Total possible points for aggs 
col_correct_points_indicators = 1343
row_correct_points_indicators = 1342
total_points_possible_fs_aggs_indicators = 16109
points_fs_aggs_base_indicators = 8054


# Load reference CSVs
ref_csv1 = pd.read_csv(ref_csv1_path, low_memory=False)

# Function to load and prepare student CSVs
def load_student_csv(path):
    df = pd.read_csv(path, low_memory=False)
    # Replace NaN with 0 or another placeholder if needed before casting to int
    df.fillna(0, inplace=True)
    return df

# Function to compare two dataframes for "gdp_energy_fs_aggs.csv"
def custom_compare_aggs(ref_df, student_df, student_name):
    points = points_fs_aggs_base_indicators

    # Check column names
    if set(ref_df.columns) == set(student_df.columns):
        points += col_correct_points_indicators
    else:
        print(f"Column names do not match. Missing columns: {set(ref_df.columns) - set(student_df.columns)} for {student_name}")
        return points, (points / total_points_possible_fs_aggs_indicators * 100)  # Return early if columns do not match

    # Check number of rows
    if len(ref_df) == len(student_df):
        points += row_correct_points_indicators

    # Compare each row for specified columns
    key_cols = ['area_code_m49', 'area', 'year_code']
    comparison_cols = [col for col in ref_df.columns if col not in key_cols]

    for index, ref_row in ref_df.iterrows():
        if index < len(student_df):
            student_row = student_df.iloc[index]
            if ref_row[key_cols[0]] == student_row[key_cols[0]] and ref_row[key_cols[1]] == student_row[key_cols[1]]:
                for col in comparison_cols:
                    if int(ref_row[col]) == int(student_row[col]):
                        points += 1

    percentage = (points / total_points_possible_fs_aggs_indicators * 100)
    return points, percentage

# Function to perform a basic comparison for "gdp_energy_with_fs_indicators.csv"
def compare_other_csv(ref_df, student_df):
    # Ensure both dataframes have the same columns in the same order
    student_df = student_df.reindex(columns=ref_df.columns)
    comparison = ref_df.eq(student_df)
    match_count = comparison.all(axis=1).sum()
    return match_count, len(ref_df)

# Prepare results DataFrame
results_df = pd.DataFrame(columns=[
    "Student Name", "Score FS IND", "Total Possible Points FS IND", "Percentage FS IND"
])

count = 0
# Process each student's folder
for student_name in os.listdir(submissions_dir):
    student_folder = os.path.join(submissions_dir, student_name)
    count += 1
    print(f"{student_folder} {count}")
    if os.path.isdir(student_folder):
        student_csv1_path = os.path.join(student_folder, os.path.basename(ref_csv1_path))

        if os.path.exists(student_csv1_path):
            student_csv1 = load_student_csv(student_csv1_path)
            score, percentage = custom_compare_aggs(ref_csv1, student_csv1, student_name)
            results_df = pd.concat([results_df, pd.DataFrame([{
                "Student Name": student_name,
                "Score FS IND": score,
                "Total Possible Points FS IND": total_points_possible_fs_aggs_indicators,
                "Percentage FS IND": percentage
            }], index=[0])], ignore_index=True)

# Save results to CSV
results_path = 'results/results_ind.csv'
results_df.to_csv(results_path, index=False)
print("Results have been saved to:", results_path)
