"""
    @author: Zaher Dirkey
    @licesnse: MPL
    Export all objects that have Face Map = "Convex" as individual files, 
    The rest of objects exported as one file     
"""
import bpy
import os
from bl_ui.utils import PresetPanel
from bpy.types import Panel, Menu

# Replace these with the names of the objects you want to export
#object_names = ["HullConvex", "WheelsConvex", "WheelConvex", "WingsConvex", "Hull", "Wheels", "Wheel", "Wings"]
                
## Correct names of mesh
for obj in bpy.data.objects:
    if obj.data.library is not None:
        obj.data.name = obj.name                
#    else:
#        obj.transform_apply(location=True, rotation=True, scale=True, isolate_users=True)

                
object_names = [obj.name for obj in bpy.data.objects if "Convex" in obj.face_maps]
                
#export_preset_name = "My"

# Replace this with the path to the folder where you want to export the DAE files
export_folder = os.path.dirname(bpy.data.filepath)+"/output/"

if not os.path.exists(export_folder):
    os.makedirs(export_folder)

# Create the export folder if it doesn't exist
if not os.path.exists(export_folder):
    os.makedirs(export_folder)

for object_name in object_names:
    bpy.ops.object.select_all(action='DESELECT')
    obj = bpy.data.objects[object_name]
    obj.select_set(True)
    export_path = os.path.join(export_folder, obj.name + ".dae")
    bpy.ops.wm.collada_export(
        filepath=export_path, 
        selected=True, 
        apply_modifiers=True, 
        open_sim=True, 
        ## export_object_transformation_type_selection='decomposed', ## ---nop---need it for scale -1 for some linked objects
        apply_global_orientation=True, ## idk
        use_texture_copies=True,
        sort_by_name=False,        
        export_global_forward_selection='Y',
        export_global_up_selection='Z',
        export_mesh_type_selection='view',
        use_object_instantiation=True        
    )

bpy.ops.object.select_all(action='SELECT')
for object_name in object_names:
    obj = bpy.data.objects[object_name]
    obj.select_set(False)

export_path = os.path.join(export_folder, os.path.splitext(os.path.basename(bpy.data.filepath))[0] + ".dae")
bpy.ops.wm.collada_export(filepath=export_path, selected=True, apply_modifiers=True, open_sim=True, use_texture_copies=False)

bpy.ops.object.select_all(action='DESELECT')
