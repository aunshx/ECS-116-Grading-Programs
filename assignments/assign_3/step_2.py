import zipfile
import os

extract_path = 'submissions'

# Iterate through each subfolder in the extracted submissions folder
for folder_name in os.listdir(extract_path):
    folder_path = os.path.join(extract_path, folder_name)
    if zipfile.is_zipfile(folder_path):
        # Create a new folder name based on the first part of the original folder name
        new_folder_name = folder_name.split('_')[0]
        new_folder_path = os.path.join(extract_path, new_folder_name)
        
        # Extract the contents of the zip file to the new folder
        with zipfile.ZipFile(folder_path, 'r') as zip_ref:
            zip_ref.extractall(new_folder_path)
        
        # Remove the original zip file
        os.remove(folder_path)

# Verify the result
print(os.listdir(extract_path))
