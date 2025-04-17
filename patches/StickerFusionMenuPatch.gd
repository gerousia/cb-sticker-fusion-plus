static func patch():
	var script_path = "res://menus/sticker_fusion/StickerFusionMenu.gd"
	var patched_script : GDScript = preload("res://menus/sticker_fusion/StickerFusionMenu.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines: Array = patched_script.source_code.split("\n")
	var code_index: int = 0
	
	code_index = code_lines.find("var exchange: Exchange")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("declare_mod"))
		
	code_index = code_lines.find("func fuse_stickers(a: ItemNode, a_attrib: Array, b: ItemNode, b_attrib: Array) -> ItemNode:")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("init_duplicate_attributes"))

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

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload(true)
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block: String) -> String:
	var code_blocks: Dictionary = {}
	
	code_blocks["declare_mod"] = """
var mod = DLC.mods_by_id["mod_sticker_fusion_plus"]
"""
	
	code_blocks["init_duplicate_attributes"] = """
	var duplicate_attributes: Dictionary = {}
"""
	
	code_blocks["find_duplicate_attributes"] = """
				if mod.is_maxed(attributes[i]):
					output_panel.no_result_text_override = "STICKER_FUSION_MAXED_ATTRIBUTES"
					return null
				if mod.is_upgradeable(attributes[i]):
					duplicate_attributes[attributes[i]] = attributes[j]
					continue
"""
	
	code_blocks["modify_target_attributes"] = """
	for k in duplicate_attributes:
		var _dupe_attr_a = k
		var _dupe_attr_b = duplicate_attributes[k]
		
		if _dupe_attr_a and _dupe_attr_b in attributes:
			mod.upgrade_attribute(attributes, _dupe_attr_a, _dupe_attr_b)
"""

	code_blocks["set_item_attributes"] = """
	output.item.set_attributes(attributes)
"""

	return code_blocks[block]
