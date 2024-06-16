# Calculate correctness of listings_with_reviews_and_cal_subset_1000.json
import os
import json
import pandas as pd

# Define the correct value and variation thresholds
correct_value = 15966
variation_thresholds = [0.05, 0.10, 0.15, 0.20]
points_deducted = 0.25

def calculate_total_dates_length(file_path):
    total_length = 0
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        for obj in data:
            if 'dates_list' in obj:
                total_length += len(obj['dates_list'])
            if 'reviews' in obj:
                total_length += len(obj['reviews'])
    return total_length

def calculate_score(total_length):
    if total_length == 0:
        return 1
    if total_length == correct_value:
        return 4
    variation = abs(total_length - correct_value) / correct_value
    for threshold in variation_thresholds:
        if variation <= threshold:
            return 4 - (variation_thresholds.index(threshold) + 1) * points_deducted
    if variation > 0.20:
        return 2
    return 1

def process_student_json_files(extract_path):
    results = []
    submissions_path = extract_path

    for batch_folder in os.listdir(submissions_path):
        batch_path = os.path.join(submissions_path, batch_folder)
        if os.path.isdir(batch_path):
            for student_folder in os.listdir(batch_path):
                student_path = os.path.join(batch_path, student_folder)

                if os.path.isdir(student_path):
                    json_file = None
                    for file in os.listdir(student_path):
                        if file in ['listings_with_reviews_and_cal_subset_1000.json']:
                            json_file = os.path.join(student_path, file)
                            break

                    if json_file:
                        print(f"Processing file: {json_file} for student: {student_folder}")
                        try:
                            total_length = calculate_total_dates_length(json_file)
                        except Exception as e:
                            print(f"Error processing file {json_file} for student {student_folder}: {e}")
                            total_length = 1
                        total_score = calculate_score(total_length)
                        results.append([student_folder, total_length, total_score])
                    else:
                        results.append([student_folder, 0, 0])

    return results

extract_path = 'submissions'
results = process_student_json_files(extract_path)
results_df = pd.DataFrame(results, columns=['Student Name', 'Total Length of Combined List', 'Total Score'])
output_csv_path = 'results/caldate_json.csv'
results_df.to_csv(output_csv_path, index=False)
