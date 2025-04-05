@tool
extends EditorPlugin

# The new node type to be added
const humanizer_node = preload('res://addons/humanizer_author/scripts/humanizer_editor_tool.gd')
# Its icon in the scene tree
const node_icon = preload('res://addons/humanizer/icon.png')
# Editor inspectors 
var humanizer_inspector = HumanizerEditorInspectorPlugin.new()
var human_randomizer_inspector = HumanRandomizerInspectorPlugin.new()
var humanizer_material_inspector = HumanizerMeshInstanceInspectorPlugin.new()

#only called in the editor, so it wont interfere with main plugin loading in game
func _enter_tree():
	#zip loading doesnt work - just extract the zips to the res://humanizer directory
	HumanizerRegistry.load_all()
	## then load assets from zips, use the resource loader to cache.. may be a problem if you have too many assets
	#for path in ProjectSettings.get_setting_with_override("addons/humanizer/asset_import_paths"):
		#var file_list = OSPath.get_files_recursive(path)
		#for file_path in file_list:
			#if file_path.get_extension() == "zip":
				##why doesnt this work?
				#ProjectSettings.load_resource_pack(file_path) 
				##also tried using zip reader but HOW do you turn packedbytearray into resource ??
				
	# Add editor inspector plugins
	add_inspector_plugin(humanizer_inspector)
	add_inspector_plugin(human_randomizer_inspector)
	add_inspector_plugin(humanizer_material_inspector)
	# Add custom humanizer node
	add_custom_type('Humanizer', 'Node3D', humanizer_node, node_icon)


func _exit_tree():
	remove_inspector_plugin(humanizer_inspector)
	remove_inspector_plugin(human_randomizer_inspector)
	remove_inspector_plugin(humanizer_material_inspector)
	
