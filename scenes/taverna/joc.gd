class_name Joc
extends Control
## CONTRACTUL UNEI MESE DIN TAVERNĂ — al doilea contract de joc din proiect.
##
## Primul e `Puzzle`: o întrebare, patru butoane, un verdict. Opt discipline îl
## împart, și ăsta e tot rostul lui.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU ÎNCAP MESELE ÎN `Puzzle`, ȘI DE CE A TREBUIT UN AL DOILEA CONTRACT
##
## Prima întrebare a sesiunii a fost chiar asta: „Wordle nu e un rând în
## `CATALOG`?" Nu, și motivul nu e de mărime, e de FORMĂ. Un `Puzzle` are un
## singur moment de decizie — apeși unul din patru butoane, și s-a terminat.
## Wordle are șase, Sudoku are optzeci și unu, iar între ele starea se ADUNĂ:
## ce ai aflat la încercarea a treia schimbă ce merită încercat la a patra. Un
## `Puzzle` nu are unde să țină așa ceva, fiindcă n-are nevoie.
##
## Deci:
##   `Puzzle` e o BAZĂ      — 1443 de linii pe care opt discipline le împart,
##                            fiindcă au tot ecranul la fel.
##   `Joc` e un CONTRACT    — vreo sută de linii, fiindcă două mese din tavernă
##                            n-au nimic la fel în afară de margini: una e o
##                            grilă de litere, alta o grilă de cifre.
##
## Dacă aș fi scris aici o bază groasă, prima mea presupunere despre „ce au
## jocurile în comun" ar fi devenit un zid pentru al treilea joc. Un contract
## subțire nu poate greși așa: nu promite nimic despre interior.
##
## ─────────────────────────────────────────────────────────────
## CE TREBUIE SĂ FACĂ UN JOC NOU
##
##   1. `extends Joc`
##   2. implementează `_porneste(samanta)` — construiește-ți masa
##   3. când s-a terminat, cheamă `termina(reusit, rezumat)`
##
## Și un rând în `mese.gd`. Nimic altceva. Taverna nu știe ce e o literă, o
## cifră sau o grilă — ea deschide o scenă, pune un antet deasupra și ascultă
## semnalul. Aceeași despărțire ca între `lupta.gd` și cele opt discipline.
##
## ─────────────────────────────────────────────────────────────
## SĂMÂNȚA: DE CE E UN PARAMETRU, ȘI DE CE 0 ÎNSEAMNĂ „ALEGE TU"
##
## Un joc din tavernă se joacă în două feluri care cer garanții DIFERITE:
##
##   LIBER (azi)            — „nu vreau același cuvânt de două ori". Asta o dă
##                            sacul (`Sac`), care ține minte ce-a ieșit. Sacul
##                            nu poate fi sămânțat: el alege dintre biletele
##                            RĂMASE, deci rezultatul lui atârnă de tot
##                            istoricul tău, nu de un număr.
##   DECRETUL ZILEI (urmează) — „același joc toată ziua, oricâte ori îl deschid".
##                            Asta o dă o sămânță din dată. Sacul ar fi dat
##                            invers: alt cuvânt la fiecare deschidere.
##
## Niciuna nu înlocuiește pe cealaltă, deci contractul le ține pe amândouă:
## `SAMANTA_LIBERA` (0) înseamnă „alege cum vrei, numai să nu repeți", iar orice
## alt număr înseamnă „exact jocul ăsta". Decretul Zilei e atunci o masă care
## trimite `data de azi` ca sămânță — adică un rând în catalog și un calcul de
## dată, nu un sistem.
##
## ─────────────────────────────────────────────────────────────
## CE NU E ÎN CONTRACT, DINADINS
##
## **Recompense.** Un joc întoarce „am reușit" și o frază, nu Monede. Cine
## plătește (dacă plătește vreodată) e Taverna, fiindcă economia e a jocului,
## nu a mesei — exact ca la noduri, unde lupta nu știe cât valorează victoria.
## Azi nu plătește nimeni nimic: vezi antetul lui `taverna.gd`.
##
## **Niveluri.** Cele opt discipline au I/II/III fiindcă o întrebare trebuie să
## se potrivească unei trepte de combo. O masă n-are treaptă: joci până
## termini. Dacă o masă vrea totuși dificultăți (Sudoku le va vrea), aia intră
## ca sămânță sau ca rând în catalog, nu ca parametru al tuturor.
##
## **Cronometru.** Taverna e modul fără ceas. Asta nu e o lipsă de
## funcționalitate, e definiția modului.

## „Alege tu" — vezi secțiunea despre sămânță din antet.
const SAMANTA_LIBERA := 0

## Jocul s-a terminat. `rezultat` are două chei:
##   „reusit"  — bool. Ce înseamnă „reușit" îl hotărăște masa.
##   „rezumat" — o frază pentru jucător („Cuvântul era CARTE."). Poate fi gol.
##
## DOUĂ CHEI ÎNTR-UN DICȚIONAR, nu doi parametri, din exact motivul scris la
## contractul întrebărilor: un joc care vrea să spună și altceva (câte încercări,
## cât a durat) adaugă o cheie, iar Taverna, care nu se uită la ea, nu se
## schimbă. Doi parametri ar fi devenit trei, iar al treilea ar fi atins toate
## mesele deodată.
signal terminat(rezultat: Dictionary)

