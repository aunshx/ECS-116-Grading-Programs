import os
import shutil

# Path to the submissions directory
submissions_dir = 'submissions'

def valid_file(file_name):
    """ Check if the file is a valid SQL or CSV file and not a macOS metadata file """
    return (file_name.endswith(('.sql', '.csv')) and not file_name.startswith('._'))

def sanitize_filename(file_name):
    """ Remove leading and trailing spaces from filenames """
    return file_name.strip()

def clean_directories(directory):
    """ Remove unwanted directories like _MACOSX """
    for subdir in os.listdir(directory):
        subdir_path = os.path.join(directory, subdir)
        if os.path.isdir(subdir_path) and subdir == "_MACOSX":
            shutil.rmtree(subdir_path)
            print(f"Removed directory: {subdir_path}")

def flatten_files(student_folder):
    """ Move .sql and .csv files to be only one level deep inside the student folder, ignoring metadata files """
    clean_directories(student_folder)  # Clean up unwanted directories first
    for root, dirs, files in os.walk(student_folder, topdown=False):
        for file in files:
            if valid_file(file):
                file_path = os.path.join(root, file)
                sanitized_file = sanitize_filename(file)
                new_path = os.path.join(student_folder, sanitized_file)
                # Check if file is already at the correct location
                if file_path != new_path:
                    shutil.move(file_path, new_path)
                    print(f"Moved {file} from {file_path} to {new_path}")

def count_student_folders(directory):
    """ Count and return the number of student folders in a given directory """
    return len([name for name in os.listdir(directory) if os.path.isdir(os.path.join(directory, name))])

def process_student_folders():
    """ Process each student folder in the submissions directory and count them before and after processing """
    if not os.path.exists(submissions_dir):
        os.makedirs(submissions_dir)
        print(f"Created directory: {submissions_dir}")

    # Initial count of student folders
    initial_count = count_student_folders(submissions_dir)
    print(f"Initial count of student folders in submissions: {initial_count}")

    student_folders = [name for name in os.listdir(submissions_dir) if os.path.isdir(os.path.join(submissions_dir, name))]
    for student_name in student_folders:
        student_folder = os.path.join(submissions_dir, student_name)
        flatten_files(student_folder)

    # Final count of student folders
    final_count = count_student_folders(submissions_dir)
    print(f"Final count of student folders in submissions: {final_count}")

# Run the processing of student folders
process_student_folders()
