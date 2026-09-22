class_name FigurinaHarta
extends Control
## FIGURINA — piesa de șah care stă pe nodul unde ești ACUM.
##
## Pe harta de referință, „unde sunt" nu e scris nicăieri și nu luminează nimic:
## pur și simplu stă o figurină pe locul ăla, ca pe o tablă de joc. E cea mai
## veche convenție din jocurile de societate și n-are nevoie de nicio explicație
## — ochiul o găsește înaintea oricărui simbol, fiindcă e singurul obiect de pe
## hartă care nu e desenat PE hârtie, ci așezat PESTE ea.
##
## ─────────────────────────────────────────────────────────────
## DE CE UN OBIECT SEPARAT, ȘI NU UN DESEN ÎN `simbol_nod.gd`
##
## Tentația e mare: nodul știe deja dacă e cel curent, deci ar putea să-și
## deseneze singur figurina. Trei motive pentru care nu:
##
## 1. E UNA SINGURĂ. Paisprezece noduri ar purta fiecare codul unui obiect care
##    apare pe cel mult unul dintre ele. Cheltuiala nu e de performanță, e de
##    citit: la fiecare întrebare „ce desenează un nod?" ar trebui să ții minte
##    „și, în cazul ăsta, o figurină".
##
## 2. TREBUIE SĂ IASĂ DIN CASETĂ. Nodul e o casetă de 92 px; figurina e mai
##    înaltă decât atât și stă cu talpa pe centru, deci corpul ei urcă mult
##    deasupra. Un nod poate desena în afara casetei lui (`clip_contents` e
##    fals), dar ordinea de desenare nu e a lui: vecinul de deasupra, adăugat
##    după, i-ar trece peste cap.
##
## 3. E DEASUPRA A TOT. Ca obiect separat, adăugat ultimul în pânză, asta e
##    gratis. Ca desen în nod, ar fi însemnat să reordonez nodurile.
##
## ─────────────────────────────────────────────────────────────
## CE ÎNSEAMNĂ „TALPA CADE PE CENTRUL NODULUI"
##
## Un simbol de nod se CENTREAZĂ pe punctul lui: mijlocul sabiei stă pe centru.
## O figurină nu — ea STĂ pe locul ăla. Punctul ei de sprijin e talpa, nu
## mijlocul. Dacă aș centra-o, ar pluti cu o jumătate de corp deasupra nodului
## și n-ar mai arăta așezată pe el, ci agățată de el.
##
## De-aia poziția se calculează din `TALPA`, nu din jumătatea înălțimii. Și
## de-aia `TALPA` e 0,96 și nu 1,0: în PNG mai e o fâșie de transparență sub
## soclu, iar dacă aș socoti talpa la marginea de jos a imaginii, figurina ar
## sta cu câțiva pixeli deasupra hârtiei.
##
## ─────────────────────────────────────────────────────────────
## DACĂ FIȘIERUL LIPSEȘTE
##
## Nu se întâmplă nimic. `exista()` întoarce `false`, harta nu construiește
## obiectul, iar nodul curent rămâne exact cum era înainte: cu aură, cu simbolul
## tipului lui și cu X. Aceeași regulă ca la simbolurile de nod — un fișier de
## artă care nu e încă acolo nu are voie să strice o hartă jucabilă.

## Fișierul figurinei. Un PNG pătrat, cu transparență reală, cu soclul lipit de
## marginea de jos.
const CALE := "res://assets/art/campaign_nodes/campaign_token.png"

## Cât de înaltă e caseta figurinei, în ÎNĂLȚIMI DE NOD.
##
## 1,3 e măsura la care figurina domină nodul fără să acopere vecinii: la 92 px
## nod înseamnă ~120 px, adică urcă vreo 115 px peste centru. Cel mai apropiat
## vecin de pe planșele de azi e la ~73 px — deci îl atinge, dar pe DEASUPRA
## (figurina e ultimul strat), iar un vecin parțial acoperit de piesa pe care
## stai citește corect: „sunt aici, nu acolo".
const INALTIME := 1.3

## Unde e talpa, ca fracțiune din înălțimea texturii. Vezi nota de sus.
const TALPA := 0.96

## Textura, ținută pe CLASĂ: figurina se construiește din nou la fiecare
## redesenare a hărții (după fiecare nod), iar fișierul n-are de ce să fie citit
## de pe disc de zece ori într-o expediție. `_cautata` separat de textură
## fiindcă `null` e un răspuns valid („am încercat, nu e acolo") pe care nu
## vreau să-l reîncerc.
static var _textura: Texture2D = null
static var _cautata := false


## Există fișierul? Harta întreabă ÎNAINTE să construiască ceva, fiindcă
## răspunsul schimbă și felul în care se desenează nodul de dedesubt (vezi
## `acoperit` din `simbol_nod.gd`). O figurină construită și apoi găsită goală
## ar fi lăsat nodul curent fără simbol ȘI fără figurină.
static func exista() -> bool:
	return textura() != null


## Textura, încărcată o singură dată. `ResourceLoader.exists()` înainte de
## `load()` din același motiv ca în `simbol_nod.gd`: `load()` pe o cale
## inexistentă scrie o eroare roșie în consolă, iar o consolă plină de erori
## așteptate e o consolă în care nu mai vezi erorile adevărate.
static func textura() -> Texture2D:
	if _cautata:
		return _textura
	_cautata = true
	if ResourceLoader.exists(CALE):
		_textura = load(CALE) as Texture2D
	if _textura == null:
		print("FigurinaHarta: %s lipseste; nodul curent ramane cu simbolul lui." % CALE)
	return _textura


func _ready() -> void:
	# IGNORE, ca la eticheta de hover: figurina e înaltă și acoperă bucăți din
	# nodurile vecine. Dacă ar prinde ea mouse-ul, un nod accesibil de deasupra
	# ar deveni neclicabil tocmai fiindcă stai lângă el.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Așaz-o cu talpa pe punctul ăsta.
##
## Primește centrul în pixeli și înălțimea unui nod — nu întreabă harta nimic și
## nu știe ce e `Expeditie`. Tot ce face fișierul ăsta e „pune imaginea aia cu
## talpa aici, atât de mare".
func aseaza(centru: Vector2, inaltime_nod: float) -> void:
	# Caseta e pătrată fiindcă textura e pătrată: așa imaginea nu se turtește,
	# oricât de îngustă e figurina desenată în ea.
	var latura := inaltime_nod * INALTIME
	size = Vector2(latura, latura)
	# Pe orizontală o centrăm; pe verticală o URCĂM, cu fix atâta cât e talpa
	# sub marginea de sus a casetei.
	position = centru - Vector2(latura * 0.5, latura * TALPA)
	queue_redraw()


func _draw() -> void:
	var imagine := textura()
	if imagine == null:
		return
	draw_texture_rect(imagine, Rect2(Vector2.ZERO, size), false)
