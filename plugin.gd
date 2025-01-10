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

func _enter_tree():
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
	
