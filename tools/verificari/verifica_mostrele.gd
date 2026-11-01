extends Node
## MOSTRELE DE LOGICA — cate o intrebare din fiecare tipar, de citit cu ochiul.
##
##   godot --headless --path . res://tools/verificari/verifica_mostrele.tscn
##
## NU DA VERDICTE si nu iese cu cod de eroare, ca si `verifica_coltul`: ce
## masoara ea e singurul lucru pe care un script nu-l poate judeca.
## `verifica_logica` bate forma (patru variante, raspunsul recalculat, enigma
## rezolvata); aici se vede ACORDUL si daca propozitia suna a romaneste. „Emil e
## calugarita" trece orice verificare automata si e totusi gresit.
##
## Se ruleaza cand se atinge un generator sau cand se adauga un cuvant in
## `data/logica_vocabular.json` — adica exact atunci cand gramatica se poate
## strica fara ca nimic sa se plangă.

const LOGICA := preload("res://scenes/logica/logica.gd")


func _ready() -> void:
	LOGICA.incarca_date()
	var scena = LOGICA.new()
	for generator in LOGICA.GENERATOARE:
		var q: Dictionary = scena.call(generator["metoda"])
		var ocol := 0
		while q.is_empty() and ocol < 20:
			q = scena.call(generator["metoda"])
			ocol += 1
		if q.is_empty():
			print("\n[%s] %s — NU A IESIT" % [generator["tip"], generator["metoda"]])
			continue
		print("\n[%s · %s] %s" % [generator["tip"], generator["categorie"], generator["metoda"]])
		print(q["text"])
		for i in range(q["variante"].size()):
			print("   %s %s" % ["(*)" if i == int(q["corect"]) else "( )", q["variante"][i]])
		print("   > %s" % q["explicatie"])
	scena.free()
	get_tree().quit(0)
