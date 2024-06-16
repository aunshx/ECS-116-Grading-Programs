import zipfile
import os

# Path to the uploaded zip file
zip_path = 'PA3.zip'
extract_path = 'submissions'

with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    zip_ref.extractall(extract_path)

submission_extract_path = os.path.join(extract_path, 'submissions')

os.makedirs(submission_extract_path, exist_ok=True)

def unzip_student_submissions_to_new_folder(base_path, target_path):
    for root, dirs, files in os.walk(base_path):
        for dir_name in dirs:
            if dir_name.isdigit():
                student_folder_path = os.path.join(root, dir_name)
                for file in os.listdir(student_folder_path):
                    if file.endswith('.zip'):
                        student_zip_path = os.path.join(student_folder_path, file)
                        student_name = file.split('_')[0]
                        student_extract_path = os.path.join(target_path, dir_name, student_name)
                        os.makedirs(student_extract_path, exist_ok=True)
                        with zipfile.ZipFile(student_zip_path, 'r') as student_zip_ref:
                            student_zip_ref.extractall(student_extract_path)

unzip_student_submissions_to_new_folder(extract_path, submission_extract_path)

for root, dirs, files in os.walk(submission_extract_path):
    for dir_name in dirs:
        print(f"Directory: {os.path.join(root, dir_name)}")
    for file_name in files:
        print(f"File: {os.path.join(root, file_name)}")
