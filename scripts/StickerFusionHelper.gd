static func is_attribute_capped(attribute: StickerAttribute) -> bool:
	if attribute.get("chance_max"):
		return attribute.chance == attribute.chance_max
	if attribute.get("stat_value_max"):
		return attribute.stat_value == attribute.stat_value_max

	return false

static func is_attribute_scaleable(attribute: StickerAttribute) -> bool:
	return attribute.get("chance_max") or attribute.get("stat_value_max")

static func upgrade_attribute(attributes: Array, attrib_a: StickerAttribute, attrib_b: StickerAttribute) -> void:
	if attributes.size() <= 0:
		return

	if not attributes.has(attrib_a) or not attributes.has(attrib_b):
		return

	if attrib_a.get_template() != attrib_b.get_template():
		return

	var index = attributes.find(attrib_a)
	var upgraded_attribute = _copy_attribute(attributes[index])

	if upgraded_attribute.get("chance_max"):
		upgraded_attribute.chance = _get_scale_value(
			min(attrib_a.chance, attrib_b.chance),
			max(attrib_a.chance, attrib_b.chance),
			upgraded_attribute.chance_min,
			upgraded_attribute.chance_max
		)

	if upgraded_attribute.get("stat_value_max"):
		upgraded_attribute.stat_value = _get_scale_value(
			min(attrib_a.stat_value, attrib_b.stat_value),
			max(attrib_a.stat_value, attrib_b.stat_value),
			upgraded_attribute.stat_value_min,
			upgraded_attribute.stat_value_max
		)

	attributes[index] = upgraded_attribute
	attributes.erase(attrib_b)	

static func _copy_attribute(attribute: StickerAttribute) -> Resource:
	var output = attribute.duplicate()
	
	output.template_path = attribute.template_path
	if attribute.get("stat_value_max"):
		output.stat_value = attribute.stat_value
	if attribute.get("chance_max"):    
		output.chance = attribute.chance
	if attribute.get("buff") != null:
		output.buff = attribute.buff
		output.amount = attribute.amount
	if attribute.get("debuff") != null:
		output.debuff = attribute.debuff
		output.amount = attribute.amount
	return output;

static func get_upgrade_cost_multiplier(attributes: Dictionary) -> int:
	var cost: int = 0

	for k in attributes:
		var attr_a = k
		var attr_b = attributes[k]

		var weight: float = 0
		var factor: float = 0

		if attr_a.get("chance_max"):
			weight = _get_scale_value(
				min(attr_a.chance, attr_b.chance),
				max(attr_a.chance, attr_b.chance),
				attr_a.chance_min, 
				attr_a.chance_max
			)
			factor = _get_scale_factor(weight, attr_a.get("chance_max"))

		if attr_a.get("stat_value_max"):
			weight = _get_scale_value(
				min(attr_a.stat_value, attr_b.stat_value),
				max(attr_a.stat_value, attr_b.stat_value),
				attr_a.stat_value_min,
				attr_a.stat_value_max
			)
			factor = _get_scale_factor(weight, attr_a.get("stat_value_max"))

		cost += _snap_to_cost_interval(factor)

	return cost

static func _snap_to_cost_interval(factor: float) -> int:
	if factor < 0:
		return 0
	return int(ceil(factor / 20.0))

static func _get_scale_value(low: float, high: float, min_value: float, max_value: float) -> float:
	return clamp(ceil(high + (low * 0.10 * 2)), min_value, max_value)
	
static func _get_scale_factor(value: float, max_value: float) -> float:
	return ceil(100 * value / max_value)
