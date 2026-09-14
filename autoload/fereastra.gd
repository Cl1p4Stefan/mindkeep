extends Node
## PAZNICUL FERESTREI — se asigură că fereastra nu scade sub pânza de desen.
##
## E un „autoload" (Project → Project Settings → Autoload), ca `Muzica` și
## `Sunet`: pornește o dată, înaintea oricărei scene, și rămâne în picioare
## până la închiderea jocului. Aici asta contează, pentru că regula pe care o
## impune e o proprietate a FERESTREI, nu a unei scene — dacă ar sta în
## `lupta.gd`, s-ar pierde în clipa în care apare harta de expediție.
##
## ─────────────────────────────────────────────────────────────
## DE CE EXISTĂ FIȘIERUL ĂSTA
##
## Proiectul are o „pânză de desen" de 1152×648 (Project Settings → Display →
## Window → Viewport Width/Height). Toate dimensiunile din scene — font 14,
## `custom_minimum_size = 190` — sunt măsurate în pixelii ACELEI pânze.
## Modul de întindere `canvas_items` ia pânza și o potrivește peste fereastra
## reală, cu un factor de scalare.
##
## Factorul ăsta nu e simetric, și asta e toată povestea:
##
##   fereastră MAI MARE (factor > 1)  →  Godot REDESENEAZĂ literele la
##       dimensiunea mare. Textul rămâne tăios la orice mărime. Verificat:
##       la 1920×1080 (factor 1.67) e impecabil.
##
##   fereastră MAI MICĂ (factor < 1)  →  literele sunt desenate o dată la 14px
##       și apoi MICȘORATE de placa video. Un „A" de 14 pixeli înghesuit în 11
##       pixeli nu mai are din ce să-și facă liniile. Verificat: la 922×518
##       (factor 0.8) cuvintele se lipesc între ele.
##
## Nu e o setare greșită undeva — e limita fizică a micșorării. Singura apărare
## reală e să nu ajungi niciodată sub factorul 1. De-aia dimensiunea minimă a
## ferestrei = exact dimensiunea pânzei.
##
## ─────────────────────────────────────────────────────────────
## CE NU REZOLVĂ
##
## Doar fereastra ADEVĂRATĂ a jocului. Când apeși Play în Godot 4.4+, editorul
## încorporează jocul într-un panou („Game"), îi impune dimensiunea panoului și
## ignoră regula asta. Dacă textul arată prost acolo dar bine în jocul rulat
## separat, ăla e panoul, nu jocul — vezi nota din `docs/progres.md`.


## Pânza de desen, citită din setările proiectului în loc să fie scrisă aici cu
## mâna. Dacă schimbi vreodată Viewport Width/Height, regula se mută singură
## după ea; două numere copiate în două locuri s-ar desincroniza exact în ziua
## în care ai uita de fișierul ăsta.
func _dimensiunea_panzei() -> Vector2i:
	return Vector2i(
		int(ProjectSettings.get_setting("display/window/size/viewport_width", 1152)),
		int(ProjectSettings.get_setting("display/window/size/viewport_height", 648)),
	)


func _ready() -> void:
	var fereastra := get_window()
	var panza := _dimensiunea_panzei()

	# Plasa de siguranță: pe un ecran mai mic decât pânza (un laptop vechi, sau
	# un monitor rotit), o dimensiune minimă mai mare decât ecranul ar da o
	# fereastră pe care n-o mai poți apuca de bară ca s-o muți. Mai bine text
	# moale decât fereastră de neatins, deci coborâm minimul la cât încape.
	#
	# `get_usable_rect` e zona fără bara de start, nu tot ecranul — exact
	# suprafața în care o fereastră poate sta întreagă.
	var utilizabil := DisplayServer.screen_get_usable_rect(
		DisplayServer.window_get_current_screen()
	).size

	fereastra.min_size = Vector2i(
		mini(panza.x, utilizabil.x),
		mini(panza.y, utilizabil.y),
	)
