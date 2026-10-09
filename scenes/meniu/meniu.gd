extends Control
## MENIUL DE START — prima ușă a jocului.
##
## De azi, ăsta e `run/main_scene` din `project.godot`, adică ce apare la F5.
##
## ─────────────────────────────────────────────────────────────
## DE CE E ATÂT DE SUBȚIRE, ȘI DE CE TREBUIE SĂ RĂMÂNĂ
##
## Un meniu de start e locul în care se adună, pe nesimțite, logica tuturor
## celorlalte ecrane: „dacă ai un save, scrie Continuă", „dacă n-ai deblocat
## Turnul, ascunde butonul", „dacă expediția e în curs, du-l direct acolo".
## Fiecare din astea e o decizie care APARȚINE ecranului de după, nu meniului —
## iar un meniu care le adună devine singurul fișier pe care trebuie să-l
## deschizi ca să înțelegi orice.
##
## Deci regula fișierului ăsta: el ÎNCARCĂ o scenă și nu știe nimic despre ce
## se întâmplă în ea. Harta își alege singură ecranul (loadout, hartă sau
## sumar) în `_ready`-ul ei, din starea lui `Expeditie`, exact ca până acum —
## faptul că cineva a apăsat un buton înainte nu schimbă nimic acolo. Tocmai
## de-aia `harta.tscn` și `lupta.tscn` pornesc în continuare singure cu F6.
##
## ─────────────────────────────────────────────────────────────
## MUZICA
##
## `CETATE` — piesa liniștită, cea care e deja „casa" jocului. `HARTA` ar fi
## promis o expediție din meniu, iar `LUPTA` ar fi fost o minciună. Când
## meniul își va merita piesa proprie, aia e un rând în `enum Piesa` și un rând
## în `PIESE` (vezi `autoload/muzica.gd`), nimic altceva.
##
## Și nu se oprește la plecare: `Muzica.reda()` face singur tranziția lină spre
## piesa scenei următoare. Un `opreste()` aici ar tăia sunetul în clipa
## clickului și ar reporni de la zero dincolo.

const SCENA_HARTA := "res://scenes/harta/harta.tscn"
const SCENA_PRACTICE := "res://scenes/practice/practice.tscn"

@onready var buton_expeditie: Button = %ButonExpeditie
@onready var buton_practice: Button = %ButonPractice


func _ready() -> void:
	buton_expeditie.pressed.connect(_pe_expeditie)
	buton_practice.pressed.connect(_pe_practice)
	Muzica.reda(Muzica.Piesa.CETATE)
	# Focusul pe primul buton, ca meniul să se poată umbla cu tastatura
	# (săgeți + Enter) fără să atingi mouse-ul. Aceeași grijă ca la variantele
	# din `puzzle.gd`.
	buton_expeditie.grab_focus()


func _pe_expeditie() -> void:
	# `change_scene_to_file` schimbă scena la finalul cadrului curent, deci e
	# sigur de chemat din semnalul unui buton: nodul care a strigat nu e distrus
	# în timp ce încă rulează codul lui.
	get_tree().change_scene_to_file(SCENA_HARTA)


func _pe_practice() -> void:
	get_tree().change_scene_to_file(SCENA_PRACTICE)