## O partidă nouă începe aici.
##
## Strigat de `porneste()`, deci și de pornirea pe care o face Taverna. Pare de
## prisos pentru ea — ea tocmai a cerut pornirea — și totuși nu e: o masă se
## poate reporni SINGURĂ. Sudoku o face, fiindcă nivelurile lui stau pe tăblie
## (trei butoane), iar o grilă nu se poate rescala.
##
## Fără semnalul ăsta, un clic pe „Greu" ar fi lăsat rândul cu rezultatul
## partidei de dinainte („Gata! Grila mediu…", în verde) scris lângă o grilă
## abia începută. Taverna nu se poate uita în masă ca să afle; masa îi spune.
##
## N-are nicio cheie: „a început" nu are ce să poarte. Ce e de spus despre o
## partidă se spune la final, în `terminat`.
signal pornita()

## A chemat cineva `porneste()`?
##
## Există pentru un singur lucru: ca o masă să se poată juca singură cu F6.
## Scena așteaptă un cadru în `_ready` și, dacă steagul e încă stins, pornește
## ea. Fără el, F6 ar da un ecran mort, iar Taverna ar porni jocul de două ori
## (adică ar consuma două bilete din sac pentru o singură partidă). Același
## tipar, din același motiv, ca `pornit` din `puzzle.gd`.
var pornit := false

## Sămânța cu care s-a pornit masa. Ținută ca s-o poată citi o repornire
## („încă o dată, altul" vs. „încă o dată, același").
var samanta := SAMANTA_LIBERA

## Ca un joc terminat să nu se poată termina a doua oară. Aceeași grijă ca
## `raspuns_dat` din `puzzle.gd`: o grilă completată din tastatură în timp ce
## tween-ul de final încă rulează ar fi strigat semnalul de două ori, iar
## Taverna ar fi pus două ecrane de rezultat unul peste altul.
var terminat_deja := false


# ─────────────────────────────────────────────────────────────
# CE CHEAMĂ TAVERNA
# ─────────────────────────────────────────────────────────────

## Pornește masa. Taverna cheamă ASTA, nu `_porneste`.
##
## Despărțirea în două (una publică, una de implementat) e cea de la
## `Puzzle.porneste` / `_compune_intrebare`: partea comună — sămânța reținută,
## steagul de final stins — se scrie o dată, aici, și nu se poate uita într-o
## masă nouă.
func porneste(cu_samanta := SAMANTA_LIBERA) -> void:
	samanta = cu_samanta
	pornit = true
	terminat_deja = false
	pornita.emit()
	_porneste(cu_samanta)


## Un rând de ajutor pentru antetul Tavernei: regulile, în câteva cuvinte.
##
## OPȚIONAL. Lipsa lui nu e o scăpare — un joc care se explică singur din
## ecran (Sudoku) n-are ce scrie aici.
func rand_de_ajutor() -> String:
	return ""


# ─────────────────────────────────────────────────────────────
# CE IMPLEMENTEAZĂ MASA
# ─────────────────────────────────────────────────────────────

## REGULILE jocului, pentru panoul pe care-l deschide Taverna. OPȚIONAL.
##
## `null` = masa n-are ce explica: Taverna nu deschide nimic la prima așezare
## și nu arată butonul „i". Aceeași formă ca `rand_de_ajutor()` — un joc care
## se explică singur din ecran nu plătește nimic pentru o funcție pe care n-o
## scrie.
##
## DE CE REGULILE SUNT ALE MESEI, nu ale Tavernei: dacă Taverna le-ar ține
## într-un tabel, un joc nou s-ar scrie în două locuri, iar textul ar putea
## rămâne în urma codului fără ca nimic să se plângă. Aici stau lângă
## constantele pe care le descriu — `LUNGIME`, `RANDURI` și chiar culorile.
##
## DE CE UN NOD, și nu un text. A fost un `String` o zi, cu etichete BBCode și
## cu pătrate de culoare scrise ca „███". Mergea, și totuși spunea mai puțin:
## regulile unui joc de grilă se înțeleg uitându-te la TREI RÂNDURI ADEVĂRATE,
## nu citind despre ele. Un nod poate purta chiar celulele jocului, construite
## de aceleași funcții — deci exemplul nu poate ajunge să arate altfel decât
## masa pe care o explică.
##
## E chiar judecata scrisă la cârligul de desenare din `puzzle.gd`
## (`_plansa_pentru`): baza nu poate construi ce nu știe, deci primește un NOD,
## nu o listă de forme. Taverna îi pune un titlu deasupra și un „✕" în colț, și
## nu se uită niciodată înăuntru.
##
## Nodul nu mai e al tău după ce-l dai: Taverna îl pune în panoul ei și îl
## îngroapă când pleci de la masă. Se cheamă O DATĂ, la deschiderea mesei, deci
## nu-l ține într-o variabilă și nu te baza pe el după aceea.
func reguli() -> Control:
	return null


## Construiește-ți masa. OBLIGATORIU.
##
## `push_error` și nu o scenă goală: o masă fără `_porneste` e un fișier
## neterminat, nu o stare de joc, iar singurul moment în care o pot afla
## ieftin e prima dată când o deschid.
func _porneste(_samanta: int) -> void:
	push_error("Masa %s n-a implementat `_porneste`." % get_script().resource_path)


## Cheamă asta când s-a terminat. Strigă semnalul o singură dată.
func termina(reusit: bool, rezumat := "") -> void:
	if terminat_deja:
		return
	terminat_deja = true
	terminat.emit({"reusit": reusit, "rezumat": rezumat})
