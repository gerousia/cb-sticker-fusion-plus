const script_path = "res://menus/sticker_fusion/StickerFusionMenu.gd"
const cached_script = preload("res://menus/sticker_fusion/StickerFusionMenu.gd")

static func process(code: String) -> String:
	var output: String = ""
	var code_lines: Array = code.split("\n")
	var code_index: int = 0

	# # #

	code_index = code_lines.find("var exchange: Exchange")
	if code_index >= 0:
		code_lines.insert(code_index + 1, _get_replacement_line("add_variables"))

	code_index = code_lines.find("		exchange.markup_percent = 100 + 100 * output_panel.sticker.item.attributes.size()")
	if code_index >= 0:
		code_lines.insert(code_index + 1, _get_replacement_line("func_update_output"))

	code_index = code_lines.find("func update_fuse_button() -> void :")
	if code_index >= 0:
		code_lines.insert(code_index + 1, _get_replacement_line("func_update_fuse_button"))

	code_index = code_lines.find("""func fuse_stickers(a: ItemNode, a_attrib: Array, b: ItemNode, b_attrib: Array) -> ItemNode:""")
	if code_index >= 0:
		var block_size = 29
		for index in range(block_size - 1, -1, -1):
			code_lines.remove(code_index + index)
		code_lines.insert(code_index, _get_replacement_line("func_fuse_stickers"))

	# # #

	for line in code_lines:
		output += line + "\n"

	return output

static func _get_replacement_line(block: String) -> String:
	var code_blocks: Dictionary = {}
	
	code_blocks["add_variables"] = """
var mod = DLC.mods_by_id["mod_sticker_fusion_plus"]
var duplicate_attributes: Dictionary
"""

	code_blocks["func_update_output"] = """
		exchange.markup_percent += mod.helpers.StickerFusionMenu.get_upgrade_cost(duplicate_attributes)
"""

	code_blocks["func_update_fuse_button"] = """
	$"%FuseButton".text = "STICKER_FUSION_FUSE_UPGRADE_BUTTON" if duplicate_attributes.size() > 0 else "STICKER_FUSION_FUSE_BUTTON"
"""

	code_blocks["func_fuse_stickers"] = """
func fuse_stickers(a: ItemNode, a_attrib: Array, b: ItemNode, b_attrib: Array) -> ItemNode:
	output_panel.no_result_text_override = ""
	
	if not a or not b or not (a.item is StickerItem) or not (b.item is StickerItem):
		return null
	
	output.item = a.item.duplicate()
	
	var attributes: = []
	_add_attributes(attributes, output.item, a.item, a_attrib)
	_add_attributes(attributes, output.item, b.item, b_attrib)
	
	if attributes.size() == 0:
		return null

	duplicate_attributes = {}

	for i in range(attributes.size()):
		var attr_i = attributes[i].get_template()
		for j in range(i + 1, attributes.size()):
			var attr_j = attributes[j].get_template()
			if attr_i == attr_j:
				
				# # # ADD # # #
				if mod.helpers.StickerFusionMenu.is_attribute_capped(attributes[i]):
					duplicate_attributes[attributes[i]] = attributes[j]
					output_panel.no_result_text_override = "STICKER_FUSION_MAXED_ATTRIBUTES"
					return null
				if mod.helpers.StickerFusionMenu.is_attribute_scaleable(attributes[i]):
					duplicate_attributes[attributes[i]] = attributes[j]
					continue
				# # # # # #
				
				output_panel.no_result_text_override = "STICKER_FUSION_DUPLICATE_ATTRIBUTES"
				return null
	
	# # # ADD # # #
	for dupe_attr_a in duplicate_attributes:
		var dupe_attr_b = duplicate_attributes[dupe_attr_a]
		mod.helpers.StickerFusionMenu.merge_attributes(attributes, dupe_attr_a, dupe_attr_b)
	# # # # # #
	
	if attributes.size() > MAX_ATTRIBUTES:
		output_panel.no_result_text_override = "STICKER_FUSION_TOO_MANY_ATTRIBUTES"
		return null
		
	# # # MOVED # # #
	output.item.set_attributes(attributes)
	# # # # # #
	
	return output if output.item else null
"""

	return code_blocks[block]
