import pandas as pd
import os

# Function to compare counts and calculate points
def calculate_points(student_counts, answer_counts):
    points = 0
    total_queries = len(answer_counts)

    print("HELLO", student_counts, answer_counts)
    
    for student_count, answer_count in zip(student_counts, answer_counts):
        difference = abs(student_count - answer_count) / answer_count * 100
        if difference == 0:
            points += 2
        elif difference <= 5:
            points += 1.8
        elif difference <= 10:
            points += 1.7
        elif difference <= 15:
            points += 1.6
        elif difference <= 20:
            points += 1.5
        else:
            points += 1
    
    return points

# Convert points to score out of 2
def calculate_score(points):
    max_points = 8  # Maximum points possible
    return (points / max_points) * 2

# Load the answer_key
answer_counts = [3685, 5658, 15890, 17121]

# Directory containing student submissions
student_submissions_dir = 'submissions'

# Initialize results list
results = []

# List of possible student csv filenames
possible_filenames = [
    'problem_set_05.csv',
    'problem_set_5.csv',
    'prob_set_5.csv',
    'prob_set_05.csv'
]

# Iterate through each student's folder
serial_number = 1
for student_folder in os.listdir(student_submissions_dir):
    student_folder_path = os.path.join(student_submissions_dir, student_folder)
    
    # Check if it's a directory
    if os.path.isdir(student_folder_path):
        # Find the correct student CSV file
        student_csv_path = None
        for filename in possible_filenames:
            potential_path = os.path.join(student_folder_path, filename)
            print("POTENTIAL PATH", potential_path, student_folder)
            if os.path.exists(potential_path):
                student_csv_path = potential_path
                break
        
        if student_csv_path:
            # Load the student's CSV file
            student_df = pd.read_csv(student_csv_path)
            print(f"Columns in {student_csv_path}: {student_df.columns.tolist()}")
            
            # Check if 'Count' column exists
            if 'Count' in student_df.columns:
                student_counts = student_df['Count'].values
                # Calculate points
                points = calculate_points(student_counts, answer_counts)
                # Calculate score
                score = calculate_score(points)
                # Append result
                results.append({
                    'Serial Number': serial_number,
                    'Student Name': student_folder,
                    'Points': points,
                    'Score': score
                })
                serial_number += 1
            else:
                print(f"Error: 'Count' column not found in {student_csv_path}")

# Save results to CSV
results_df = pd.DataFrame(results)
results_df.to_csv('results/results.csv', index=False)

