# Check the correct total lengths from which to compare the results.
# Select the length with the most occurrences. 

import os
import json
import pandas as pd

def calculate_total_lengths(file_path):
    total_length = 0
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        # Comment out whatever field you don't want to check according to the json file selected
        for obj in data:
            if 'dates_list' in obj:
                total_length += len(obj['dates_list'])
            if 'reviews' in obj:
                total_length += len(obj['reviews'])
    return total_length

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
                        # Change the below file name according to what you want to check
                        if file in ['listings_with_reviews_and_cal_subset_1000.json']:
                            json_file = os.path.join(student_path, file)
                            break

                    if json_file:
                        print(f"Processing file: {json_file} for student: {student_folder}")
                        try:
                            total_length = calculate_total_lengths(json_file)
                        except Exception as e:
                            print(f"Error processing file {json_file} for student {student_folder}: {e}")
                            total_length = 0
                        results.append([student_folder, total_length])
                    else:
                        results.append([student_folder, 0])

    return results

extract_path = 'submissions'
results = process_student_json_files(extract_path)
results_df = pd.DataFrame(results, columns=['Student Name', 'Total Length'])
output_csv_path = 'results/max_length_json.csv'
results_df.to_csv(output_csv_path, index=False)
