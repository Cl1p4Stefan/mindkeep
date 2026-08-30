extends Control
## Scena de luptă — PROTOTIP cu placeholder-e.
## Fără artă, fără puzzle-uri: validăm doar bucla
## „cheltuiesc PA -> lovesc -> încheie tura -> inamicul acționează -> rundă nouă".

# ─────────────────────────────────────────────────────────────
# REGULILE JOCULUI (constante)
# `const` = valoare care NU se schimbă în timpul rulării.
# Le ținem sus, toate la un loc: când vrei să reechilibrezi lupta,
# schimbi un număr aici, nu cauți prin tot codul.
# `:=` înseamnă „deduce tu tipul din valoare" (aici: int).
# ─────────────────────────────────────────────────────────────
const PA_PE_RUNDA := 3          # PA primite la începutul fiecărei runde (nu se reportează)
const COST_OBELISC := 1         # cât costă activarea unui Obelisc de Nivel I
const PV_MAX_JUCATOR := 30      # Regele = PV-ul tău
const PV_MAX_INAMIC := 12
const CEAS_MAX := 3             # în câte runde se umple ceasul inamicului
const DAUNE_ATAC_INAMIC := 8    # cât lovește când ceasul e plin

# Datele celor 3 Obeliscuri, ca tabel.
# Un Array de Dictionary = cea mai simplă „bază de date" din GDScript.
# Avantajul: ca să adaugi al 4-lea Obelisc, adaugi o linie aici —
# nu scrii cod nou. Logica de mai jos merge pe orice număr de intrări.
const OBELISCURI := [
	{"nume": "Memorie", "daune": 3},
	{"nume": "Logica", "daune": 3},
	{"nume": "Cuvantul Adevarat", "daune": 2},
]

# ─────────────────────────────────────────────────────────────
# STAREA LUPTEI (variabile)
# `var` = se schimbă în timpul jocului. Astea + jurnalul sunt TOATĂ
# starea luptei — exact ce va trebui, mai târziu, salvat în JSON.
# ─────────────────────────────────────────────────────────────
var runda := 1
var pa := 0
var pv_jucator := PV_MAX_JUCATOR
var pv_inamic := PV_MAX_INAMIC
var ceas_inamic := 0
var lupta_terminata := false
var jurnal: Array[String] = []

# ─────────────────────────────────────────────────────────────
# REFERINȚE CĂTRE NODURI
# `@onready` = „ia nodul ăsta în momentul în care scena e gata".
# Fără @onready, codul ar rula înainte ca nodurile să existe → eroare.
# `%Nume` funcționează pentru nodurile marcate „Access as Unique Name"
# în editor (bifa % din arborele scenei). Avantaj față de $Cale/Lunga:
# dacă muți nodul în altă parte a arborelui, codul NU se strică.
# ─────────────────────────────────────────────────────────────
@onready var eticheta_runda: Label = %Runda
@onready var eticheta_pv_inamic: Label = %InamicPV
@onready var bara_pv_inamic: ProgressBar = %InamicBaraPV
@onready var eticheta_ceas: Label = %InamicCeasEticheta
@onready var bara_ceas: ProgressBar = %InamicBaraCeas
@onready var eticheta_jurnal: Label = %Jurnal
@onready var eticheta_pv_jucator: Label = %JucatorPV
@onready var bara_pv_jucator: ProgressBar = %JucatorBaraPV
@onready var eticheta_pa: Label = %PAEticheta
@onready var buton_incheie_tura: Button = %IncheieTura
# Array simplu cu cele 3 butoane, ca să le putem trata în buclă.
@onready var butoane_obelisc := [%Obelisc1, %Obelisc2, %Obelisc3]


# `_ready()` e chemată automat de Godot o singură dată, când scena a intrat
# în joc și toate nodurile există. Aici punem tot ce se face o dată.
func _ready() -> void:
	# Configurăm butoanele DIN COD, pe baza tabelului OBELISCURI de sus.
	# `range(...)` ne dă indicii 0, 1, 2 — avem nevoie de index, nu doar de buton,
	# ca să știm mai târziu CARE Obelisc a fost apăsat.
	for index in range(butoane_obelisc.size()):
		var buton: Button = butoane_obelisc[index]
		var date: Dictionary = OBELISCURI[index]
		buton.text = "%s\n%d daune\n%d PA" % [date["nume"], date["daune"], COST_OBELISC]
		# SEMNALE: „pressed" e semnalul emis de Button la click.
		# .connect(functie) = „când se emite, cheamă funcția asta".
		# .bind(index) = „și trimite-i index-ul ca argument".
		# Așa scriem O SINGURĂ funcție pentru toate cele 3 butoane.
		buton.pressed.connect(_pe_obelisc_apasat.bind(index))

	buton_incheie_tura.pressed.connect(_pe_incheie_tura_apasat)

	# Pregătim barele o singură dată, din constante — ca să nu existe
	# două surse de adevăr: una în editor, alta în cod.
	bara_pv_inamic.max_value = PV_MAX_INAMIC
	bara_pv_jucator.max_value = PV_MAX_JUCATOR
	bara_ceas.max_value = CEAS_MAX

	scrie_in_jurnal("Lupta incepe.")
	incepe_runda()


# ─────────────────────────────────────────────────────────────
# BUCLA DE RUNDĂ
# ─────────────────────────────────────────────────────────────

