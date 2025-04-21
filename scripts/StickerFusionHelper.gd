static func is_attribute_capped(attribute: StickerAttribute) -> bool:
	for field in ["chance", "stat_value"]:
		if attribute.get(field + "_max"):
			return attribute[field] == attribute[field + "_max"]

	return false

static func is_attribute_scaleable(attribute: StickerAttribute) -> bool:
	return attribute.get("chance_max") or attribute.get("stat_value_max")

static func merge_attributes(attributes: Array, attrib_a: StickerAttribute, attrib_b: StickerAttribute) -> void:
	if attributes.size() <= 0:
		return
	if not attributes.has(attrib_a) and attributes.has(attrib_b):
		return
	if not attrib_a.get_template() == attrib_b.get_template():
		return

	var attrib_a_index = attributes.find(attrib_a)
	var replacement = _copy_attribute(attributes[attrib_a_index])

	for field in ["chance", "stat_value"]:
		var min_key = field + "_min"
		var max_key = field + "_max"
		
		if replacement.get(max_key):
			replacement[field] = _get_scale_value(
				min(attrib_a[field], attrib_b[field]),
				max(attrib_a[field], attrib_b[field]),
				replacement[min_key],
				replacement[max_key]
			)

	attributes[attrib_a_index] = replacement
	attributes.erase(attrib_b)	

static func _copy_attribute(attribute: StickerAttribute) -> Resource:
	var output = attribute.duplicate()	
	output.template_path = attribute.template_path
		
	for field in ["chance", "stat_value"]:
		if attribute.get(field + "_max"):
			output[field] = attribute[field]

	for field in ["buff", "debuff"]:
		if attribute.get(field) != null:
			output[field] = attribute[field]
			output.amount = attribute.amount

	return output;

static func get_upgrade_cost(duplicates: Dictionary) -> int:
	var cost: int = 0

	for attrib_a in duplicates:
		var attrib_b = duplicates[attrib_a]
		
		for field in ["chance", "stat_value"]:
			var min_key = field + "_min"
			var max_key = field + "_max"
			
			if attrib_a.get(max_key):
				var scaled_value = _get_scale_value(
					min(attrib_a[field], attrib_b[field]),
					max(attrib_a[field], attrib_b[field]),
					attrib_a[min_key],
					attrib_a[max_key]
				)
				var scaled_factor = _get_scale_factor(scaled_value, attrib_a.get(max_key))
				cost += int(_get_interval_value(scaled_factor))

	return 100 * cost

static func _get_scale_value(low: float, high: float, min_value: float, max_value: float, multiplier: float = 0.20) -> float:
	return clamp(ceil(high + (low * multiplier)), min_value, max_value)
	
static func _get_scale_factor(value: float, max_value: float) -> float:
	return ceil(100 * value / max_value)
	
static func _get_interval_value(value: float, interval: float = 20.0) -> float:
	return ceil(value / interval) if value >= 0.0 else 0.0
