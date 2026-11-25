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

	# Telefonul întors: fereastra își schimbă forma, iar pânza o urmează, dacă
	# ecranul de acum o primește. Vezi „PÂNZA ÎN PORTRET" mai jos.
	fereastra.size_changed.connect(_potriveste)


# ─────────────────────────────────────────────────────────────
# PÂNZA ÎN PORTRET
#
# De pe 25 noiembrie 2026. Pe un telefon ținut vertical, pânza de 1152 × 648
# se micșorează după LĂȚIME: 1152 de pixeli înghesuiți în ~390. Un pătrat de
# Sudoku ajungea pe la 14 px, adică mai mic decât în landscape (~25), care era
# deja prea mic pentru un deget. Deci întoarcerea telefonului, singură, strica.
#
# Ce se schimbă e FORMA PÂNZEI, nu mărimea lucrurilor din joc: o pânză îngustă
# (`PANZA_PORTRET`) e micșorată mult mai puțin, deci același pătrat de 42 iese
# pe la 36 px. Niciun `MARIME_CELULA` nu s-a atins pentru asta.
#
# NU SE POATE FORȚA ROTIREA din browser — Safari pe iPhone ignoră blocarea
# orientării, iar Chrome pe Android o îngăduie doar pe tot ecranul. Deci jocul
# se ia după telefon: îl întorci, iar pânza se schimbă. Asta e și varianta mai
# bună: decizia e a mâinii, nu a jocului.
#
# DOAR ECRANELE CARE O PRIMESC. Lupta, harta și meniul sunt așezate pe 1152 de
# pixeli lățime; pe 450 n-ar încăpea, deci rămân pe pânza mare oricum ar sta
# telefonul (adică exact cum arătau înainte). Un ecran care știe să stea îngust
# o spune cu `primeste_portret(true)` și o retrage la plecare. Azi: Taverna,
# pentru sala cu mese și pentru mesele care o declară (`Joc.incape_in_portret`).
#
# PE DESKTOP NU SE ÎNTÂMPLĂ NIMIC: fereastra nu poate fi mai îngustă decât
# pânza (vezi `min_size` de mai sus), deci nu e niciodată verticală. Doar un
# monitor rotit ar aprinde-o — și acolo ar fi chiar ce trebuie.
# ─────────────────────────────────────────────────────────────

## Pânza îngustă. LĂȚIMEA e o măsurătoare, nu o alegere: e cât cere cel mai lat
## lucru care trebuie să încapă (rândul de jos al tastaturii Cuvântului Ascuns,
## 426 px) plus marginile Tavernei în portret. Cu cât e mai îngustă, cu atât
## totul iese mai mare pe telefon; mai îngustă decât asta, tastatura s-ar tăia.
##
## ÎNĂLȚIMEA e o PODEA, nu o mărime: cu `aspect = expand`, pânza se lungește cât
## e ecranul de lung, deci pe un telefon obișnuit are 760-1000 px. Podeaua
## garantează că nici pe unul scund (sau cu bara browserului mare) nu scade sub
## cât cer ecranele, măsurate de `verifica_taverna` pe chiar numărul ăsta.
const PANZA_PORTRET := Vector2i(450, 760)

## Strigat când pânza trece dintr-o formă în alta. Ecranele care se așază
## altfel în portret (Taverna, mesele) îl ascultă.
signal orientare_schimbata(portret: bool)

## Pânza e acum cea îngustă.
var portret := false
## Ecranul de acum știe să stea îngust. Vezi `primeste_portret`.
var _primit := false

## Pentru `verifica_taverna`: -1 = forma o spune fereastra (jocul), 1 = „telefonul
## e ținut vertical", 0 = „e ținut culcat". Fără fereastră (`--headless`) nu
## există un telefon de întors, iar o verificare care ar pune pânza DE MÂNĂ ar
## ocoli exact regula care trebuie bătută: cine o primește, cine o retrage. Așa,
## verificarea minte doar despre forma ferestrei, iar restul drumului e al jocului.
var verticala_simulata := -1


## Spus de ecranul care tocmai s-a deschis (sau de cel care pleacă): „eu pot
## sta îngust" / „eu nu". Pânza se schimbă doar dacă fereastra e chiar verticală.
func primeste_portret(da: bool) -> void:
	_primit = da
	_potriveste()


func _potriveste() -> void:
	_pune(_primit and _e_verticala())


func _e_verticala() -> bool:
	if verticala_simulata >= 0:
		return verticala_simulata == 1
	var marime := get_window().size
	return marime.y > marime.x


## Spus de verificare: „acum telefonul stă așa". Vezi `verticala_simulata`.
func simuleaza_verticala(da: bool) -> void:
	verticala_simulata = 1 if da else 0
	_potriveste()


func _pune(da: bool) -> void:
	if da == portret:
		return
	portret = da
	get_window().content_scale_size = PANZA_PORTRET if da else _dimensiunea_panzei()
	orientare_schimbata.emit(da)
