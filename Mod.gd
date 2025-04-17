extends ContentInfo

#const StickerFusionHelper = preload("res://mods/sticker_fusion_plus/scripts/StickerFusionHelper.gd")
const StickerFusionMenuPatch = preload("res://mods/sticker_fusion_plus/patches/StickerFusionMenuPatch.gd")

func _init():
	StickerFusionMenuPatch.patch()

func is_upgradeable(attribute: StickerAttribute) -> bool:
	if attribute.get("chance_max"):
		return attribute.chance < attribute.chance_max
	if attribute.get("stat_value_max"):
		return attribute.stat_value < attribute.stat_value_max

	return false
	
func is_maxed(attribute: StickerAttribute) -> bool:
	if attribute.get("chance_max"):
		return attribute.chance == attribute.chance_max
	if attribute.get("stat_value_max"):
		return attribute.stat_value == attribute.stat_value_max

	return false

func upgrade_attribute(output: Array, target: StickerAttribute, donor: StickerAttribute) -> void:
	if output.size() <= 0:
		return

	if not output.has(target) or not output.has(donor):
		return

	var _index = output.find(target)
	var _replacement = _copy_attribute(output[_index])

	var _high: float = 0.0
	var _low: float = 0.0
	var _change: float = 1.0

	if target.get("chance_max"):
		_high = max(target.chance, donor.chance)
		_low = min(target.chance, donor.chance)
		_change = ceil(_high + (_low * 0.10 * 2))
		_replacement.chance = clamp(_change, _replacement.chance_min, _replacement.chance_max)

	if target.get("stat_value_max"):
		_high = max(target.stat_value, donor.stat_value)
		_low = min(target.stat_value, donor.stat_value)
		_change = ceil(_high + (_low * 0.10 * 2))
		_replacement.stat_value = clamp(_change, _replacement.stat_value_min, _replacement.stat_value_max)

	output.erase(donor)
	output[_index] = _replacement

static func _copy_attribute(target: StickerAttribute) -> Resource:
	var output = target.duplicate()
	
	output.template_path = target.template_path
	if target.get("stat_value_max"):
		output.stat_value = target.stat_value
	if target.get("chance_max"):    
		output.chance = target.chance
	if target.get("buff") != null:
		output.buff = target.buff
		output.amount = target.amount
	if target.get("debuff") != null:
		output.debuff = target.debuff
		output.amount = target.amount
	return output;
