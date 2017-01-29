PrefabFiles = {
  "smartfertilizer",
}

Assets = {

  Asset( "IMAGE", "images/inventoryimages/fertilize.tex" ),
  Asset( "ATLAS", "images/inventoryimages/fertilize.xml" ),

}

GLOBAL.STRINGS.NAMES.SMARTFERTILIZER = "SmartFertilizer"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SMARTFERTILIZER = "easy"
GLOBAL.STRINGS.RECIPE_DESC.SMARTFERTILIZER = "for lazy farmer"

local smartfertilizer = GLOBAL.Recipe("smartfertilizer", {Ingredient("twigs", 2),Ingredient("flint", 2)}, GLOBAL.RECIPETABS.TOOLS, GLOBAL.TECH.NONE)
smartfertilizer.atlas = "images/inventoryimages/fertilize.xml"
smartfertilizer.image = "fertilize.tex"
