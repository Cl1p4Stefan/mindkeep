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
##
## ─────────────────────────────────────────────────────────────
## ÎNFĂȚIȘAREA — aceeași bibliotecă și același pergament ca în Practice
##
## Meniul poartă tema `assets/tema/pergament.tres` pe rădăcină, ca Practice,
## deci nicio culoare și niciun font nu sunt scrise aici: fiecare etichetă își
## ia rolul din `theme_type_variation` (`TitluMeniu`, `TitluPergament`,
## `ButonRubrica`…). Fundalul e biblioteca din luptă prin același shader
## (`fundal_estompat.gdshader`), dar ABIA estompată: aici nu se citește un
## paragraf peste ea, deci are voie să se vadă ca loc.
##
## Cele două moduri sunt două PAGINI una lângă alta, nu două butoane una sub
## alta: o răscruce se vede ca două drumuri. Fiecare pagină are o imagine care
## există deja în joc — figurina de pe hartă și creierul din chenarul de
## Practice — ca să recunoști ecranul în care intri înainte să intri.
##
## Mișcarea e puțină, dinadins (meniul îl vezi în fiecare zi):
##   - o intrare de sub o secundă (voal care se ridică, pagini care apar);
##   - pagina cu focus se ridică puțin. Mouse-ul MUTĂ focusul (`grab_focus` la
##     survolare), deci e mereu o singură pagină ridicată, oricum ai umbla —
##     cu săgețile sau cu mouse-ul;
##   - praf în lumina vitraliului (`Praf`, particule pe procesor, fără nicio
##     imagine nouă în proiect: firul e un gradient rotund generat de Godot).

const SCENA_HARTA := "res://scenes/harta/harta.tscn"
const SCENA_PRACTICE := "res://scenes/practice/practice.tscn"

@onready var buton_expeditie: Button = %ButonExpeditie
@onready var buton_practice: Button = %ButonPractice
@onready var expeditie_stare: Label = %ExpeditieStare
@onready var avertisment: Label = %Avertisment
@onready var antet: Control = %Antet
@onready var ornament: Control = %Ornament
@onready var carte_expeditie: Control = %CarteExpeditie
@onready var carte_practice: Control = %CartePractice
@onready var praf: CPUParticles2D = %Praf
@onready var voal: ColorRect = %Voal

## Cât se ridică pagina cu focus. Puțin: e un semn, nu o animație.
const RIDICARE := 1.035
## Culoarea ornamentului de sub titlu: cea a subtitlului (`AntetSecundar`).
const CULOARE_ORNAMENT := Color(0.82, 0.74, 0.58, 0.85)


func _ready() -> void:
	buton_expeditie.pressed.connect(_pe_expeditie)
	buton_practice.pressed.connect(_pe_practice)
	_leaga_pagina(buton_expeditie, carte_expeditie)
	_leaga_pagina(buton_practice, carte_practice)
	ornament.draw.connect(_deseneaza_ornament)
	resized.connect(_aseaza_praful)
	_aseaza_praful()
	_arata_starea_save_ului()
	Muzica.reda(Muzica.Piesa.CETATE)
	_intrare()
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
# MIȘCAREA
# ─────────────────────────────────────────────────────────────

## Intrarea: voalul întunecat se ridică, antetul și paginile apar pe rând.
##
## Se animă `modulate`, NU `position`: antetul și paginile stau în containere,
## iar un container își rearanjează copiii ori de câte ori se schimbă ceva
## (fereastra, un text) și ar șterge orice poziție pusă de mână în mijlocul
## animației. Culoarea n-o atinge.
func _intrare() -> void:
	voal.show()
	voal.modulate.a = 1.0
	antet.modulate.a = 0.0
	for carte in [carte_expeditie, carte_practice]:
		carte.modulate.a = 0.0

	var t := create_tween().set_parallel(true)
	t.tween_property(voal, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_OUT)
	t.tween_property(antet, "modulate:a", 1.0, 0.6).set_delay(0.1)
	var intarziere := 0.3
	for carte in [carte_expeditie, carte_practice]:
		t.tween_property(carte, "modulate:a", 1.0, 0.45).set_delay(intarziere)
		intarziere += 0.12
	# Voalul nu mai are ce face după ce s-a ridicat; ascuns, nu mai costă nimic
	# la desenare.
	t.chain().tween_callback(voal.hide)


