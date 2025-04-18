extends "res://menus/BaseMenu.gd"

const ItemNode = preload("res://global/save_state/ItemNode.gd")
const FusedMaterial = preload("res://data/items/fused_material.tres")

const MAX_ATTRIBUTES = 3

onready var input_panels = [$"%BaseStickerPanel", $"%AttributeSourcePanel"]
onready var output_panel = $"%FusionResultPanel"

var output: ItemNode
var exchange: Exchange

# # # START
var mod = DLC.mods_by_id["mod_sticker_fusion_plus"]
var duplicate_attributes: Dictionary
# # # END

func _ready() -> void :
	output = ItemNode.new()
	add_child(output)
	update_fuse_button()

func grab_focus() -> void :
	$"%BaseStickerPanel".grab_focus()
	update_fuse_button()

func _on_select_sticker_pressed(index: int):
	var items_in_use: = []
	
	for i in range(input_panels.size()):
		if i != index and input_panels[i].sticker:
			items_in_use.push_back(input_panels[i].sticker)
	
	var context: StickerFusionSlot = input_panels[index].slot
	var tab_filter: = ["stickers"]
	var immediate_item_use: = false
	assert (context)
	
	var result = yield(MenuHelper.show_inventory(context, tab_filter, immediate_item_use, items_in_use), "completed")
	if result != null:
		assert (result is Dictionary)
		assert (result.item is ItemNode)
		assert (result.arg == null)
		
		input_panels[index].sticker = result.item
		
		if input_panels[index].slot.is_base_sticker():
			for input_panel in input_panels:
				input_panel.base_sticker = result.item
		
		update_output()
	
	input_panels[index].grab_focus()

func update_output() -> void :
	output_panel.sticker = fuse_stickers(input_panels[0].sticker, input_panels[0].selected_attributes, input_panels[1].sticker, input_panels[1].selected_attributes)
	
	if output_panel.sticker:
		exchange = SimpleExchangeWithMarkup.new()
		exchange.currency = FusedMaterial
		exchange.item = output_panel.sticker.item
		exchange.max_amount = 1
		exchange.markup_percent = 100 + 100 * output_panel.sticker.item.attributes.size()
	else:
		exchange = null
	
	update_fuse_button()

func update_fuse_button() -> void :
	if exchange:
		$"%FuseButton".disabled = false
		$"%CostLabel".bbcode_text = exchange.get_cost_bbcode()
	else:
		$"%FuseButton".disabled = true
		$"%CostLabel".bbcode_text = ""

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
				
				# # #
				if mod.is_maxed(attributes[i]):
					output_panel.no_result_text_override = "STICKER_FUSION_MAXED_ATTRIBUTES"
					return null
				if mod.is_upgradeable(attributes[i]):
					duplicate_attributes[attributes[i]] = attributes[j]
					continue
				# # #
				
				output_panel.no_result_text_override = "STICKER_FUSION_DUPLICATE_ATTRIBUTES"
				return null
	
	# # #
	for k in duplicate_attributes:
		var _dupe_attr_a = k
		var _dupe_attr_b = duplicate_attributes[k]
		
		if _dupe_attr_a and _dupe_attr_b in attributes:
			mod.upgrade_attribute(attributes, _dupe_attr_a, _dupe_attr_b)
	# # #
	
	if attributes.size() > MAX_ATTRIBUTES:
		output_panel.no_result_text_override = "STICKER_FUSION_TOO_MANY_ATTRIBUTES"
		return null
		
	# # #
	output.item.set_attributes(attributes)
	# # #
	
	return output if output.item else null

func _add_attributes(output: Array, target: StickerItem, sticker: StickerItem, attrib_indices: Array) -> void :
	assert (target.battle_move.attribute_profile)
	for index in attrib_indices:
		if index >= sticker.attributes.size():
			continue
		var attrib = sticker.attributes[index]
		if not StickerAttribute.is_compatible_with(attrib, target.battle_move):
			
			
			continue
		output.push_back(attrib)

func _on_selected_attributes_changed():
	update_output()

func _on_FuseButton_pressed():
	if not output_panel.sticker or not exchange:
		return
	
	var new_sticker: StickerItem = output_panel.sticker.item
	assert (new_sticker)
	var currencies: = exchange.get_currencies()
	var prices: = exchange.get_prices()
	
	for i in range(prices.size()):
		if not ExchangeUtil.has_currency(currencies[i], prices[i]):
			return

	for panel in input_panels:
		panel.sticker.consume()
		panel.sticker = null
		panel.base_sticker = null
	update_output()
	
	$"%StickerAudio".play()
	$"%PurchaseAudio".play()
	yield(Co.next_frame(), "completed")
	
	for i in range(prices.size()):
		ExchangeUtil.consume_currency(currencies[i], prices[i])
	
	$"%CurrencyBox".refresh()
	yield(MenuHelper.give_item(new_sticker, 1, false), "completed")
	grab_focus()
	
