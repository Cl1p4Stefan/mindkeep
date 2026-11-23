extends Control
## Icoana paginii PESCUIT din meniu: lună, apă și un crap care sare.
##
## Desenată, nu o imagine: celelalte trei pagini împrumută câte o imagine care
## există deja în joc, iar iazul n-are niciuna. E același desen ca peștii din
## iaz (`Pesti.deseneaza`), deci pagina arată ce găsești dincolo de ea.

func _draw() -> void:
	var c := size / 2.0
	var luna := c + Vector2(size.y * 0.42, -size.y * 0.22)
	draw_circle(luna, 16.0, Color(0.96, 0.90, 0.72, 0.25))
	draw_circle(luna, 11.0, Color(0.96, 0.90, 0.72))
	var apa := c.y + size.y * 0.28
	for i in range(3):
		var y := apa + i * 7.0
		var lat := 70.0 - i * 16.0
		draw_line(Vector2(c.x - lat, y), Vector2(c.x + lat, y), Color(0.32, 0.26, 0.18, 0.75 - i * 0.2), 2.0)
	var crap := Pesti.specie("crap")
	draw_set_transform(c + Vector2(-6, -4), -0.45, Vector2.ONE)
	Pesti.deseneaza(self, crap, Vector2.ZERO, 84.0, true, Color(0.30, 0.22, 0.14, 0.95))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for i in range(4):
		var p := c + Vector2(30 + i * 6, apa - 6 - i * 5)
		draw_circle(p, 2.0, Color(0.32, 0.26, 0.18, 0.6))
