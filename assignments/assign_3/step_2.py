import zipfile
import os

extract_path = 'submissions'

for folder_name in os.listdir(extract_path):
    folder_path = os.path.join(extract_path, folder_name)
    if zipfile.is_zipfile(folder_path):
        new_folder_name = folder_name.split('_')[0]
        new_folder_path = os.path.join(extract_path, new_folder_name)
        
        with zipfile.ZipFile(folder_path, 'r') as zip_ref:
            zip_ref.extractall(new_folder_path)
        
        os.remove(folder_path)

print(os.listdir(extract_path))
