import os
import shutil

# Define the path to the submissions folder
extract_path = 'submissions'  # Update this path to your local submissions folder

# File extensions to move
file_extensions = ('.xlsx', '.csv', '.pdf', '.json')

# Iterate through each group folder (1, 2, 3, ...)
for group_folder in os.listdir(extract_path):
    group_folder_path = os.path.join(extract_path, group_folder)
    
    if os.path.isdir(group_folder_path):
        # Iterate through each student folder within the group folder
        for student_folder in os.listdir(group_folder_path):
            student_folder_path = os.path.join(group_folder_path, student_folder)
            
            if os.path.isdir(student_folder_path):
                # Iterate through each subfolder and file in the student folder
                for root, dirs, files in os.walk(student_folder_path):
                    for file in files:
                        if file.endswith(file_extensions):
                            # Move the file to the student folder
                            file_path = os.path.join(root, file)
                            new_file_path = os.path.join(student_folder_path, file)
                            shutil.move(file_path, new_file_path)

                    # Delete empty directories
                    for dir in dirs:
                        dir_path = os.path.join(root, dir)
                        if not os.listdir(dir_path):
                            os.rmdir(dir_path)

# Verify the result
for group_folder in os.listdir(extract_path):
    group_folder_path = os.path.join(extract_path, group_folder)
    if os.path.isdir(group_folder_path):
        for student_folder in os.listdir(group_folder_path):
            student_folder_path = os.path.join(group_folder_path, student_folder)
            if os.path.isdir(student_folder_path):
                print(f"Contents of {student_folder_path}: {os.listdir(student_folder_path)}")
