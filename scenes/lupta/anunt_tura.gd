class_name AnuntTura
extends Control
## ANUNȚUL DE TURĂ — banda care trece peste arenă când se schimbă rândul.
##
## ─── CE PROBLEMĂ REZOLVĂ ───────────────────────────────────────
## Lupta are două stări — rândul tău, rândul inamicului — și până acum ecranul
## spunea în care ești numai prin lucruri pe care le ratezi: punctele de PA,
## Obeliscurile care se sting, jurnalul (ascuns în spatele unui buton) și
## marcajul „PARADA!" de pe întrebare, care te prinde când ești DEJA în ea.
## Cel mai rău caz e runda de încărcare a Grabnicului: pe ecran nu se întâmplă
## absolut nimic, iar jocul pare că s-a blocat o jumătate de secundă.
##
## ─── DE CE O BANDĂ ȘI NU UN POPUP CU BUTON ─────────────────────
## Un popup care trebuie închis ar fi fost un clic ceremonial în fiecare rundă —
## exact motivul pentru care butonul „Încheie tura" s-a ascuns („Jocul nu
## trebuie să-mi ceară să confirm că n-am ce face"). Într-o sesiune de 15 minute
## sunt zeci de treceri de tură; un popup le-ar fi făcut pe toate un zid.
## Banda e la fel de mare și de centrată ca un popup, dar nu oprește nimic: nu
## prinde clicuri (`MOUSE_FILTER_IGNORE`) și se stinge singură.
##
## ─── CE NU ȘTIE ────────────────────────────────────────────────
## Nimic despre ture, runde, inamici sau reguli. Primește două texte și o
## culoare și le arată. Cine decide CE scrie pe ea e `lupta.gd`, singura care
## știe al cui e rândul — aceeași despărțire ca la cardul de inamic, unde
## `date_card_inamic()` socotește și `construieste_card()` desenează.
##
## Se naște DIN COD, ca punctele de PA, nu din editor: e un strat de deasupra
## fără nimic de reglat cu ochiul, iar `lupta.gd` o așază singură în arbore
## exact deasupra arenei și sub panourile de jurnal, card și verdict.

## Înălțimea benzii. Două rânduri de text plus aer: titlul mare și detaliul mic.
const INALTIME := 112.0

## Cât ține anunțul, pe trei bucăți. Suma (1,5 s) e tot bugetul de timp al
## unei treceri de tură — iar pentru rândul inamicului ea se adaugă la pauza
## care exista deja (`PAUZA_FINAL_TURA`), nu o înlocuiește: pauza aia e „ai
## terminat", banda e „acum e el".
##
## PAUZA E BUCATA CARE SE REGLEAZĂ, nu intrarea și nu ieșirea. Alea două sunt
## mișcare — o mișcare mai lentă se citește ca o animație leneșă, nu ca un
## anunț care stă mai mult. Pauza e singura în care banda chiar STĂ, la putere
## plină, și e singura pe care o simți ca „am apucat să citesc".
##
## Cât costă, scris pe față: pauza se plătește la FIECARE tură a inamicului,
## unde banda se așteaptă (vezi `tura_inamicului()`). Cu 1 s aici, o trecere
## de tură ajunge la ~2 s cu tot cu `PAUZA_FINAL_TURA` — într-o luptă de 10
## runde, vreo 20 de secunde de treceri. La rândul TĂU nu costă nimic: acolo banda
## nu se așteaptă și oricum se stinge în clipa în care apeși un Obelisc.
const DURATA_INTRARE := 0.25
const DURATA_PAUZA := 1.0
const DURATA_IESIRE := 0.25

## Cât de strânsă pe verticală pleacă banda, și cât se lățește la ieșire.
## Intrarea se DESFĂȘOARĂ (0,45 → 1), ieșirea se destinde puțin peste (1 → 1,08)
## cât se stinge: ochiul citește prima ca „a venit ceva", a doua ca „s-a dus".
const STRANGERE := 0.45
const LARGIRE := 1.08

