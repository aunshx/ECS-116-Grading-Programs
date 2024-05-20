import os
import pandas as pd

# Paths to reference CSV files
ref_csv2_path = 'gdp_energy_with_fs_indicators.csv'

# Directory containing student submissions
submissions_dir = 'testing_data'

# Base Points 
base_points = 8054
col_correct_points = 1343
row_correct_points = 1342

# Load reference CSVs
ref_csv2 = pd.read_csv(ref_csv2_path, low_memory=False)

# Function to load and prepare student CSVs
def load_student_csv(path):
    df = pd.read_csv(path, low_memory=False)
    # Replace NaN with 0 or another placeholder if needed before casting to int
    df.fillna(0, inplace=True)
    return df

# Function to compare two dataframes for "gdp_energy_fs_aggs.csv"
def custom_compare_aggs(ref_df, student_df, student_name):
    total_possible_points = base_points  # 10 points for column names, 10 points for row count

    # Check column names
    if set(ref_df.columns) == set(student_df.columns):
        total_possible_points += col_correct_points
    else:
        print(f"Column names do not match. Missing columns: {set(ref_df.columns) - set(student_df.columns)} for {student_name}")
        return total_possible_points, 0  # Return early if columns do not match

    # Check number of rows
    if len(ref_df) == len(student_df):
        total_possible_points += row_correct_points

    # Compare each row for specified columns
    key_cols = ['area_code_m49', 'area', 'year_code']
    comparison_cols = [col for col in ref_df.columns if col not in key_cols]

    points = 0
    for index, ref_row in ref_df.iterrows():
        if index < len(student_df):
            student_row = student_df.iloc[index]
            if ref_row[key_cols[0]] == student_row[key_cols[0]] and ref_row[key_cols[1]] == student_row[key_cols[1]]:
                for col in comparison_cols:
                    if int(ref_row[col]) == int(student_row[col]):
                        total_possible_points += 1
                        points += 1

    return total_possible_points, points


# Process each student's folder
for student_name in os.listdir(submissions_dir):
    student_folder = os.path.join(submissions_dir, student_name)
    if os.path.isdir(student_folder):
        student_csv2_path = os.path.join(student_folder, os.path.basename(ref_csv2_path))

        if os.path.exists(student_csv2_path):
            student_csv1 = load_student_csv(student_csv2_path)
            total_possible_points, points = custom_compare_aggs(ref_csv2, student_csv1, student_name)
            print(f"The total_points_possible_fs_aggs_indicators = {total_possible_points}, column base points = {col_correct_points}, row base points = {row_correct_points}, table correctness points = {points}, base points = {base_points}")

