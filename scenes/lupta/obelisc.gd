class_name Obelisc
extends Button
## BUTONUL UNUI OBELISC: piesa de șah, numele disciplinei, bordura ei, halo-ul
## din spate și cele trei reacții — hover, apăsare, blocat.
##
## ─────────────────────────────────────────────────────────────
## DE CE O SCENĂ SEPARATĂ, ȘI NU TREI BUTOANE ÎN `lupta.tscn`
##
## Aceeași regulă ca la Obeliscuri în general și ca la panoul de verdict: un
## contract, mai multe conținuturi. Cele trei butoane au FORMĂ identică și
## diferă prin trei valori (nume, piesă, culoare). Scrise de trei ori în scena
## de luptă, orice schimbare de formă de mâine — alt colț, alt halo, o stare
## nouă — s-ar fi făcut de trei ori, iar a treia oară s-ar fi uitat.
##
## Aici, un Obelisc nou e un rând în tabelul `OBELISCURI` din `lupta.gd`.
##
## DE CE RĂDĂCINA E TOT UN `Button`, deși nu i se vede nimic din înfățișare:
## `Button` aduce gratis tot ce e greu și plictisitor — zona de click, hover-ul,
## `disabled`, semnalul `pressed`, navigarea cu tastatura. Noi îi stingem doar
## hainele implicite (`StyleBoxEmpty` pe toate stările) și desenăm altele peste.
## `lupta.gd` nu observă nicio diferență: conectează `pressed` ca înainte.
##
## ─────────────────────────────────────────────────────────────
## CUM E ÎMPĂRȚITĂ MUNCA
##
##   Aura   (Panel)   — halo-ul moale din spate; singurul lucru pentru care un
##                      `StyleBoxFlat` e mai bun decât desenul nostru (umbre).
##   Fata   (Control) — fondul cu degrade, colțurile, bordura (`fata_obelisc.gd`)
##   Glifa  (Control) — piesa de șah desenată (`glifa_sah.gd`)
##   Lacat  (Control) — semnul de blocat (`lacat.gd`)
##
## Toate stau într-un `Continut` care NU e butonul: containerul din luptă
## repoziționează butonul la fiecare așezare a interfeței, deci o ridicare
## aplicată butonului însuși ar fi ștearsă. `Continut` e liber să se miște.

# ─────────────────────────────────────────────────────────────
# REGLAJE
# ─────────────────────────────────────────────────────────────
## Cu câți pixeli se ridică butonul la hover. 3 e pragul de la care ochiul
## sesizează mișcarea fără s-o citească drept „butonul a sărit".
const RIDICARE := 3.0

## Cât rămâne ridicat cât timp e ținut apăsat. Nu 0 și nu negativ: apăsarea îl
## coboară cu 2px față de hover, deci se simte împins, nu aruncat la loc.
const RIDICARE_APASAT := 1.0

## Duratele celor două mișcări. Hover-ul are voie să fie lin (e o schimbare de
## stare); apăsarea trebuie să pară CAUZATĂ de degetul tău, deci aproape
## instantanee. Peste ~0.1 s, o apăsare începe să pară o animație.
const DURATA_HOVER := 0.14
const DURATA_APASARE := 0.06

## Halo-ul piesei (vezi `glifa_sah.gd`) în repaus și la hover.
const GLOW_PIESA := 0.45
const GLOW_PIESA_HOVER := 0.95

## Halo-ul din spatele butonului: cât se întinde în afara lui, în pixeli, și cu
## ce transparență. În repaus e aproape doar o adiere care desprinde butonul de
## fundal; la hover devine ce anunță „ăsta e sub mouse".
const UMBRA := 7
const UMBRA_HOVER := 15
const ALFA_UMBRA := 0.14
const ALFA_UMBRA_HOVER := 0.32

## Cât de stins e butonul cât timp nu-l poți folosi (n-ai PA, e un puzzle
## deschis, lupta s-a terminat, Obeliscul e blocat). Transparență, nu gri:
## așa se stinge TOT butonul deodată — și piesa, și halo-ul, și bordura — spre
## fondul arenei, în loc să fie nevoie de o a doua culoare pentru fiecare.
const ALFA_INDISPONIBIL := 0.42

