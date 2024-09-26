import arcpy
import os

# Set workspace #############################
arcpy.env.workspace = r"C:\Users\Breanna.Xiong\Documents\R Scripts\ak_aoa\data\aa_exploration_data\natural_resources\EFH Percentiles Maps (Shapefile)\source"

# Set folders #############################
folder_50th = r"C:\Users\Breanna.Xiong\Documents\R Scripts\ak_aoa\data\aa_exploration_data\natural_resources\EFH Percentiles Maps (Shapefile)\50th Percentile (layer 4, 5)"
folder_95th = r"C:\Users\Breanna.Xiong\Documents\R Scripts\ak_aoa\data\aa_exploration_data\natural_resources\EFH Percentiles Maps (Shapefile)\95th Percentile (layer 2, 3, 4, 5)"


# Get file names of all the EFH #############################
raw_path = []
raw_name = []

walk = arcpy.da.Walk(datatype="FeatureClass")

for dir_path, dir_names, file_names in walk:
    for filename in file_names:
        path = os.path.join(dir_path, filename)
        raw_path.append(path) 
        
        name = filename
        base_name, extension = os.path.splitext(name)
        raw_name.append(base_name)

# print(raw_path)
# print(raw_name)      


# Create new name #############################
new_path_95th = []
new_path_50th = []

for file in raw_name:
    # Split the file path into the base name and extension

    new_name_95th = (f'{folder_95th}\\{file}_95th{extension}')
    new_path_95th.append(new_name_95th)
    
    new_name_50th = (f'{folder_50th}\\{file}_50th{extension}')
    new_path_50th.append(new_name_50th)

# print(new_path_95th)
# print(new_path_50th)


# Description: Rename a file geodatabase feature class #############################

# Set local variables
data_type = "FeatureClass"

# Run Rename

for raw, new in zip(raw_path, new_path_95th):
    
    arcpy.management.Rename(raw, new, data_type)

    # print(new)
    # print('\n')


# Get the 50th percentile (subset 'layers' with values of 4 and 5) #############################

for in_file, out_file in zip(new_path_95th, new_path_50th):
    arcpy.conversion.ExportFeatures(
    in_features= in_file,
    out_features= out_file,
    where_clause= "layer = 4 Or layer = 5")
    
    print(f'Finished with {out_file}.')
    print('\n')
    
