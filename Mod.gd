extends ContentInfo

const PATCHES: Array = [
	preload("res://mods/cb_sticker_fusion_plus/patches/StickerFusionMenuPatch.gd")
]

var helpers: Dictionary = {
	StickerFusionMenu = load("res://mods/cb_sticker_fusion_plus/helpers/StickerFusionHelper.gd"),
}

func _init(): # modified cat_modutils
	for patch in PATCHES:
		var script: GDScript = fetch(patch)
		var code: String = patch.process(read(script))
		write(script, code)

func fetch(patch: GDScript) -> GDScript:
	print("Loading [%s]: \"%s\"" % [PATCHES.find(patch) + 1, patch.resource_path])
	
	if ResourceLoader.has_cached(patch.script_path):
		return ResourceLoader.load(patch.script_path, "GDScript") as GDScript
	
	if patch.cached_script:
		return patch.cached_script

	push_error("Expected cached resource not found: %s" % patch.resource_path)
	return null

func read(script: GDScript) -> String:
	var source_code: String = ""
	var err: int
	
	if script.has_source_code():
		source_code = script.source_code
	else:
		var file: File = File.new()
		if not file.file_exists(script.resource_path):
			push_error("Expected file not found: %s" % script.resource_path)
			return ""
		err = file.open(script.resource_path, File.READ)
		if not err == OK:
			push_error("Failed to open file: %s" % script.resource_path)
			return ""
		source_code = file.get_as_text()
		file.close()

	print("	Replacing: \"%s\"" % script.resource_path)
	return source_code

func write(script: GDScript, code: String) -> void:
	script.source_code = code
	var err: int = script.reload(true)
	if not err == OK:
		push_error("Failed to patch file: %s" % script.resource_path)
		return
	print("	Patch Successful.")