## Cât de ștearsă e piesa pe un Obelisc BLOCAT, peste stingerea de mai sus.
## Blocat e mai mult decât indisponibil: „nu acum" vs. „nu runda asta".
const ALFA_PIESA_BLOCATA := 0.30

## Raza colțurilor. Aceeași valoare ca în `fata_obelisc.gd` și ca la panourile
## din restul luptei — halo-ul trebuie să aibă exact forma feței, altfel iese
## un colț luminos în afara butonului.
const RAZA_COLT := 12

# ─────────────────────────────────────────────────────────────
# STARE
# ─────────────────────────────────────────────────────────────
## Obeliscul e blocat până la finalul rundei (ai greșit la el)?
## Nu îl setezi direct — vine prin `seteaza_stare()`, împreună cu disponibilitatea.
var blocat := false

## Culoarea disciplinei. Sursa tuturor culorilor butonului.
var culoare := Color(0.6, 0.85, 1.0)

var _sub_mouse := false
var _apasat := false
var _tween: Tween = null
var _stil_aura: StyleBoxFlat = null

@onready var continut: Control = %Continut
@onready var aura: Panel = %Aura
@onready var fata: FataObelisc = %Fata
@onready var glifa: GlifaSah = %Glifa
@onready var eticheta: Label = %Nume
@onready var lacat: Lacat = %Lacat
@onready var imagine: TextureRect = %Imagine


func _ready() -> void:
	# Hainele implicite ale butonului, stinse. `StyleBoxEmpty` = „nu desena
	# nimic": fondul gri al temei ar fi stat sub fața noastră și i-ar fi
	# stricat colțurile rotunjite cu propriile lui colțuri drepte.
	for stare in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(stare, StyleBoxEmpty.new())

	# Halo-ul. Stilul e construit din cod fiindcă depinde de culoarea
	# disciplinei, care vine din tabel — și fiecare buton primește EXEMPLARUL
	# LUI: un stil comun ar face ca hover-ul pe un buton să aprindă toate trei.
	_stil_aura = StyleBoxFlat.new()
	_stil_aura.corner_radius_top_left = RAZA_COLT
	_stil_aura.corner_radius_top_right = RAZA_COLT
	_stil_aura.corner_radius_bottom_right = RAZA_COLT
	_stil_aura.corner_radius_bottom_left = RAZA_COLT
	_stil_aura.shadow_size = UMBRA
	aura.add_theme_stylebox_override("panel", _stil_aura)

	mouse_entered.connect(_pe_intrare)
	mouse_exited.connect(_pe_iesire)
	button_down.connect(_pe_apasare)
	button_up.connect(_pe_ridicare)

	_aplica_culoarea()
	_asaza_acum()


## Ce face butonul ăsta. Chemată o dată, din `lupta.gd`, cu un rând din tabelul
## `OBELISCURI`. Numele, piesa și culoarea nu se mai schimbă niciodată după —
## de-aia sunt aici și nu în `actualizeaza_ui()`, care rulează de zeci de ori
## pe rundă.
## `cale_imagine` e opțională: dacă fișierul există, Obeliscul arată ARTA — altfel
## rămâne pe piesa desenată. Deci poți scrie calea în tabel înainte să existe
## fișierul: până îl pui în proiect, butonul merge mai departe cu desenul.
func configureaza(
	nume: String,
	piesa: GlifaSah.Piesa,
	culoare_disciplina: Color,
	cale_imagine := ""
) -> void:
	culoare = culoare_disciplina
	# `@onready` se completează abia când scena intră în arbore, iar `lupta.gd`
	# poate să ne cheme înainte de asta. `is_node_ready()` ne spune dacă
	# nodurile există deja; dacă nu, le așteptăm — un cadru, o singură dată.
	if not is_node_ready():
		await ready
	eticheta.text = nume
	glifa.piesa = piesa
	_pune_imaginea(cale_imagine)
	_aplica_culoarea()
	_asaza_acum()


