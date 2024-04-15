extends Rune

func buff_minion(minion: Minion) -> void:
	minion.attack_reach.append(Vector2i(0, -1))
	if Vector2i(1, 1) in minion.attack_reach:
		minion.attack_reach.append(Vector2i(-1, -1))
		minion.attack_reach.append(Vector2i(1, -1))
