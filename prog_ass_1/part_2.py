import os
import shutil

# Path to the submissions directory
submissions_dir = 'submissions'

# Standard names for the CSV files
standard_csv1 = 'base_data/gdp_energy_fs_aggs.csv'
standard_csv2 = 'base_data/gdp_energy_with_fs_indicators.csv'

def valid_file(file_name):
    """ Check if the file is a valid SQL or CSV file and not a macOS metadata file """
    return file_name.endswith(('.sql', '.csv')) and not file_name.startswith('._')

def clean_directories(directory):
    """ Remove unwanted directories like _MACOSX """
    for subdir in os.listdir(directory):
        subdir_path = os.path.join(directory, subdir)
        if os.path.isdir(subdir_path) and subdir == "_MACOSX":
            shutil.rmtree(subdir_path)
            print(f"Removed directory: {subdir_path}")

def flatten_files(student_folder):
    """ Move .sql and .csv files to be only one level deep inside the student folder, ignoring metadata files """
    for root, dirs, files in os.walk(student_folder, topdown=False):
        for file in files:
            if valid_file(file):
                file_path = os.path.join(root, file)
                new_path = os.path.join(student_folder, file)
                if file_path != new_path:
                    shutil.move(file_path, new_path)
                    print(f"Moved {file} from {file_path} to {new_path}")

def normalize_csv_names(student_folder):
    """ Rename CSV files to standard names based on predefined prefixes, removing all whitespaces first. """
    for file in os.listdir(student_folder):
        file_path = os.path.join(student_folder, file)
        # Sanitize the filename by removing whitespace
        sanitized_file = ''.join(file.split())
        sanitized_path = os.path.join(student_folder, sanitized_file)
        
        # Rename the file to remove spaces if needed
        if file_path != sanitized_path:
            shutil.move(file_path, sanitized_path)
            print(f"Sanitized {file} to {sanitized_file}")
            file = sanitized_file
            file_path = sanitized_path
        
        parts = file.split('_')
        
        # Rebuild and rename based on specific rules
        if file.startswith('gdp_energy_fs_aggs') and file.endswith('.csv'):
            new_filename = '_'.join(parts[:4]) + '.csv'
            parts = new_filename.split('.csv')
            normalized_filename = '.csv'.join(filter(None, parts)) + ('.csv' if new_filename.endswith('.csv') else '')

            new_path = os.path.join(student_folder, normalized_filename)
            if file_path != new_path:
                shutil.move(file_path, new_path)
                print(f"Renamed {file} to {normalized_filename}")
        
        elif file.startswith('gdp_energy_with_fs_indicators') and file.endswith('.csv'):
            new_filename = '_'.join(parts[:5]) + '.csv'
            parts = new_filename.split('.csv')
            normalized_filename = '.csv'.join(filter(None, parts)) + ('.csv' if new_filename.endswith('.csv') else '')

            new_path = os.path.join(student_folder, normalized_filename)
            if file_path != new_path:
                shutil.move(file_path, new_path)
                print(f"Renamed {file} to {normalized_filename}")

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
        normalize_csv_names(student_folder)

    print("Processing complete.")

# Run the processing of student folders
process_student_folders()
