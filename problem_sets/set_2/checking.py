import zipfile
import os
import re
import csv

def extract_all(zip_path, extract_to):
    """Extract all zip files recursively from the given zip_path."""
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
        extracted_files = zip_ref.namelist()

    # Check for nested zip files and extract them
    for file in extracted_files:
        full_path = os.path.join(extract_to, file)
        if file.endswith('.zip'):
            nested_extract_to = os.path.splitext(full_path)[0]  # Create a directory for the nested zip
            os.makedirs(nested_extract_to, exist_ok=True)
            extract_all(full_path, nested_extract_to)

def count_sql_queries(file_path):
    """Count the number of SQL queries in a .psql or .sql file, handling different encodings."""
    query_count = 0
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
    except UnicodeDecodeError:
        try:
            with open(file_path, 'r', encoding='latin1') as file:
                content = file.read()
        except Exception as e:
            print(f"Failed to read {file_path}: {e}")
            return query_count  # Return 0 if file cannot be read

    queries = re.findall(r'select', content, re.IGNORECASE)
    query_count = len(queries)
    return query_count

def process_directory(directory):
    """Process each .psql or .sql file in the directory and its subdirectories, ignoring macOS system files."""
    results = []
    for root, dirs, files in os.walk(directory):
        dirs[:] = [d for d in dirs if d not in ['__MACOSX']]  # Ignore macOS system folders
        files = [f for f in files if not f.startswith('.')]  # Ignore hidden files like .DS_Store
        for file in files:
            if file.endswith(".psql") or file.endswith(".sql"):
                full_path = os.path.join(root, file)
                query_count = count_sql_queries(full_path)
                results.append((os.path.basename(root).split('_')[0], query_count))
    return results

def save_to_csv(results, output_file):
    """Save the results to a CSV file."""
    with open(output_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['Student Zip', 'SQL Query Count'])
        for result in results:
            writer.writerow(result)

def main():
    # Change 'source_zip' to the path of your zip file
    source_zip = './submissions.zip'
    # Change 'extract_dir' to your desired extraction directory
    extract_dir = './results/'
    # Setup the output CSV file path
    csv_output_path = 'results.csv'

    # Ensure the extraction directory exists
    if not os.path.exists(extract_dir):
        os.makedirs(extract_dir)

    # Extract all contents recursively
    extract_all(source_zip, extract_dir)

    # Process the directory for .psql or .sql files
    results = process_directory(extract_dir)

    # Save results to CSV
    save_to_csv(results, csv_output_path)

    print(f"Results saved to {csv_output_path}")

if __name__ == "__main__":
    main()
