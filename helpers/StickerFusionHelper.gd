static func is_attribute_capped(attribute: StickerAttribute) -> bool:
	for field in ["chance", "stat_value"]:
		if attribute.get(field + "_max"):
			return attribute[field] == attribute[field + "_max"]

	return false

static func is_attribute_scaleable(attribute: StickerAttribute) -> bool:
	return attribute.get("chance_max") or attribute.get("stat_value_max")

static func merge_attributes(attributes: Array, attr_a: StickerAttribute, attr_b: StickerAttribute) -> void:
	if attributes.size() <= 0:
		return
	if not attributes.has(attr_a) and attributes.has(attr_b):
		return
	if not attr_a.get_template() == attr_b.get_template():
		return

	var attr_a_index = attributes.find(attr_a)
	var replacement = _copy_attribute(attributes[attr_a_index])

	for field in ["chance", "stat_value"]:
		var min_key = field + "_min"
		var max_key = field + "_max"
		
		if replacement.get(max_key):
			replacement[field] = _get_scale_value(
				min(attr_a[field], attr_b[field]),
				max(attr_a[field], attr_b[field]),
				replacement[min_key],
				replacement[max_key]
			)

	attributes[attr_a_index] = replacement
	attributes.erase(attr_b)	

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

	for attr_a in duplicates:
		var attr_b = duplicates[attr_a]
		
		for field in ["chance", "stat_value"]:
			var min_key = field + "_min"
			var max_key = field + "_max"
			
			if attr_a.get(max_key):
				var scaled_value = _get_scale_value(
					min(attr_a[field], attr_b[field]),
					max(attr_a[field], attr_b[field]),
					attr_a[min_key],
					attr_a[max_key]
				)
				var scaled_factor = _get_scale_factor(scaled_value, attr_a.get("rarity"), attr_a.get(max_key))
				cost += int(_get_interval_value(scaled_factor) * 0.5) # # # Too Expensive
 
	return 100 * cost

static func _get_scale_value(low: float, high: float, min_value: float, max_value: float, rate: float = 0.5) -> float:
	var formula = ceil(high + (low * (1 - high / max_value)) * rate) # # # Non-Linear Growth
	return clamp(formula, min_value, max_value)
	
static func _get_scale_factor(value: float, rarity: int, max_value: float) -> float:
	return 100 * (value / max_value) * rarity
	
static func _get_interval_value(value: float, interval: float = 20.0) -> float:
	return ceil(value / interval) if value >= 0.0 else 0.0
