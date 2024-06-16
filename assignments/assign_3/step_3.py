import os
import shutil

# Define the path to the submissions folder
extract_path = 'submissions'

# File extensions to move
file_extensions = ('.xlsx', '.csv', '.pdf', '.json')

for group_folder in os.listdir(extract_path):
    group_folder_path = os.path.join(extract_path, group_folder)
    
    if os.path.isdir(group_folder_path):
        for student_folder in os.listdir(group_folder_path):
            student_folder_path = os.path.join(group_folder_path, student_folder)
            
            if os.path.isdir(student_folder_path):
                for root, dirs, files in os.walk(student_folder_path):
                    for file in files:
                        if file.endswith(file_extensions):
                            file_path = os.path.join(root, file)
                            new_file_path = os.path.join(student_folder_path, file)
                            shutil.move(file_path, new_file_path)

                    for dir in dirs:
                        dir_path = os.path.join(root, dir)
                        if not os.listdir(dir_path):
                            os.rmdir(dir_path)

for group_folder in os.listdir(extract_path):
    group_folder_path = os.path.join(extract_path, group_folder)
    if os.path.isdir(group_folder_path):
        for student_folder in os.listdir(group_folder_path):
            student_folder_path = os.path.join(group_folder_path, student_folder)
            if os.path.isdir(student_folder_path):
                print(f"Contents of {student_folder_path}: {os.listdir(student_folder_path)}")
