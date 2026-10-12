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

## ─────────────────────────────────────────────────────────────
## CELE DOUĂ LUCRURI PE CARE LE CITEȘTE DE PE DISC — ȘI DE CE NU-L STRICĂ
##
## De la Save (pasul 8), meniul se uită la două lucruri și scrie două rânduri:
##
##   1. DACĂ E UN RUN ÎN CURS, butonul scrie „Continua expeditia", cu un rând
##      dedesubt despre unde ai rămas. E o CITIRE a stării, nu o decizie despre
##      ecranul de după: harta își alege singură ecranul, exact ca până acum, și
##      ar fi arătat harta oricum. Fără rândul ăsta, apeși „Expeditie"
##      așteptând un loadout și aterizezi în mijlocul unui run — iar primul
##      lucru pe care l-ai crede e că jocul a uitat să-ți dea alegerea.
##
##   2. DACĂ UN FIȘIER DE SAVE A FOST PUS DEOPARTE (nu s-a putut citi), se
##      spune. Un progres pierdut în tăcere arată exact ca „n-am jucat
##      niciodată" — iar fișierul e încă pe disc, deci merită să afli că e
##      acolo. `Arhiva` ține FAPTUL („permanent" → „JSON invalid, linia 3");
##      fraza se face aici, fiindcă un fișier care nu știe ce e un Fragment
##      n-are de ce să știe cum se vorbește cu jucătorul.
##
## Ce NU face în continuare: nu hotărăște nimic. Nu încarcă save-ul (`Arhiva`
## l-a citit la pornire, înaintea oricărei scene), nu-l șterge, nu întreabă
## harta nimic.

const SCENA_HARTA := "res://scenes/harta/harta.tscn"
const SCENA_PRACTICE := "res://scenes/practice/practice.tscn"

@onready var buton_expeditie: Button = %ButonExpeditie
@onready var buton_practice: Button = %ButonPractice
@onready var expeditie_rol: Label = %ExpeditieRol
@onready var avertisment: Label = %Avertisment


func _ready() -> void:
	buton_expeditie.pressed.connect(_pe_expeditie)
	buton_practice.pressed.connect(_pe_practice)
	_arata_starea_save_ului()
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


# ─────────────────────────────────────────────────────────────
# CE SPUNE MENIUL DESPRE SAVE
# ─────────────────────────────────────────────────────────────

## Butonul și cele două rânduri, din starea citită de `Arhiva` la pornire.
func _arata_starea_save_ului() -> void:
	if Expeditie.activa:
		buton_expeditie.text = "Continua expeditia"
		expeditie_rol.text = "%d noduri in urma, %d / %d PV. Pornita cu samanta %d." % [
			Expeditie.parcurse.size(), Expeditie.pv, Expeditie.pv_max, Expeditie.samanta]

	var randuri := _randuri_de_avertisment()
	avertisment.visible = not randuri.is_empty()
	avertisment.text = "\n".join(randuri)


## Fraza pentru fiecare fișier pus deoparte.
##
## Cele două fișiere primesc DOUĂ mesaje diferite, fiindcă pierderile sunt
## diferite: un run întrerupt e o seară, progresul permanent sunt toate serile.
## Un singur mesaj pentru amândouă ar fi spus mai puțin decât știm.
##
## Motivul tehnic („JSON invalid, linia 3") NU intră în frază: pe ecran e
## zgomot, iar în consolă e deja scris de `Arhiva`, cu tot cu numele fișierului
## pus deoparte.
func _randuri_de_avertisment() -> Array[String]:
	var randuri: Array[String] = []
	if Arhiva.stricate.has("permanent"):
		randuri.append("Progresul salvat nu s-a putut citi. A fost pus deoparte.")
	if Arhiva.stricate.has("expeditie"):
		randuri.append("Expeditia salvata nu s-a putut citi. A fost pusa deoparte.")
	return randuri
