import os
import pandas as pd

# Paths to reference CSV files
ref_csv1_path = 'gdp_energy_fs_aggs.csv'
ref_csv2_path = 'gdp_energy_with_fs_indicators.csv'

# Directory containing student submissions
submissions_dir = 'submissions'

# Load reference CSVs with low_memory option to avoid DtypeWarning
ref_csv1 = pd.read_csv(ref_csv1_path, low_memory=False)
ref_csv2 = pd.read_csv(ref_csv2_path, low_memory=False)

# Function to load student CSVs
def load_student_csv(path):
    return pd.read_csv(path, low_memory=False)

# Function to compare two dataframes, considering only the integer part of numbers
def compare_dataframes(df1, df2):
    # Reindex and align columns to match reference DataFrame
    df1 = df1.reindex(columns=df2.columns)
    # Truncate floating point numbers to their integer part for comparison
    df1 = df1.applymap(lambda x: int(x) if isinstance(x, float) else x)
    df2 = df2.applymap(lambda x: int(x) if isinstance(x, float) else x)
    # Compare dataframes
    comparison = df1.eq(df2)
    total_records = comparison.shape[0]
    match_count = comparison.all(axis=1).sum()
    mismatch_count = total_records - match_count
    return mismatch_count, match_count, total_records

# Prepare results DataFrame
results_path = 'results.csv'
results_columns = [
    "Serial Number", "Student Folder Name",
    "Mismatch CSV1", "Match CSV1", "Total CSV1",
    "Mismatch CSV2", "Match CSV2", "Total CSV2",
    "Total Mismatch", "Total Match"
]
results_df = pd.DataFrame(columns=results_columns)

# Process each student's folder
serial_number = 1
for student_name in os.listdir(submissions_dir):
    student_folder = os.path.join(submissions_dir, student_name)
    if os.path.isdir(student_folder):
        student_csv1_path = os.path.join(student_folder, os.path.basename(ref_csv1_path))
        student_csv2_path = os.path.join(student_folder, os.path.basename(ref_csv2_path))
        if os.path.exists(student_csv1_path) and os.path.exists(student_csv2_path):
            student_csv1 = load_student_csv(student_csv1_path)
            student_csv2 = load_student_csv(student_csv2_path)
            mismatch1, match1, total_student1 = compare_dataframes(student_csv1, ref_csv1)
            mismatch2, match2, total_student2 = compare_dataframes(student_csv2, ref_csv2)
            new_row = pd.DataFrame({
                "Serial Number": [serial_number],
                "Student Folder Name": [student_name],
                "Mismatch CSV1": [mismatch1], "Match CSV1": [match1], "Total CSV1": [total_student1],
                "Mismatch CSV2": [mismatch2], "Match CSV2": [match2], "Total CSV2": [total_student2],
                "Total Mismatch": [mismatch1 + mismatch2], "Total Match": [match1 + match2]
            }, columns=results_columns)
            results_df = pd.concat([results_df, new_row], ignore_index=True)
            serial_number += 1

# Save results to CSV
results_df.to_csv(results_path, index=False)
print("Results have been saved to:", results_path)
