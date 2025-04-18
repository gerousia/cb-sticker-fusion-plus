extends ContentInfo

const StickerFusionHelper = preload("res://mods/sticker_fusion_plus/scripts/StickerFusionHelper.gd")
const StickerFusionMenuPatch = preload("res://mods/sticker_fusion_plus/patches/StickerFusionMenuPatch.gd")

func _init():
	StickerFusionMenuPatch.patch()
