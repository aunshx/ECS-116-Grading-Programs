import os
import pandas as pd

# Paths to reference CSV files
ref_csv1_path = 'gdp_energy_fs_aggs.csv'
ref_csv2_path = 'gdp_energy_with_fs_indicators.csv'

# Directory containing student submissions
submissions_dir = 'submissions'

# Load reference CSVs
ref_csv1 = pd.read_csv(ref_csv1_path, low_memory=False)
ref_csv2 = pd.read_csv(ref_csv2_path, low_memory=False)

# Function to load and prepare student CSVs
def load_student_csv(path):
    df = pd.read_csv(path, low_memory=False)
    # Replace NaN with 0 or another placeholder if needed before casting to int
    df.fillna(0, inplace=True)
    return df

# Function to compare two dataframes
def compare_dataframes(df1, df2):
    df1 = df1.apply(lambda x: x.astype(int) if x.dtype.kind in 'f' else x)
    df2 = df2.apply(lambda x: x.astype(int) if x.dtype.kind in 'f' else x)
    comparison = df1.eq(df2)
    total_records = comparison.shape[0]
    match_count = comparison.all(axis=1).sum()
    mismatch_count = total_records - match_count
    return mismatch_count, match_count, total_records

# Prepare results DataFrame
results_df = pd.DataFrame(columns=[
    "Student Folder Name", "Mismatch CSV1", "Match CSV1", "Total CSV1", "Mismatch CSV2", "Match CSV2", "Total CSV2"
])

count = 0
# Process each student's folder
for student_name in os.listdir(submissions_dir):
    count += 1
    student_folder = os.path.join(submissions_dir, student_name)
    print(f"{student_folder} {count}")

    if os.path.isdir(student_folder):
        student_csv1_path = os.path.join(student_folder, os.path.basename(ref_csv1_path))
        student_csv2_path = os.path.join(student_folder, os.path.basename(ref_csv2_path))

        print(f"{student_csv1_path} {student_csv2_path}")
        
        if os.path.exists(student_csv1_path) and os.path.exists(student_csv2_path):
            student_csv1 = load_student_csv(student_csv1_path)
            student_csv2 = load_student_csv(student_csv2_path)
            mismatch1, match1, total1 = compare_dataframes(student_csv1, ref_csv1)
            mismatch2, match2, total2 = compare_dataframes(student_csv2, ref_csv2)
            new_row = {
                "Student Folder Name": student_name,
                "Mismatch CSV1": mismatch1, "Match CSV1": match1, "Total CSV1": total1,
                "Mismatch CSV2": mismatch2, "Match CSV2": match2, "Total CSV2": total2
            }
            results_df = pd.concat([results_df, pd.DataFrame([new_row])], ignore_index=True)

# Save results to CSV
results_path = 'results.csv'
results_df.to_csv(results_path, index=False)
print("Results have been saved to:", results_path)
