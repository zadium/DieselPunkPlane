import bpy
import bmesh
import os
from bl_ui.utils import PresetPanel
from bpy.types import Panel, Menu

#convex_names = ["Hull", "Wheels", "Wheel", "Wings"]
convex_names = ["Hull"]

bpy.ops.object.mode_set(mode='OBJECT')

for object_name in convex_names:    
    bpy.ops.object.select_all(action='DESELECT')
    obj = bpy.data.objects[object_name]
    obj.select_set(True)
    
    obj = bpy.context.active_object
    mesh = obj.data
    
# MUST BE in Object mode    
    face_map_name = "Convex"
#    face_map = obj.face_maps[face_map_name]
    
#    face_map = obj.face_maps.active        
#    if face_map.name != face_map_name:
#        face_map = obj.face_maps[face_map_name]
#        bpy.ops.object.face_maps.active = face_map
    face_map_index = obj.face_maps[face_map_name].index

#    print("name="+mesh.face_maps[face_map_index].name);
    # get its index
    face_map = mesh.face_maps[face_map_index] # no name for face map inside mesh

    # run over the data of the face map data layer (only one layer, so [0])
    for i, fm_data in enumerate(mesh.face_maps[0].data):
        # select the polygon if its fm layer value correspond to the good face map
        # fm_data.value can be either -1 (unassigned) or the index of the face map it is assigned to
        mesh.polygons[i].select = fm_data.value == face_map_index
    
    bpy.ops.object.mode_set(mode='EDIT')
    
    bm = bmesh.from_edit_mesh(obj.data)
    selected_faces = [f for f in bm.faces if f.select]
    
    bpy.ops.mesh.duplicate_move() #(give a warning because context is normally using the UI, but no consequences)
    bpy.ops.mesh.separate(type='SELECTED')    
    
    bpy.ops.mesh.duplicate_move(MESH_OT_duplicate={"mode":1}, TRANSFORM_OT_translate={"value":(5, 0, 0), "orient_axis_ortho":'X', "orient_type":'GLOBAL', "orient_matrix":((1, 0, 0), (0, 1, 0), (0, 0, 1)), "orient_matrix_type":'GLOBAL', "constraint_axis":(True, False, False), "mirror":False, "use_proportional_edit":False, "proportional_edit_falloff":'SMOOTH', "proportional_size":0.0630394, "use_proportional_connected":False, "use_proportional_projected":False, "snap":False, "snap_elements":{'INCREMENT'}, "use_snap_project":False, "snap_target":'CLOSEST', "use_snap_self":True, "use_snap_edit":True, "use_snap_nonedit":True, "use_snap_selectable":False, "snap_point":(0, 0, 0), "snap_align":False, "snap_normal":(0, 0, 0), "gpencil_strokes":False, "cursor_transform":False, "texture_space":False, "remove_on_cancel":False, "view2d_edge_pan":False, "release_confirm":False, "use_accurate":False, "use_automerge_and_split":False})

    
    bpy.ops.object.mode_set(mode='OBJECT')

    # Create a new mesh from the selected faces

    # Create a new object from the new mesh
    new_obj = bpy.data.objects.new(obj.name+"_Convex", new_mesh)
    bpy.context.scene.collection.objects.link(new_obj)

    # Select the new object
    bpy.context.view_layer.objects.active = new_obj
        
#    bpy.ops.mesh.select_mode(type='FACE')
#    bpy.ops.mesh.select_all(action='DESELECT')

            
#    bpy.ops.object.face_map_select()