## Leagă butonul de pagina lui: focusul ridică pagina, survolarea mută focusul.
func _leaga_pagina(buton: Button, carte: Control) -> void:
	buton.mouse_entered.connect(buton.grab_focus)
	buton.focus_entered.connect(_ridica.bind(carte, RIDICARE))
	buton.focus_exited.connect(_ridica.bind(carte, 1.0))
	# Scara crește din CENTRUL paginii, nu din colțul stânga-sus (implicit).
	# Mărimea paginii se știe abia după aranjare, deci centrul se mută odată
	# cu ea.
	carte.resized.connect(func() -> void: carte.pivot_offset = carte.size / 2.0)


## `scale` pe un copil de container e voie: containerul îi pune poziția și
## mărimea, dar scara n-o atinge, deci pagina se ridică fără să-și împingă
## vecina.
func _ridica(carte: Control, scara: float) -> void:
	var t := carte.create_tween()
	t.tween_property(carte, "scale", Vector2.ONE * scara, 0.16) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Praful plutește peste tot ecranul, deci zona lui se ia după fereastră.
func _aseaza_praful() -> void:
	praf.position = size / 2.0
	praf.emission_rect_extents = size / 2.0


## Linia de sub titlu: două fire care se sting spre capete și un romb la mijloc,
## desenate, nu scrise — un caracter decorativ (✦, ❧) ar depinde de ce glife
## are fontul.
func _deseneaza_ornament() -> void:
	var mijloc := ornament.size / 2.0
	var lungime := 170.0
	var pasi := 24
	for latura in [-1.0, 1.0]:
		for i in pasi:
			var a := mijloc + Vector2(latura * (14.0 + lungime * i / pasi), 0)
			var b := mijloc + Vector2(latura * (14.0 + lungime * (i + 1) / pasi), 0)
			var culoare := CULOARE_ORNAMENT
			culoare.a *= 1.0 - float(i) / pasi
			ornament.draw_line(a, b, culoare, 1.5, true)
	var r := 5.0
	var romb := PackedVector2Array([
		mijloc + Vector2(0, -r), mijloc + Vector2(r, 0),
		mijloc + Vector2(0, r), mijloc + Vector2(-r, 0)])
	ornament.draw_colored_polygon(romb, CULOARE_ORNAMENT)


# ─────────────────────────────────────────────────────────────
# CE SPUNE MENIUL DESPRE SAVE
# ─────────────────────────────────────────────────────────────

## Butonul și cele două rânduri, din starea citită de `Arhiva` la pornire.
func _arata_starea_save_ului() -> void:
	if Expeditie.activa:
		buton_expeditie.text = "Continuă expediția"
		# Sămânța nu mai stă pe ecran: e un număr pentru unelte, nu pentru
		# jucător. O tipărește consola, pentru când trebuie reprodus un run.
		expeditie_stare.text = "%s în urmă  ·  %d / %d PV" % [
			_noduri(Expeditie.parcurse.size()), Expeditie.pv, Expeditie.pv_max]
		expeditie_stare.visible = true
		print("Meniu: expeditie in curs, samanta %d" % Expeditie.samanta)

	var randuri := _randuri_de_avertisment()
	avertisment.visible = not randuri.is_empty()
	avertisment.text = "\n".join(randuri)


## „1 nod", „2 noduri", „20 de noduri" — româna pune „de" de la 20 în sus
## (și la 120, 1000…: la tot ce nu se termină în 01-19).
func _noduri(n: int) -> String:
	if n == 1:
		return "1 nod"
	var rest := n % 100
	if n < 20 or (rest >= 1 and rest <= 19):
		return "%d noduri" % n
	return "%d de noduri" % n


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
		randuri.append("Expediția salvată nu s-a putut citi. A fost pusă deoparte.")
	return randuri
