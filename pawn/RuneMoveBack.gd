extends Rune

func buff_minion(minion: Minion) -> void:
	minion.move_directions.append(Vector2i(0, -1))
	if Vector2i(1, 1) in minion.move_directions:
		minion.move_directions.append(Vector2i(-1, -1))
		minion.move_directions.append(Vector2i(1, -1))