## Fondul benzii: aproape negru, aproape opac, ca să se citească peste orice
## are arena în spate. Culoarea turei intră în el doar cu un strop
## (`AMESTEC_FOND`) — destul ca plăcuța să fie caldă sau rece, prea puțin ca să
## se bată cu textul, care e singurul lucru de citit.
const CULOARE_FOND := Color(0.05, 0.05, 0.08, 0.88)
const AMESTEC_FOND := 0.12

## Grosimea celor două muchii colorate, sus și jos. Tot ce poartă culoarea
## turei: fără ele banda ar fi o plăcuță neagră la ambele ture.
const MUCHIE := 3

const MARIME_TITLU := 46
const MARIME_DETALIU := 18

## Cât se stinge detaliul față de titlu. Același text la aceeași intensitate ar
## fi fost două titluri; aici titlul spune starea, detaliul o lămurește.
const STINGERE_DETALIU := 0.30

var _banda: Panel
var _stil: StyleBoxFlat
var _eticheta_titlu: Label
var _eticheta_detaliu: Label
var _tween: Tween = null

## Al câtelea anunț e cel care rulează acum. Două anunțuri lipite (o tură care
## se încheie singură imediat, de pildă) înseamnă două corutine `arata()` în
## aer; fără contorul ăsta, coada celei vechi ar ascunde banda celei noi.
var _generatie := 0


func _ready() -> void:
	# Stratul nu prinde niciun clic: Obeliscurile de dedesubt rămân apăsabile,
	# iar banda nu devine o fereastră modală pe furiș.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	modulate.a = 0.0

	_stil = StyleBoxFlat.new()
	_stil.bg_color = CULOARE_FOND
	_stil.border_width_top = MUCHIE
	_stil.border_width_bottom = MUCHIE

	# Banda se întinde pe toată lățimea și stă CENTRATĂ pe verticală, peste
	# arenă. Ancore explicite, nu un container: așa are un dreptunghi cunoscut,
	# iar `pivot_offset` (de care are nevoie scalarea) se poate calcula din el.
	_banda = Panel.new()
	_banda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banda.anchor_left = 0.0
	_banda.anchor_right = 1.0
	_banda.anchor_top = 0.5
	_banda.anchor_bottom = 0.5
	_banda.offset_top = -INALTIME / 2.0
	_banda.offset_bottom = INALTIME / 2.0
	_banda.add_theme_stylebox_override("panel", _stil)
	# Pivotul se pune la fiecare reașezare, nu o dată: scalarea trebuie să
	# pornească din MIJLOCUL benzii, iar mijlocul se mută când se schimbă
	# lățimea ferestrei. Legat de semnal, nu calculat într-un `_process`, ca să
	# se întâmple exact când se schimbă ceva.
	_banda.resized.connect(_recentreaza_pivotul)
	add_child(_banda)

	var coloana := VBoxContainer.new()
	coloana.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coloana.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	coloana.alignment = BoxContainer.ALIGNMENT_CENTER
	coloana.add_theme_constant_override("separation", 2)
	_banda.add_child(coloana)

	_eticheta_titlu = Label.new()
	_eticheta_titlu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_eticheta_titlu.add_theme_font_size_override("font_size", MARIME_TITLU)
	coloana.add_child(_eticheta_titlu)

	_eticheta_detaliu = Label.new()
	_eticheta_detaliu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_eticheta_detaliu.add_theme_font_size_override("font_size", MARIME_DETALIU)
	coloana.add_child(_eticheta_detaliu)


func _recentreaza_pivotul() -> void:
	_banda.pivot_offset = _banda.size / 2.0


