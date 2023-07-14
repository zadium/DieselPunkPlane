### Create mesh object of object that have a Face Map with name `Convex`
import bpy
import bmesh
import os
from bl_ui.utils import PresetPanel
from bpy.types import Panel, Menu

#convex_names = ["Hull", "Wings", "Wheels", "Wheel"]
convex_names = ["Hull"]

face_map_name = "Convex"

#Create _Convex collection
if "_Convex" in bpy.data.collections:
    convex_collection = bpy.data.collections["_Convex"]
else:
    convex_collection = bpy.data.collections.new('_Convex')
    bpy.context.scene.collection.children.link(convex_collection)

if bpy.context.mode != "OBJECT":
    bpy.ops.object.mode_set(mode='OBJECT')

for object_name in convex_names:
#for obj in bpy.data.objects:

    #bpy.ops.object.select_all(action='DESELECT')
    #bpy.context.view_layer.objects.active = obj
    obj = bpy.data.objects[object_name]
    
    
    if face_map_name in obj.face_maps:
        
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
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
            
        bpy.ops.object.mode_set(mode='EDIT')

        bpy.ops.mesh.duplicate_move(MESH_OT_duplicate={"mode":1})
        bpy.ops.mesh.separate(type='SELECTED')

        bpy.ops.object.mode_set(mode='OBJECT')        
        new_objs = [obj for obj in bpy.context.selected_objects if obj != bpy.context.object]
        new_obj = new_objs[0]

        new_obj.name = obj.name+"_Convex"
        #bpy.context.scene.collection.objects.unlink(new_obj)            
        convex_collection.objects.link(new_obj)        