### Create mesh object of object that have a Face Map with name `Convex`
import bpy
import bmesh
import os
from bl_ui.utils import PresetPanel
from bpy.types import Panel, Menu

face_map_name = "Convex"
collection_convex_name = "Convex"

#Create _Convex collection
if collection_convex_name in bpy.data.collections:
    convex_collection = bpy.data.collections[collection_convex_name]
else:
    convex_collection = bpy.data.collections.new(collection_convex_name)
    bpy.context.scene.collection.children.link(convex_collection)

if bpy.context.mode != "OBJECT":
    bpy.ops.object.mode_set(mode='OBJECT')
    
bpy.ops.object.select_all(action='DESELECT')

## Collect objects that have facemap named "Convect"S
convexObjects = [obj for obj in bpy.data.objects if face_map_name in obj.face_maps]
    
for obj in convexObjects:

    if face_map_name in obj.face_maps:
        
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        
        mesh = obj.data
        
        face_map_index = obj.face_maps[face_map_name].index
        face_map = mesh.face_maps[face_map_index] # no name for face map inside mesh
        
        ## MUST BE in Object mode
        face_map_index = obj.face_maps[face_map_name].index        
        face_map = mesh.face_maps[face_map_index] # no name for face map inside mesh
        
        for i, fm_data in enumerate(face_map.data):
            # fm_data.value can be either -1 (unassigned) or the index of the face map it is assigned to
            selected = fm_data.value == face_map_index
            f = mesh.polygons[i]
            f.select = selected # Select the face, maybe we do not need it        
            
        old_selected = [o for o in bpy.context.scene.objects]
            
        bpy.ops.object.mode_set(mode='EDIT')
        bpy.ops.mesh.duplicate_move(MESH_OT_duplicate={"mode":1})
        bpy.ops.mesh.separate(type='SELECTED')
        
        cur_selected = [o for o in bpy.context.scene.objects]
        new_obj = [o for o in cur_selected if o not in old_selected][0]
        print("org=", obj.name, "org=", new_obj.name)

        for coll in new_obj.users_collection:
            coll.objects.unlink(new_obj)
            
        new_obj.name = obj.name+"_Convex"
        convex_collection.objects.link(new_obj)
        bpy.ops.object.mode_set(mode='OBJECT')
        