## ARATĂ ANUNȚUL și se întoarce când s-a stins.
##
## E o corutină, deci apelantul alege singur: `await` pentru rândul inamicului
## (acolo banda ESTE pauza dinaintea loviturii), fără `await` pentru rândul tău
## (acolo n-ai de ce să aștepți — poți apăsa un Obelisc peste ea).
##
## `intarziere` e cât se stă pe loc ÎNAINTE ca banda să intre; 0 (implicit) =
## pe loc. Cât ține, pe ecran nu e nimic — nici măcar banda la opacitate zero.
## O folosește un singur apelant, deschiderea luptei: vezi
## `INTARZIERE_PRIMA_BANDA` din `lupta.gd`. Parametru, nu o constantă aici,
## fiindcă e o decizie despre RITMUL LUPTEI (când intră anunțul în raport cu
## deschiderea arenei), nu despre cum se mișcă banda — iar banda nu știe ce e
## o luptă. O întârziere anulată între timp (`ascunde_acum()`, sau alt anunț)
## nu mai apare deloc: contorul de generație o prinde și la trezire.
##
## AȘTEPTAREA MERGE PE CRONOMETRU, nu pe `_tween.finished`, dinadins: un tween
## omorât de `ascunde_acum()` nu mai emite niciodată `finished`, deci un
## `await` pe el ar putea îngheța tura inamicului pe vecie. Un cronometru se
## declanșează orice se întâmplă cu animația.
func arata(titlu: String, detaliu: String, culoare: Color, intarziere := 0.0) -> void:
	_generatie += 1
	var a_mea := _generatie

	if intarziere > 0.0:
		await get_tree().create_timer(intarziere).timeout
		# Între timp s-a cerut alt anunț, sau banda a fost stinsă. Atunci anunțul
		# ăsta nu mai are de ce să apară: ieșim ÎNAINTE să scriem ceva pe bandă,
		# nu după — altfel am fi lăsat textul nostru peste al celui care e acum
		# pe ecran.
		if a_mea != _generatie:
			return

	_eticheta_titlu.text = titlu
	_eticheta_titlu.add_theme_color_override("font_color", culoare)
	_eticheta_detaliu.text = detaliu
	_eticheta_detaliu.visible = detaliu != ""
	_eticheta_detaliu.add_theme_color_override(
		"font_color", culoare.darkened(STINGERE_DETALIU)
	)
	_stil.border_color = culoare
	_stil.bg_color = CULOARE_FOND.lerp(culoare, AMESTEC_FOND)
	# `lerp` ia și canalul alfa al culorii primite (care e 1), deci fondul s-ar
	# fi opacizat cu fiecare anunț. Transparența e a FONDULUI, nu a turei.
	_stil.bg_color.a = CULOARE_FOND.a

	_opreste_tween()
	visible = true
	modulate.a = 0.0
	_recentreaza_pivotul()
	_banda.scale = Vector2(1.0, STRANGERE)

	_tween = create_tween()
	_tween.tween_property(_banda, "scale", Vector2.ONE, DURATA_INTRARE) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.parallel().tween_property(self, "modulate:a", 1.0, DURATA_INTRARE)
	_tween.tween_interval(DURATA_PAUZA)
	_tween.tween_property(self, "modulate:a", 0.0, DURATA_IESIRE) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_tween.parallel().tween_property(_banda, "scale", Vector2(1.0, LARGIRE), DURATA_IESIRE)

	await get_tree().create_timer(
		DURATA_INTRARE + DURATA_PAUZA + DURATA_IESIRE
	).timeout

	# A pornit alt anunț între timp? Atunci banda e a lui, nu a mea.
	if a_mea == _generatie:
		visible = false


## Stinge anunțul PE LOC, fără animație. Pentru momentele în care ecranul se
## schimbă din alt motiv: se deschide panoul cu o întrebare, sau lupta se
## resetează. O bandă rămasă să se stingă peste o întrebare care tocmai a
## apărut ar acoperi exact primul rând al ei.
func ascunde_acum() -> void:
	_generatie += 1
	_opreste_tween()
	visible = false
	modulate.a = 0.0


func _opreste_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
