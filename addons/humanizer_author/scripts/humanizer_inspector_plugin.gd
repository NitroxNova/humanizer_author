class_name HumanizerEditorInspectorPlugin
extends EditorInspectorPlugin

func _can_handle(human):
	return human is HumanizerEditorTool
	
func _parse_category(human, category):
	if not Engine.is_editor_hint():
		return
	if category != 'humanizer_editor_tool.gd':
		return
	
	#print("humanizer inspector plugin - parsing category")
	var scene = load("res://addons/humanizer_author/scenes/humanizer_inspector.tscn").instantiate()
	add_custom_control(scene)
	
	# Header Section
	scene.get_node('%ResetButton').pressed.connect(human.reset)
	#scene.get_node('%PresetsOptionButton').human = human

	## Color pickers
	scene.get_node('%SkinColorPicker').color = human.human_config.skin_color
	scene.get_node('%HairColorPicker').color = human.human_config.hair_color
	scene.get_node('%EyeColorPicker').color = human.human_config.eye_color
	scene.get_node('%EyebrowColorPicker').color = human.human_config.eyebrow_color
	scene.get_node('%SkinColorPicker').color_changed.connect(human.set_skin_color)
	scene.get_node('%EyeColorPicker').color_changed.connect(human.set_eye_color)
	var eyebrow_color_picker = scene.get_node('%EyebrowColorPicker')
	eyebrow_color_picker.color_changed.connect(human.set_eyebrow_color)
	scene.get_node('%HairColorPicker').color_changed.connect(hair_color_changed.bind(human,eyebrow_color_picker))
	
	# Components Inspector
	scene.get_node('%MainColliderCheckBox').button_pressed = &'main_collider' in human.human_config.components
	scene.get_node('%RagdollCheckBox').button_pressed = &'ragdoll' in human.human_config.components
	scene.get_node('%RootBoneCheckBox').button_pressed = &'root_bone' in human.human_config.components
	scene.get_node('%LODCheckBox').button_pressed = &'lod' in human.human_config.components
	scene.get_node('%SaccadesCheckBox').button_pressed = &'saccades' in human.human_config.components
	scene.get_node('%AgeMorphsCheckBox').button_pressed = &'age_morphs' in human.human_config.components
	scene.get_node('%SizeMorphsCheckBox').button_pressed = &'size_morphs' in human.human_config.components
	scene.get_node('%MainColliderCheckBox').toggled.connect(human.set_component_state.bind(&'main_collider'))
	scene.get_node('%RagdollCheckBox').toggled.connect(human.set_component_state.bind(&'ragdoll'))
	scene.get_node('%RootBoneCheckBox').toggled.connect(human.set_component_state.bind(&'root_bone'))
	scene.get_node('%LODCheckBox').toggled.connect(human.set_component_state.bind(&'lod'))
	scene.get_node('%SaccadesCheckBox').toggled.connect(human.set_component_state.bind(&'saccades'))
	scene.get_node('%AgeMorphsCheckBox').toggled.connect(human.set_component_state.bind(&'age_morphs'))
	scene.get_node('%SizeMorphsCheckBox').toggled.connect(human.set_component_state.bind(&'size_morphs'))

	## Baking section
	scene.get_node('%AddShapekeyButton').pressed.connect(human.add_shapekey)
	scene.get_node('%ShapekeyName').text = human.new_shapekey_name
	scene.get_node('%ShapekeyName').text_changed.connect(func(value: String): human.new_shapekey_name = value)
	scene.get_node('%SelectAllButton').pressed.connect(human.set_bake_meshes.bind(&'All'))
	scene.get_node('%SelectOpaqueButton').pressed.connect(human.set_bake_meshes.bind(&'Opaque'))
	scene.get_node('%SelectTransparentButton').pressed.connect(human.set_bake_meshes.bind(&'Transparent'))
	scene.get_node('%StandardBakeButton').pressed.connect(human.standard_bake)
	scene.get_node('%SurfaceName').text = human.bake_surface_name
	scene.get_node('%SurfaceName').text_changed.connect(func(value: String): human.bake_surface_name = value)
	scene.get_node('%BakeSurfaceButton').pressed.connect(human.bake_surface)
	scene.get_node('%HumanName').text_changed.connect(func(value: String): human.human_name = value)
	scene.get_node('%SaveButton').pressed.connect(human.save_human_scene)
	scene.get_node('%HumanName').text = human.human_name

	## Assets
	scene.get_node('%RigOptionButton').human = human
	scene.get_node('%HideClothesVerticesButton').pressed.connect(human.hide_clothes_vertices)
	scene.get_node('%UnHideClothesVerticesButton').pressed.connect(human.unhide_clothes_vertices)
	
	#Equipment inspectors
	for category_id in ProjectSettings.get_setting_with_override("addons/humanizer/slots"):
		var category_dict : Dictionary = ProjectSettings.get_setting_with_override("addons/humanizer/slots")[category_id]
		var button = Button.new()
		var container = ClothesInspector.new()
		button.text = category_id
		button.pressed.connect(toggle_equipment.bind(container))
		container.visible = false
		var grid = GridContainer.new()
		grid.name = "GridContainer"
		container.add_child(grid)
		container.custom_minimum_size.y = 300
		container.category = category_id		
		scene.get_node('%Equipment').add_child(button)
		scene.get_node('%Equipment').add_child(container)
		grid.owner = container
		container.clothes_changed.connect(human.add_equipment_type)
		container.clothes_cleared.connect(human.remove_equipment_in_slot)
		container.material_set.connect(human.set_equipment_texture_by_name)
		container.overlay_added.connect(human.add_overlay)
		container.overlay_removed.connect(human.remove_overlay)
		container.config = human.human_config
		
	# Add shapekey categories and sliders
	var sliders = HumanizerTargetService.get_shapekey_categories()
	var cat_scene = HumanizerResourceService.load_resource("res://addons/humanizer_author/scenes/slider_category_inspector.tscn")
	for cat in sliders:
		if sliders[cat].size() == 0:
			continue
		sliders[cat].sort()
		var button = Button.new()
		button.text = cat
		button.name = cat + 'Button'
		var cat_container = cat_scene.instantiate()
		cat_container.name = cat + 'Container'
		cat_container.visible = false
		cat_container.shapekeys = sliders[cat]
		cat_container.human = human
		scene.get_node('%ShapekeysVBoxContainer').add_child(button)
		scene.get_node('%ShapekeysVBoxContainer').add_child(cat_container)
		button.pressed.connect(func(): cat_container.visible = not cat_container.visible)

func toggle_equipment(container:Container):
	container.visible = not container.visible

func hair_color_changed(color:Color, human, eyebrow_color_picker):
	human.humanizer.set_hair_color(color)
	eyebrow_color_picker.color = human.human_config.eyebrow_color
