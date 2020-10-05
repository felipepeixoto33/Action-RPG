extends Resource

class_name Item

#Principal
export(String) var name = null
export(Texture) var texture
export(String) var description = null
export(String, "Other", "Equipament") var itemType
export(int, "None", "Helmet", "Armor", "Legs", "Boots", "Sword", "Shield") var equipmentType
var amount = 1


#Damage & Armor

#Damage
export(int) var damage

export(int, "Piercing", "Blunt", "Slash", "None") var damageType = null 
export(int, "Piercing", "Blunt", "Slash", "None") var secondDamageType = null 
#Physical Damage Types:
#1 -> Piercing
#2 -> Blunt
#3 -> Slash

#Armor
export(int) var armor

#Heal & Cure
export(int) var healPoints
export(String) var cure
