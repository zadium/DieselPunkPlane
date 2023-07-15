### Create mesh object of object that have a Face Map with name `Convex`
import bpy
import bmesh
import os
from bl_ui.utils import PresetPanel
from bpy.types import Panel, Menu

convex_names = ["Hull", "Wings", "Wheels", "Wheel"]

face_map_name = "Convex"

#Create _Convex collection
if "_Convex" in bpy.data.collections:
    convex_collection = bpy.data.collections["_Convex"]
else:
    convex_collection = bpy.data.collections.new('_Convex')
    bpy.context.scene.collection.children.link(convex_collection)

if bpy.context.mode == "Object":
    bpy.object.mode_set(mode='OBJECT')

for object_name in convex_names:
#for obj in bpy.data.objects:

    #bpy.ops.object.select_all(action='DESELECT')
    obj = bpy.data.objects[object_name]
    if face_map_name in obj.face_maps:

        #obj = bpy.context.active_object
        mesh = obj.data

        face_map_index = obj.face_maps[face_map_name].index
        face_map = mesh.face_maps[face_map_index] # no name for face map inside mesh

        obj.select_set(True)
    #    if bpy.context.mode == "Object":
    #        bpy.object.mode_set(mode='OBJECT')


    ## MUST BE in Object mode
    #    face_map = obj.face_maps[face_map_name]

    #    face_map = obj.face_maps.active
    #    if face_map.name != face_map_name:
    #    face_map = obj.face_maps[face_map_name]
    #    bpy.ops.object.face_maps.active = face_map
        face_map_index = obj.face_maps[face_map_name].index

    #    print("name="+mesh.face_maps[face_map_index].name);

        face_map = mesh.face_maps[face_map_index] # no name for face map inside mesh

        selected_faces = []

        for i, fm_data in enumerate(face_map.data):
            # fm_data.value can be either -1 (unassigned) or the index of the face map it is assigned to
            selected = fm_data.value == face_map_index
            f = mesh.polygons[i]
            f.select = selected # Select the face, maybe we do not need it
            if selected:
                selected_faces.append(f)

        #bpy.context.mode_set(mode='EDIT')
        #bpy.object.mode_set(mode='OBJECT')
        #bm = bmesh.from_edit_mesh(obj.data)
        #selected_faces = [f for f in bm.faces if f.select]

        #bpy.ops.object.mode_set(mode='OBJECT')
        #selected_faces = [f for f in mesh.polygons if f.select]
        #mesh.validate()
        vertices = []
        for f in selected_faces:
            for v in f.vertices:
                vertices.append(mesh.vertices[v].co)

        faces = []
        for f in selected_faces:
            faces.append(f.vertices)

        #new_mesh = bpy.data.meshes.new_from_object(obj)
        new_mesh = bpy.data.meshes.new(obj.name+"_Convex_Mesh")
        #new_mesh.from_pydata([v.co for f in selected_faces for v in f.vertices], [], [[v.index for v in f.vertices] for f in selected_faces])
        new_mesh.from_pydata(vertices, [], faces)
        mesh.update(calc_edges=True)

        # Create a new object from the new mesh
        new_obj = bpy.data.objects.new(obj.name+"_Convex", new_mesh)

        convex_collection.objects.link(new_obj)
        #bpy.context.scene.collection.objects.link(new_obj)

        bpy.context.view_layer.objects.active = obj
        obj.select_set(False)
        new_obj.select_set(True)

        for mod in obj.modifiers:
            if mod.type == 'MIRROR':
                bpy.ops.object.modifier_copy_to_selected(modifier=mod.name)
                new_obj.modifiers[-1].name = mod.name+"_Convex"

        #bpy.ops.object.move_to_collection()

    #    bpy.ops.mesh.select_mode(type='FACE')
    #    bpy.ops.mesh.select_all(action='DESELECT')
    #    bpy.ops.object.face_map_select()