import os
import json
import csv

extraction_path = 'submissions'

# Prepare the CSV output
csv_output_path = 'student_submission_lengths.csv'
csv_columns = ['Serial Number', 'Student Name', 'listings_join_reviews Length', 'text_search_query Length', 'update_datetimes_query Length']
data = []

# Iterate over the extracted folders to process each student's submission
serial_number = 1
for group_folder in os.listdir(extraction_path):
    group_folder_path = os.path.join(extraction_path, group_folder)
    if os.path.isdir(group_folder_path):
        for student_folder in os.listdir(group_folder_path):
            student_folder_path = os.path.join(group_folder_path, student_folder)
            if os.path.isdir(student_folder_path):
                # Initialize the lengths for each JSON file
                listings_length = 0
                text_search_length = 0
                update_datetimes_length = 0
                
                # Get the lengths of the specified JSON files
                listings_file = os.path.join(student_folder_path, 'listings_join_reviews.json')
                text_search_file = os.path.join(student_folder_path, 'text_search_query.json')
                update_datetimes_file = os.path.join(student_folder_path, 'update_datetimes_query.json')
                
                if os.path.isfile(listings_file):
                    with open(listings_file, 'r') as file:
                        listings_length = len(json.load(file))
                
                if os.path.isfile(text_search_file):
                    with open(text_search_file, 'r') as file:
                        text_search_length = len(json.load(file))
                
                if os.path.isfile(update_datetimes_file):
                    with open(update_datetimes_file, 'r') as file:
                        update_datetimes_length = len(json.load(file))
                
                # Append the data to the list
                data.append([serial_number, student_folder, listings_length, text_search_length, update_datetimes_length])
                serial_number += 1

# Write the data to the CSV file
with open(csv_output_path, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(csv_columns)
    writer.writerows(data)

print(f"Data has been written to {csv_output_path}")
