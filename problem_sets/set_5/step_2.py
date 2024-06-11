import os
import shutil

# Path to the submissions directory
submissions_dir = 'submissions'

def valid_file(file_name):
    """ Check if the file is a valid SQL or CSV file and not a macOS metadata file """
    return file_name.endswith(('.csv')) and not file_name.startswith('._')

def clean_directories(directory):
    """ Remove unwanted directories like _MACOSX """
    for subdir in os.listdir(directory):
        subdir_path = os.path.join(directory, subdir)
        if os.path.isdir(subdir_path) and subdir == "_MACOSX":
            shutil.rmtree(subdir_path)
            print(f"Removed directory: {subdir_path}")

def flatten_files(student_folder):
    """ Move .csv files to be only one level deep inside the student folder, ignoring metadata files """
    for root, dirs, files in os.walk(student_folder, topdown=False):
        for file in files:
            if valid_file(file):
                file_path = os.path.join(root, file)
                new_path = os.path.join(student_folder, file)
                if file_path != new_path:
                    shutil.move(file_path, new_path)
                    print(f"Moved {file} from {file_path} to {new_path}")

def process_student_folders():
    """ Process each student folder in the submissions directory """
    if not os.path.exists(submissions_dir):
        os.makedirs(submissions_dir)
        print(f"Created directory: {submissions_dir}")

    student_folders = [name for name in os.listdir(submissions_dir) if os.path.isdir(os.path.join(submissions_dir, name))]
    for student_name in student_folders:
        student_folder = os.path.join(submissions_dir, student_name)
        clean_directories(student_folder)
        flatten_files(student_folder)

    print("Processing complete.")

# Run the processing of student folders
process_student_folders()
