extends ContentInfo

const StickerFusionMenu = preload("res://mods/sticker_fusion_upgrade/patches/StickerFusionMenuPatch.gd")
const StickerFusionHelper = preload("res://mods/sticker_fusion_upgrade/scripts/StickerFusionHelper.gd")

func _init():
	StickerFusionMenu.patch()	