## Începutul turei TALE: primești PA proaspăt.
func incepe_runda() -> void:
	pa = PA_PE_RUNDA   # PA nu se reportează — pur și simplu suprascriem
	scrie_in_jurnal("--- Runda %d: ai %d PA. ---" % [runda, pa])
	actualizeaza_ui()


## Chemată când apeși un Obelisc. `index` vine din .bind() de mai sus.
func _pe_obelisc_apasat(index: int) -> void:
	# „Gărzi": ieșim devreme din cazurile în care acțiunea n-are voie să se întâmple.
	# E mai ușor de citit decât un if care înghite tot restul funcției.
	if lupta_terminata:
		return
	if pa < COST_OBELISC:
		scrie_in_jurnal("Nu mai ai PA. Incheie tura.")
		return

	pa -= COST_OBELISC

	# AICI, în sesiunea următoare, se va deschide scena de Trivia și vom aștepta
	# răspunsul. Deocamdată presupunem că răspunsul e mereu corect.
	var date: Dictionary = OBELISCURI[index]
	var daune: int = date["daune"]
	# maxi() = maximul a două int-uri. Îl folosim ca PV să nu scadă sub 0.
	pv_inamic = maxi(pv_inamic - daune, 0)
	scrie_in_jurnal("Obeliscul %s: %d daune." % [date["nume"], daune])

	if pv_inamic == 0:
		termina_lupta(true)
		return

	actualizeaza_ui()


## Butonul „Încheie tura". Dacă lupta s-a terminat, același buton repornește.
func _pe_incheie_tura_apasat() -> void:
	if lupta_terminata:
		reseteaza_lupta()
		return
	tura_inamicului()


## Tura inamicului: ceasul urcă cu 1. Când se umple, lovește și se resetează.
func tura_inamicului() -> void:
	ceas_inamic += 1

	if ceas_inamic >= CEAS_MAX:
		ceas_inamic = 0
		pv_jucator = maxi(pv_jucator - DAUNE_ATAC_INAMIC, 0)
		scrie_in_jurnal("CEASUL S-A UMPLUT! Inamicul loveste pentru %d." % DAUNE_ATAC_INAMIC)
		if pv_jucator == 0:
			termina_lupta(false)
			return
	else:
		scrie_in_jurnal("Inamicul se incarca (%d/%d)." % [ceas_inamic, CEAS_MAX])

	runda += 1
	incepe_runda()


func termina_lupta(victorie: bool) -> void:
	lupta_terminata = true
	if victorie:
		scrie_in_jurnal("VICTORIE! Inamicul a cazut in runda %d." % runda)
	else:
		scrie_in_jurnal("SAH MAT. Ai pierdut in runda %d." % runda)
	buton_incheie_tura.text = "Lupta din nou"
	actualizeaza_ui()


## Readuce starea la valorile de start. Ca să testezi rapid, fără să dai F5.
func reseteaza_lupta() -> void:
	runda = 1
	pv_jucator = PV_MAX_JUCATOR
	pv_inamic = PV_MAX_INAMIC
	ceas_inamic = 0
	lupta_terminata = false
	jurnal.clear()
	buton_incheie_tura.text = "Incheie tura"
	scrie_in_jurnal("Lupta reincepe.")
	incepe_runda()


# ─────────────────────────────────────────────────────────────
# AFIȘARE
# Regulă de aur: logica de sus NU atinge niciodată direct un Label.
# Ea schimbă doar variabilele de stare, apoi cheamă actualizeaza_ui().
# Un singur loc care desenează = imposibil să ai bara și textul desincronizate.
# ─────────────────────────────────────────────────────────────
func actualizeaza_ui() -> void:
	eticheta_runda.text = "RUNDA %d" % runda

	eticheta_pv_inamic.text = "INAMIC — %d / %d PV" % [pv_inamic, PV_MAX_INAMIC]
	bara_pv_inamic.value = pv_inamic

	bara_ceas.value = ceas_inamic
	# Intenția inamicului, anunțată dinainte (ca în Slay the Spire):
	# decizi cu informație completă, nu la noroc.
	if ceas_inamic + 1 >= CEAS_MAX:
		eticheta_ceas.text = "CEAS %d/%d — LOVESTE pentru %d la finalul turei!" % [
			ceas_inamic, CEAS_MAX, DAUNE_ATAC_INAMIC
		]
	else:
		eticheta_ceas.text = "CEAS %d/%d — se incarca" % [ceas_inamic, CEAS_MAX]

	eticheta_pv_jucator.text = "REGELE (tu) — %d / %d PV" % [pv_jucator, PV_MAX_JUCATOR]
	bara_pv_jucator.value = pv_jucator

	# Semnele pline = PA rămase, punctele = PA cheltuite.
	# "x".repeat(n) construiește un string repetat de n ori.
	eticheta_pa.text = "PA: %s%s" % ["@".repeat(pa), ".".repeat(PA_PE_RUNDA - pa)]

	# Butoanele se sting singure când n-ai PA — feedback vizual gratuit,
	# în loc de un mesaj de eroare după click.
	for buton: Button in butoane_obelisc:
		buton.disabled = lupta_terminata or pa < COST_OBELISC


## Ține ultimele 5 linii pe ecran (și le trimite și în consola Godot).
func scrie_in_jurnal(linie: String) -> void:
	jurnal.append(linie)
	if jurnal.size() > 5:
		jurnal.remove_at(0)   # scoate cea mai veche linie
	eticheta_jurnal.text = "\n".join(jurnal)
	print(linie)
