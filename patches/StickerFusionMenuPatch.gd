static func patch():
	var script_path = "res://menus/sticker_fusion/StickerFusionMenu.gd"
	var patched_script: GDScript = preload("res://menus/sticker_fusion/StickerFusionMenu.gd")

	if !patched_script.has_source_code():
		var file: File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines: Array = patched_script.source_code.split("\n")
	var code_index: int = 0

	# # # var

	code_index = code_lines.find("var exchange: Exchange")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("init_mod"))
		
	code_index = code_lines.find("var exchange: Exchange")
	if code_index >= 0:
		code_lines.insert(code_index + 2, get_code("init_duplicate_attributes"))

	# # # func fuse_stickers

	code_index = code_lines.find("	output.item = a.item.duplicate()")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("reset_duplicate_attributes"))

	code_index = code_lines.find("	output.item.set_attributes(attributes)")
	if code_index >= 0:
		code_lines.remove(code_index)
	
	code_index = code_lines.find("			if attr_i == attr_j:")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("find_duplicate_attributes"))
		
	code_index = code_lines.find("	if attributes.size() > MAX_ATTRIBUTES:")
	if code_index >= 0:
		code_lines.insert(code_index, get_code("modify_target_attributes"))
	
	code_index = code_lines.find("	if attributes.size() > MAX_ATTRIBUTES:")
	if code_index >= 0:
		code_lines.insert(code_index + 3, get_code("set_item_attributes"))
	
	# # # func update_output

	code_index = code_lines.find("		exchange.markup_percent = 100 + 100 * output_panel.sticker.item.attributes.size()")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("markup_percent_multiplier"))

	# # # func update_fuse_button

	code_index = code_lines.find("""		$"%CostLabel".bbcode_text = exchange.get_cost_bbcode()""")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("fuse_button_text"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload(true)
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block: String) -> String:
	var code_blocks: Dictionary = {}
	
	# # # var

	code_blocks["init_mod"] = """
var mod = DLC.mods_by_id["mod_sticker_fusion_upgrade"]
"""
	
	code_blocks["init_duplicate_attributes"] = """
var duplicate_attributes: Dictionary
"""

	# # # func fuse_stickers

	code_blocks["reset_duplicate_attributes"] = """
	duplicate_attributes = {}
"""
	
	code_blocks["find_duplicate_attributes"] = """
				if mod.StickerFusionHelper.is_attribute_capped(attributes[i]):
					duplicate_attributes[attributes[i]] = attributes[j]
					output_panel.no_result_text_override = "STICKER_FUSION_MAXED_ATTRIBUTES"
					return null
				if mod.StickerFusionHelper.is_attribute_scaleable(attributes[i]):
					duplicate_attributes[attributes[i]] = attributes[j]
					continue
"""
	
	code_blocks["modify_target_attributes"] = """
	for dupe_attr_a in duplicate_attributes:
		var dupe_attr_b = duplicate_attributes[dupe_attr_a]
		mod.StickerFusionHelper.merge_attributes(attributes, dupe_attr_a, dupe_attr_b)
"""

	code_blocks["set_item_attributes"] = """
	output.item.set_attributes(attributes)
"""

	# # # func update_output

	code_blocks["markup_percent_multiplier"] = """
		exchange.markup_percent += mod.StickerFusionHelper.get_upgrade_cost(duplicate_attributes)
"""

	# # # func update_fuse_button

	code_blocks["fuse_button_text"] = """
		$"%FuseButton".text = "STICKER_FUSION_FUSE_UPGRADE_BUTTON" if duplicate_attributes.size() > 0 else "STICKER_FUSION_FUSE_BUTTON"
"""

	return code_blocks[block]