## Pune arta peste piesa desenată, dacă există.
##
## Culoarea NU se atinge aici — o pune `_aplica_culoarea()`, fiindcă depinde și de
## starea butonului (un Obelisc blocat își stinge și piesa). Aici doar aducem
## fișierul și decidem cine se vede: imaginea sau desenul.
func _pune_imaginea(cale: String) -> void:
	if cale == "" or not ResourceLoader.exists(cale):
		if cale != "":
			push_warning("Obelisc: lipseste %s — raman pe piesa desenata." % cale)
		imagine.visible = false
		glifa.doar_aura = false
		return

	imagine.texture = load(cale)
	imagine.visible = true
	# Piesa desenată se retrage, dar nodul ei rămâne: el ține halo-ul.
	glifa.doar_aura = true


## Singura ușă prin care `lupta.gd` schimbă cum arată butonul.
##
## Două steaguri, nu unul, fiindcă sunt două lucruri diferite:
##   `blocat_acum`   — ai greșit la Obeliscul ăsta; e mort până la runda viitoare
##   `indisponibil`  — nu-l poți apăsa ACUM (fără PA, puzzle deschis, luptă gata)
## Un Obelisc blocat e mereu și indisponibil, dar nu și invers — iar lacătul
## trebuie să apară doar în primul caz, altfel ar spune că ai greșit de fiecare
## dată când rămâi fără PA.
func seteaza_stare(blocat_acum: bool, indisponibil: bool) -> void:
	blocat = blocat_acum
	disabled = indisponibil
	if disabled:
		# Nu mai ești „sub mouse" pe un buton pe care nu-l poți apăsa: altfel
		# ar rămâne ridicat și aprins, promițând ceva ce nu se întâmplă.
		_sub_mouse = false
		_apasat = false
	_aplica_culoarea()
	_asaza_acum()


# ─────────────────────────────────────────────────────────────
# CULORILE — ce nu se animă
# ─────────────────────────────────────────────────────────────

## Împrăștie culoarea disciplinei în toate piesele butonului. Chemată doar când
## se schimbă ceva ce ține de culoare (configurare, blocare), nu în fiecare cadru.
func _aplica_culoarea() -> void:
	if not is_node_ready():
		return

	fata.culoare = culoare
	_stil_aura.shadow_color = Color(culoare, ALFA_UMBRA)

	# Fondul văzut prin tăieturile piesei și prin gaura lacătului. Aceeași
	# formulă ca în `fata_obelisc.gd`, ca să nu se vadă o treaptă de culoare.
	var fond := FataObelisc.fond(culoare)

	# Trupul aurei, în culoarea FONDULUI, nu în cea a disciplinei.
	#
	# Aura stă sub fața butonului, care o acoperă complet — deci, logic, culoarea
	# ei n-ar trebui să conteze deloc. Contează exact într-un caz, și s-a văzut
	# imediat: când Obeliscul e indisponibil, TOT conținutul devine semi-
	# transparent (`ALFA_INDISPONIBIL`), fața inclusiv. Cu trupul aurei albastru
	# aprins, butonul blocat nu se stingea — se ALBEA, fiindcă prin fața devenită
	# translucidă se vedea culoarea de dedesubt.
	#
	# Cu fondul aici, n-are ce se vedea prin ea: aura devine ce trebuia să fie de
	# la început — doar o umbră colorată în jurul butonului.
	_stil_aura.bg_color = fond
	glifa.culoare_gol = fond
	lacat.culoare_gol = fond

	# Numele: culoarea disciplinei, dusă spre alb ca să rămână TEXT, nu decor.
	# Bordura și piesa sunt deja colorate; dacă și numele ar fi pur colorat,
	# butonul ar avea trei accente și niciun conținut.
	eticheta.add_theme_color_override("font_color", culoare.lerp(Color.WHITE, 0.55))

	# Piesa. Pe un Obelisc blocat e ștearsă și fără halo — semnul principal că
	# unealta nu mai e a ta runda asta. Lacătul doar confirmă.
	glifa.culoare = Color(culoare, ALFA_PIESA_BLOCATA if blocat else 1.0)

	# IMAGINEA, colorată cu aceeași culoare ca bordura și numele.
	#
	# `modulate` înmulțește fiecare pixel cu culoarea dată. Pe o piesă GRI asta
	# înseamnă exact ce vrem: griul deschis devine albastru deschis, griul închis
	# devine albastru închis — volumul și umbrele rămân, se schimbă doar nuanța.
	# (Pe o imagine deja colorată ar fi ieșit noroi; de-aia arta se generează gri.)
	#
	# Fișierul de pe disc rămâne neatins: colorarea trăiește doar în joc, deci
	# aceeași imagine poate servi mâine altă disciplină, cu altă culoare.
	imagine.modulate = Color(culoare, ALFA_PIESA_BLOCATA if blocat else 1.0)
	lacat.visible = blocat
	lacat.culoare = culoare.lerp(Color.WHITE, 0.3)


