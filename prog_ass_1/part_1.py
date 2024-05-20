import zipfile
import os

# Path to the main zip file and submissions directory
main_zip_path = 'PA1.zip'  # Update this to the correct path
submissions_dir = 'submissions'
os.makedirs(submissions_dir, exist_ok=True)

def is_zip_file(filepath):
    """ Check if the file is a zip file """
    try:
        with zipfile.ZipFile(filepath, 'r') as test_zip:
            return True
    except zipfile.BadZipFile:
        return False

def extract_files(zip_path, extract_to):
    """ Recursively extract .sql and .csv files from zip files """
    if not is_zip_file(zip_path):
        print(f"Warning: {zip_path} is not a zip file or is corrupted.")
        return

    with zipfile.ZipFile(zip_path, 'r') as z:
        # List all files and directories in the zip file
        for file_info in z.infolist():
            if file_info.filename.endswith('.zip'):
                # It's a nested zip file, extract it and dive in
                nested_zip_path = os.path.join(extract_to, file_info.filename)
                z.extract(file_info, extract_to)
                extract_files(nested_zip_path, extract_to)
                os.remove(nested_zip_path)  # Cleanup nested zip after extraction
            elif file_info.filename.endswith(('.sql', '.csv')):
                # Extract only .sql and .csv files
                z.extract(file_info, extract_to)

def process_student_files():
    """ Process each student's zip file within the main PA1.zip """
    with zipfile.ZipFile(main_zip_path, 'r') as main_zip:
        file_count = len(main_zip.infolist())
        print(f"Total files in PA1.zip: {file_count}")
        
        for student_zip_info in main_zip.infolist():
            if student_zip_info.filename.endswith('.zip'):
                # Determine the student's folder name
                student_name = student_zip_info.filename.split('_')[0]
                student_folder = os.path.join(submissions_dir, student_name)
                os.makedirs(student_folder, exist_ok=True)
                
                # Extract the student zip to a temporary location
                student_zip_path = os.path.join(student_folder, student_zip_info.filename)
                main_zip.extract(student_zip_info, student_folder)
                
                # Recursively extract files if it's a valid zip file
                if is_zip_file(student_zip_path):
                    extract_files(student_zip_path, student_folder)
                else:
                    print(f"Extracted file {student_zip_path} is not a zip file.")
                
                # Remove the student zip file after processing
                os.remove(student_zip_path)
    
    # Count subfolders in the submissions directory
    subfolder_count = len([name for name in os.listdir(submissions_dir) if os.path.isdir(os.path.join(submissions_dir, name))])
    print(f"Total subfolders in submissions: {subfolder_count}")

# Run the extraction process
process_student_files()
