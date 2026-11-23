class_name Firul
extends RefCounted
## LUPTA CU FIRUL — tot ce se întâmplă între „a mușcat" și „l-ai scos".
##
## Un singur buton: ții apăsat ca să tragi, dai drumul ca să slăbești firul.
## Tragerea aduce peștele (`progres`) și întinde firul (`tensiune`). Dacă
## tensiunea ajunge la 1, firul se rupe și peștele pleacă.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU E DOAR „ȚINE APĂSAT"
##
## Din când în când peștele SMUCEȘTE. Înainte de fiecare smucitură vine o
## AVERTIZARE — firul vibrează, apa se încrețește — iar cine trage prin
## smucitură îl rupe repede. Deci priceperea e să citești semnul și să dai
## drumul la timp, adică exact ce antrenează Obeliscul Reflexului: să NU faci
## ce-ți vine să faci. Aici, la iaz, fără nicio întrebare pe ecran.
##
## Forța speciei (1..5) scurtează avertizarea, lungește smuciturile și
## întinde firul mai repede. Babușca se iartă aproape orice; somnul nu.
##
## ─────────────────────────────────────────────────────────────
## DE CE O CLASĂ A EI, ȘI NU COD ÎN SCENĂ
##
## Ca să poată fi JUCATĂ fără fereastră. `verifica_iazul` trece fiecare specie
## prin mii de lupte cu trei jucători închipuiți — unul atent, unul care ține
## apăsat tot timpul, unul care se uită doar la tensiune — și cere ca primul
## să câștige aproape mereu, iar ceilalți doi să piardă la peștii mari. Fără
## asta, „lupta cere pricepere" ar fi o frază, nu o măsurătoare. Aceeași
## despărțire ca între `Expeditie` și `harta.gd`.

enum Faza { LINISTE, AVERTIZARE, SMUCITURA }

var forta: int
var progres := 0.0
var tensiune := 0.2
var faza := Faza.LINISTE
## Cât mai ține faza de acum, în secunde.
var ceas_faza := 0.0
var rupt := false
var prins := false
## Câte secunde de tras curat aduc peștele la mal.
var durata_tragere := 0.0

var _rng: RandomNumberGenerator


func _init(forta_speciei: int, zona: int, masa_rel: float, rng: RandomNumberGenerator) -> void:
	forta = clampi(forta_speciei, 1, 5)
	_rng = rng
	durata_tragere = 2.6 + 1.1 * forta + 1.0 * zona + 1.8 * masa_rel
	ceas_faza = _pauza()


## Cât ține avertizarea: 0,70 s la babușcă, 0,38 la somn. Sub vreo 0,3 s n-ar
## mai fi citire, ar fi noroc.
func durata_avertizare() -> float:
	return 0.78 - 0.08 * forta


func _pauza() -> float:
	return _rng.randf_range(1.4, 3.2) / (1.0 + 0.10 * forta)


func _durata_smuciturii() -> float:
	return _rng.randf_range(0.45, 0.8) + 0.06 * forta


## Un pas al luptei. `apasat` = jucătorul trage acum.
func pas(dt: float, apasat: bool) -> void:
	if rupt or prins:
		return
	ceas_faza -= dt
	if faza == Faza.SMUCITURA:
		if apasat:
			# Tragi prin smucitură: firul se întinde repede.
			tensiune += (0.55 + 0.32 * forta) * dt
		else:
			tensiune -= 0.18 * dt
			# Peștele ia puțin fir înapoi — se pierde, nu se rupe.
			progres -= (0.015 + 0.006 * forta) * dt
		if ceas_faza <= 0.0:
			faza = Faza.LINISTE
			ceas_faza = _pauza()
	else:
		if apasat:
			progres += dt / durata_tragere
			tensiune += (0.10 + 0.035 * forta) * dt
		else:
			tensiune -= 0.55 * dt
			progres -= 0.01 * dt
		if ceas_faza <= 0.0:
			if faza == Faza.LINISTE:
				faza = Faza.AVERTIZARE
				ceas_faza = durata_avertizare()
			else:
				faza = Faza.SMUCITURA
				ceas_faza = _durata_smuciturii()

	tensiune = maxf(tensiune, 0.0)
	progres = clampf(progres, 0.0, 1.0)
	if tensiune >= 1.0:
		rupt = true
	elif progres >= 1.0:
		prins = true
