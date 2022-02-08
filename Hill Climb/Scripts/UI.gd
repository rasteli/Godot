extends CanvasLayer

var coin_amount = 0

func add_coins(amount):
	coin_amount += amount
	$Coin/Label.text = str(coin_amount)

func update_fuel(value):
	$Fuel/ProgressBar.value = value
	var stylebox_fg = $Fuel/ProgressBar.get("custom_styles/fg")
	stylebox_fg.bg_color.h = lerp(0, 0.3, value / 100)
