# Calculate correctness of listing_with_calendar_subset json
import os
import json
import pandas as pd

# Define the correct value and variation thresholds
correct_value = 15695
variation_thresholds = [0.05, 0.10, 0.15, 0.20]
points_deducted = 0.25

def calculate_total_dates_length(file_path):
    total_length = 0
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        for obj in data:
            if 'dates_list' in obj:
                total_length += len(obj['dates_list'])
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
    submissions_path = extract_path  # Assuming this is the path to the extracted folder

    for batch_folder in os.listdir(submissions_path):
        batch_path = os.path.join(submissions_path, batch_folder)
        if os.path.isdir(batch_path):
            for student_folder in os.listdir(batch_path):
                student_path = os.path.join(batch_path, student_folder)

                if os.path.isdir(student_path):
                    json_file = None
                    for file in os.listdir(student_path):
                        if file in ['listings_with_calendar_subset_1000.json', 'listings_with_calendar_subset.json']:
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
                        # Student without a relevant JSON file
                        results.append([student_folder, 0, 0])

    return results

# Assuming the extracted path is directly the submissions folder
extract_path = 'submissions'
results = process_student_json_files(extract_path)
results_df = pd.DataFrame(results, columns=['Student Name', 'Total Length of Dates List', 'Total Score'])
output_csv_path = 'results/calendar_json.csv'
results_df.to_csv(output_csv_path, index=False)
