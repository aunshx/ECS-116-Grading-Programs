# Calculate the score for step_5 
import os
import pandas as pd

# Define target values and variation percentage
target_values_1 = [25196, 1672, 19228, 1281]
target_values_2 = [25197, 1930]
variation_percentage = [0.05, 0.1, 0.15, 0.2, 0.25]

def calculate_score(value, target):
    if pd.isna(value):
        return 0
    for i, percentage in enumerate(variation_percentage):
        if abs(value - target) / target <= percentage:
            return (1 - i * 0.05)
    return 0

def calculate_third_column_score(df):
    score = 0
    for i in range(len(df)):
        value = pd.to_numeric(df.iloc[i, 2], errors='coerce')
        if pd.isna(value):
            score += 0
        elif value > 0:
            score += 0.4
        else:
            score += 0
    return score

def process_student_files(extract_path):
    results = []
    submissions_path = extract_path

    for batch_folder in os.listdir(submissions_path):
        batch_path = os.path.join(submissions_path, batch_folder)
        if os.path.isdir(batch_path):
            for student_folder in os.listdir(batch_path):
                student_path = os.path.join(batch_path, student_folder)

                if os.path.isdir(student_path):
                    step_5_file = None
                    for file in os.listdir(student_path):
                        if (file.startswith('step_5') or file.startswith('step_05')) and (file.endswith('.csv') or file.endswith('.xlsx')):
                            step_5_file = os.path.join(student_path, file)
                            break

                    if step_5_file:
                        print(f"Processing file: {step_5_file} for student: {student_folder}")
                        if step_5_file.endswith('.csv'):
                            df = pd.read_csv(step_5_file)
                        else:
                            df = pd.read_excel(step_5_file)

                        total_score = 0
                        total_third_column_score = calculate_third_column_score(df)

                        try:
                            for i in range(4):
                                if i < len(df):
                                    value = float(df.iloc[i, 1])
                                    score = calculate_score(value, target_values_1[i])
                                    total_score += score
                            for i in range(2):
                                if i + 5 < len(df):
                                    value = float(df.iloc[i + 5, 1])
                                    score = calculate_score(value, target_values_2[i])
                                    total_score += score
                        except (IndexError, ValueError) as e:
                            print(f"Error for student {student_folder}: {e}")

                        total_final_score = total_score + total_third_column_score
                        normalized_score = round((total_final_score / 8.8) * 5, 2)
                        results.append([student_folder, total_score, total_third_column_score, normalized_score])
                    else:
                        # Student without a step_5 file
                        results.append([student_folder, 0, 0, 0])

    return results

extract_path = 'submissions'
results = process_student_files(extract_path)
results_df = pd.DataFrame(results, columns=['Student Name', 'Total Score', 'Total Third Column Score', 'Normalized Score'])
output_csv_path = 'results/step_5.csv'
results_df.to_csv(output_csv_path, index=False)
