
Assets = {
    Asset("IMAGE", "images/inventoryimages/packagewand.tex"),
    Asset("ATLAS", "images/inventoryimages/packagewand.xml"),
}

PrefabFiles = {
	"packagewand",
	"packagething",
}

GLOBAL.STRINGS.NAMES.PACKAGEWAND = "Package Wand"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PACKAGEWAND = "make your home better"
GLOBAL.STRINGS.RECIPE_DESC.PACKAGEWAND = "can pack structures"

-- add to recipes
local packagewand = GLOBAL.Recipe("packagewand", {Ingredient("twigs", 2),Ingredient("redgem", 2), Ingredient("livinglog",2)}, GLOBAL.RECIPETABS.TOOLS, GLOBAL.TECH.NONE)
packagewand.atlas = "images/inventoryimages/packagewand.xml"
packagewand.image = "packagewand.tex"