# ─────────────────────────────────────────────────────────────
# MIȘCAREA — ce se animă
# ─────────────────────────────────────────────────────────────

## Unde trebuie să ajungă butonul, după starea lui de acum.
## O singură funcție care răspunde la „cum arăt eu?", folosită și de animație,
## și de așezarea instantanee — deci cele două nu pot ajunge niciodată în
## dezacord (bug-ul clasic: hover-ul animă spre o valoare, iar resetarea pune
## alta, și butonul rămâne cu un halo pe care nu-l mai stinge nimeni).
func _tinta() -> Dictionary:
	var aprins := _sub_mouse and not disabled
	return {
		"ridicare": -(RIDICARE_APASAT if _apasat else (RIDICARE if aprins else 0.0)),
		"evidentiere": 1.0 if aprins else 0.0,
		"glow": (GLOW_PIESA_HOVER if aprins else GLOW_PIESA) if not blocat else 0.0,
		"umbra": UMBRA_HOVER if aprins else UMBRA,
		"alfa_umbra": ALFA_UMBRA_HOVER if aprins else ALFA_UMBRA,
		"alfa": ALFA_INDISPONIBIL if disabled else 1.0,
	}


## Sare direct la starea țintă, fără animație. Pentru momentele în care nu e
## nimic de arătat: prima așezare, o schimbare de stare venită din luptă.
func _asaza_acum() -> void:
	if not is_node_ready():
		return
	_opreste_tweenul()
	var tinta := _tinta()
	continut.position.y = tinta["ridicare"]
	fata.evidentiere = tinta["evidentiere"]
	fata.apasat = _apasat
	glifa.glow = tinta["glow"]
	_stil_aura.shadow_size = tinta["umbra"]
	_stil_aura.shadow_color = Color(culoare, tinta["alfa_umbra"])
	continut.modulate.a = tinta["alfa"]


## Alunecă spre starea țintă. `durata` e scurtă la apăsare și lină la hover.
func _animeaza(durata: float) -> void:
	if not is_node_ready():
		return
	_opreste_tweenul()
	var tinta := _tinta()
	fata.apasat = _apasat   # comutare, nu animație: e un fel de a desena, nu o mișcare

	# `set_parallel(true)` = toate pornesc odată. Ridicarea, aprinderea feței,
	# halo-ul piesei și cel al butonului sunt UN singur gest văzut din patru
	# părți; pornite pe rând, s-ar vedea ca patru efecte.
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(continut, "position:y", tinta["ridicare"], durata)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(fata, "evidentiere", tinta["evidentiere"], durata)
	_tween.tween_property(glifa, "glow", tinta["glow"], durata)
	_tween.tween_property(_stil_aura, "shadow_size", tinta["umbra"], durata)
	_tween.tween_property(_stil_aura, "shadow_color", Color(culoare, tinta["alfa_umbra"]), durata)
	_tween.tween_property(continut, "modulate:a", tinta["alfa"], durata)


func _opreste_tweenul() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()


func _pe_intrare() -> void:
	if disabled:
		return
	_sub_mouse = true
	_animeaza(DURATA_HOVER)


func _pe_iesire() -> void:
	_sub_mouse = false
	# Degetul poate pleca de pe buton cu butonul mouse-ului încă apăsat.
	# Fără linia asta, butonul ar rămâne „apăsat" pentru totdeauna.
	_apasat = false
	_animeaza(DURATA_HOVER)


func _pe_apasare() -> void:
	_apasat = true
	_animeaza(DURATA_APASARE)


func _pe_ridicare() -> void:
	_apasat = false
	# Nu presupunem că ne întoarcem în hover: între apăsare și ridicare s-a
	# deschis deja panoul cu întrebarea, iar butonul a devenit indisponibil.
	# `_tinta()` știe asta; noi doar cerem „du-te unde trebuie acum".
	_animeaza(DURATA_APASARE)
