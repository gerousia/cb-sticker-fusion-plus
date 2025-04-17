extends Resource

func is_upgradable(attribute: StickerAttribute) -> bool:
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

func upgrade_attribute(target_attrib: StickerAttribute, donor_attrib: StickerAttribute) -> void:
	if target_attrib.get("chance_max"):
		var high = max(target_attrib.chance, donor_attrib.chance)
		var low = min(target_attrib.chance, donor_attrib.chance)
		var new = ceil(high + (low * 0.10 * 2))
		target_attrib.chance = clamp(new, target_attrib.chance_min, target_attrib.chance_max)  
	if target_attrib.get("stat_value_max"):
		var high = max(target_attrib.stat_value, donor_attrib.stat_value)
		var low = min(target_attrib.stat_value, donor_attrib.stat_value)
		var new = ceil(high + (low * 0.10 * 2))
		target_attrib.stat_value = clamp(new, target_attrib.stat_value_min, target_attrib.stat_value_max)