extends Node

var has_pda : bool = false
var has_flashlight : bool = false

var _desired_props : Array = []

func _ready():
	var props = self.get_property_list()
	for prop in props:
		# To find out the datatype, use the GDScript's typeof() function.
		# Bool type = 1 | Int type = 2 | Float type = 3
		if prop["type"] == 1:
			_desired_props.append(prop)

func reset():
	for prop in _desired_props:
		var name = prop["name"]
		self[name] = false
