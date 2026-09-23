extends Control
## ECRANUL DE EXPEDIȚIE — loadout, hartă, sumar.
##
## Trei ecrane într-o scenă, fiindcă sunt trei momente ale ACELUIAȘI lucru:
## îți alegi uneltele, mergi pe drum, afli ce-a ieșit. Ca panourile din luptă
## (jurnal, card, verdict), stau unul peste altul și se arată pe rând.
##
## ─────────────────────────────────────────────────────────────
## CINE DEȚINE CE
##
## Ecranul ăsta nu deține NIMIC din expediție. Toată starea e în
## `autoload/expeditie.gd`; aici se citește și se desenează. Regula se vede cel
## mai bine la PV: harta îl AFIȘEAZĂ, lupta îl SCADE, dar niciuna nu-l ține —
## fiindcă amândouă sunt scene care mor la schimbarea de scenă, iar PV-ul nu
## are voie să moară cu ele.
##
## Consecința practică: poți închide jocul pe hartă, îl redeschizi, și dacă
## `Expeditie` a fost încărcată din save, ecranul ăsta se redesenează identic
## fără să știe că s-a întâmplat ceva.
##
## ─────────────────────────────────────────────────────────────
## CUM CURGE
##
##   `_ready()` se uită la starea expediției și deschide ecranul potrivit:
##     fără expediție        → LOADOUT
##     expediție încheiată   → SUMAR
##     expediție în mers     → HARTA
##
## Asta e tot. Nu există „de unde am venit”: ecranul nu ține minte dacă ai
## ajuns aici din meniu, dintr-o victorie sau dintr-o înfrângere, fiindcă
## starea spune deja totul. Un ecran care ar trebui să știe pe ce drum a fost
## deschis e un ecran care se va deschide greșit, într-o zi, pe al patrulea drum.

const SCENA_LUPTA := "res://scenes/lupta/lupta.tscn"

# ── GEOMETRIA HĂRȚII ──────────────────────────────────────────
# Nodurile NU stau într-un container. Un VBox/HBox le-ar așeza în rânduri
# drepte, dar o hartă are nevoie ca nodul 3 de pe coloana 2 să fie EXACT în
# dreptul spațiului dintre nodurile 1 și 2 — altfel liniile dintre ele nu mai
# arată a drum, ci a tabel. Deci le punem noi, cu `position`, iar pânza
# desenează drumurile între centrele lor.
const MARIME_NOD := Vector2(92, 92)

## ÎNCOTRO MERGE DRUMUL: PE O PANGLICĂ.
##
## Harta de până acum mergea în linie dreaptă de la stânga la dreapta:
## adâncimea era „cât de departe în dreapta”, coloana era „cât de sus”.
## Panglica nu schimbă ideea, o GENERALIZEAZĂ. Există o curbă, iar:
##
##   ADÂNCIMEA = cât ai mers PE curbă  (lungime de arc, `s`)
##   COLOANA   = pe ce bandă ești      (abatere perpendiculară, `dec`)
##
## Adică, în loc de coordonate de caiet (x, y), folosim coordonate LEGATE DE
## DRUM: mergi înainte atât, și stai lateral atât.
##
## DE CE HARTA VECHE E UN CAZ PARTICULAR AL ĂSTEIA: dă-i ca traseu un singur
## segment orizontal. Curba devine o dreaptă, tangenta e mereu (1, 0), normala
## e mereu (0, 1), iar formula `C(s) + N(s)·dec` se citește
## `(stânga + s, mijloc + dec)` — adică exact vechiul „x din adâncime, y din
## coloană". Nu am înlocuit un sistem cu altul; am scos din el presupunerea
## că tangenta e constantă. Tot ce era înainte se obține punând curba la loc
## dreaptă, fără să ating o linie din cod.
##
## Drumul tot merge, în mare, încotro citim. Un drum care șerpuiește spune
## însă și „e un TEREN pe dedesubt” — lucru pe care o linie dreaptă nu-l poate
## spune oricâte liniuțe ai desena pe ea.
##
## ZONA UTILĂ, în FRACȚIUNI DE ECRAN (0..1). Pergamentul nu acoperă toată
## fereastra: are margini arse în stânga și sus, se termină pe la 85% din
## lățime, iar în colțul din dreapta-jos stă cartea legată în piele. Nodurile
## au voie doar pe hârtie.
##
## De ce fracțiuni și nu pixeli: fundalul se întinde peste toată fereastra,
## deci marginea hârtiei rămâne „la 85% din lățime” indiferent cât de mare e
## fereastra. În pixeli, ar fi trebuit recalculată la fiecare redimensionare.
##
## Marginea din dreapta (0.026 + 0.812 = 0.838) e ALEASĂ SUB cartea din colț
## (care începe pe la 0.845): dacă niciun nod nu trece de linia aia, cartea nu
## mai are cum să încurce pe nimeni, iar tot codul care ocolea zona cărții a
## putut dispărea. O regulă de așezare e mai ieftină decât o excepție de ocolit.
##
## Ăsta e și motivul pentru care fâșia de hârtie din dreapta-sus rămâne goală,
## deși acolo chiar e hârtie: zona utilă e un DREPTUNGHI, iar un dreptunghi care
## ar ajunge până la marginea de sus-dreapta ar coborî și peste carte. Ca s-o
## folosim, ar trebui ori o zonă în formă de L (o excepție de ocolit, exact ce
## am scos), ori o planșă desenată mai lată — adică date, nu cod.
##
## CELELALTE TREI MARGINI sunt lipite de hârtie (stânga 0.026, sus 0.042, jos
## 0.948), fiindcă din septembrie 2026 pânza ține toată pagina: antetul și
## piciorul stau PESTE ea, nu deasupra ei. Vezi nota de la `_zona_utila()`.
const ZONA_PERGAMENT := Rect2(0.026, 0.042, 0.812, 0.906)

## Cât lăsăm liber între nodurile de pe marginea zonei și marginea ei.
const MARGINE_PANZA := 18.0

## ─────────────────────────────────────────────────────────────
## EXCEPȚIA DIN COLȚUL DE JOS-DREAPTA
##
## `ZONA_PERGAMENT` se oprește la 0,838 din lățime fiindcă ACOLO, jos de tot,
## începe cartea. E o margine dreaptă trasă după cel mai îngust loc al hârtiei:
## simplă, dar plătită peste tot. La înălțimea mijlocului, unde cotorul e abia
## pe la 0,89, fâșia dintre 0,838 și 0,89 rămâne hârtie bună, nefolosită.
##
## Se vedea la un singur nod: cel mai din dreapta din jumătatea de jos se oprea
## cu vreo 40 px în stânga Bossului, deși mai avea unde. Ochiul citește „drumul
## se întoarce înainte să ajungă", nu „aici era marginea dreptunghiului".
##
## Ce urmează e o EXCEPȚIE ȚINTITĂ, nu o lărgire a zonei. Zona rămâne cum e —
## e ce ține toate celelalte noduri departe de carte fără niciun `if`. Un
## singur nod, ales după o descriere care nu depinde de planșă și nici de
## sămânță, e împins la dreapta după geometrie, și tot atunci e oprit de cotor,
## de vecini și de marginea pânzei. Vezi `impinge_nodul_de_jos_dreapta()`.

## Cu cât trece nodul DINCOLO de Boss pe orizontală. Zero ar însemna „exact sub
## el", iar o coloană perfectă arată a coincidență; câțiva pixeli în plus se
## citesc ca „drumul chiar a ajuns până la capăt".
const PESTE_BOSS := 24.0

## COTORUL CĂRȚII, în fracțiuni din dreptunghiul `Pergament`.
##
## Cartea nu e un nod de scenă: e PICTATĂ în `campaign_map.jpg`, deci codul n-are
## pe cine întreba unde e. Ce se poate face, și se face aici, e s-o măsori o
## dată din imagine și s-o ții în FRACȚIUNI — dreptunghiul peste care se întind
## e cel real al texturii, citit la rulare (`_pergamentul_in_panza()`), deci
## regula se mută singură la orice mărime de fereastră. Dacă imaginea se
## schimbă, cele două perechi de mai jos sunt tot ce e de remăsurat.
##
## Două puncte, nu unul, fiindcă volumul e ÎNCLINAT: cotorul se duce spre
## dreapta pe măsură ce urcă. O verticală trasă prin punctul lui cel mai din
## stânga ar fi aruncat degeaba spațiul de sus — adică exact greșeala pe care
## regula asta o repară.
##
## Măsurate pe rândurile 0,60 și 0,85 din imagine (unde cotorul e pe la 0,905,
## respectiv 0,855), rotunjite în favoarea cărții.
const CARTE_SUS := Vector2(0.900, 0.600)
const CARTE_JOS := Vector2(0.850, 0.850)

## Cât aer rămâne între marginea casetei nodului și cotor.
const MARGINE_CARTE := 26.0

## Cât de aproape au voie să ajungă două centre de noduri. Același prag ca în
## `tools/verifica_harta.gd`: 72 px e distanța la care ajungeau nodurile pe
## harta dreaptă de dinaintea panglicii, adică pragul lui „n-am stricat nimic".
const DISTANTA_MINIMA_NODURI := 72.0

## Pe ce lungime de drum se simte mutarea nodului, măsurată de la capătul mutat.
##
## Drumul nu poate fi translatat întreg: celălalt capăt e lipit de un nod care
## NU se mută. Deci se trage doar de capăt, cu o pondere care scade lin de la 1
## la 0 pe lungimea asta. Mai scurtă = o cotitură bruscă lângă nod; mai lungă =
## se clatină și partea de drum care n-avea niciun motiv. 260 px e cam două
## treimi dintr-un drum obișnuit de pe planșă.
const INFLUENTA_TRAGERII := 260.0

## ─────────────────────────────────────────────────────────────
## TRASEUL PANGLICII
##
## Puncte de trecere în FRACȚIUNI DIN ZONA UTILĂ (0..1; 0,0 e colțul din
## stânga-sus al hârtiei disponibile). Din ele se face o curbă netedă
## (`Curve2D`), iar curba se măsoară DUPĂ LUNGIME, nu după x. Startul cade pe
## primul punct, Bossul pe ultimul.
##
## De ce fracțiuni: același motiv ca la `ZONA_PERGAMENT` — forma traseului nu
## are voie să depindă de mărimea ferestrei.
##
## De ce „după lungime” și nu „după x”: pe o porțiune povârnită, un pas egal pe
## x înseamnă un pas mult mai lung pe hârtie. Straturile ar ieși înghesuite pe
## porțiunile drepte și răsfirate pe cele povârnite. Măsurată după lungime,
## distanța dintre două straturi e aceeași peste tot — exact ce se aștepta
## ochiul de la harta dreaptă.

## VAL — de la stânga la dreapta, cu o ondulație și jumătate pe verticală.
##
## Punctele sunt un cosinus eșantionat la fiecare 45° de fază: pleacă dintr-un
## vârf, coboară într-o vale, urcă la loc și coboară iar. Trei sferturi de
## drum între două vârfuri înseamnă o perioadă și jumătate — adică exact
## ondulația și jumătate cerută.
##
## DE CE ÎNCEPE ÎNTR-UN VÂRF ȘI NU LA MIJLOC. Prima variantă era un sinus:
## pornea de la jumătatea înălțimii, adică din punctul cel mai POVÂRNIT al
## undei. Acolo tangenta e înclinată cu 38°, deci normala e și ea înclinată cu
## 38° — iar banda, care iese perpendicular pe drum, ieșea în diagonală și
## trecea cu 43 de pixeli DINCOLO de marginea din stânga a hârtiei.
##
## Într-un vârf, tangenta e orizontală și normala e verticală: banda iese drept
## în sus și în jos, unde e loc. Aceeași undă, același număr de cocoașe, aceeași
## rază de curbură — doar începută din alt punct al ei. E genul de reparație
## care nu costă nimic dacă te uiți la geometrie în loc să micșorezi ceva.
##
## Sunt treisprezece puncte, nu șapte, tot dintr-un motiv măsurabil: curba
## netedă trasă prin puncte rare face vârfuri mai ASCUȚITE decât unda adevărată,
## iar un vârf ascuțit are rază de curbură mică — și raza de curbură e exact ce
## limitează lățimea panglicii.
##
## AMPLITUDINEA e 0,085 din înălțimea zonei (±34 px pe fereastra implicită) și
## nu e aleasă din ochi: e cea mai mare la care toate verificările din
## `tools/verifica_harta.gd` rămân verzi. Vezi socoteala de la
## `LATIMI_PANGLICA` — val mai mare înseamnă cotituri mai strânse, iar
## cotiturile strânse strivesc nodurile de pe banda dinăuntru.
const TRASEU_VAL := [
	Vector2(0.0000, 0.4150), Vector2(0.0833, 0.4399), Vector2(0.1667, 0.5000),
	Vector2(0.2500, 0.5601), Vector2(0.3333, 0.5850), Vector2(0.4167, 0.5601),
	Vector2(0.5000, 0.5000), Vector2(0.5833, 0.4399), Vector2(0.6667, 0.4150),
	Vector2(0.7500, 0.4399), Vector2(0.8333, 0.5000), Vector2(0.9167, 0.5601),
	Vector2(1.0000, 0.5850),
]

## ȘARPE — stânga-sus → dreapta-sus → mijloc → stânga → jos → dreapta-jos.
##
## Trei culoare orizontale (sus, mijloc, jos) legate prin două ÎNTOARCERI: una
## la dreapta, una la stânga. Fiecare întoarcere e un semicerc eșantionat din
## 45° în 45°, nu un colț — un colț ar avea rază de curbură aproape zero, iar
## panglica s-ar întoarce pe dos exact acolo. Așa, raza întoarcerii e jumătate
## din distanța dintre două culoare, adică tot ce se poate obține pe înălțimea
## asta de hârtie.
##
## VERDICTUL, ÎN CIFRE: ȘARPELE NU ÎNCAPE PE HÂRTIA ASTA. Nu din cauza
## cotiturilor, cum credeam, ci din cauza ÎNĂLȚIMII.
##
## Socoteala, pas cu pas. Ca două noduri de pe același strat să nu se atingă,
## panglica are nevoie de cel puțin 94 px lățime. Ca un nod de pe culoarul de
## sus să nu se atingă de unul de pe culoarul de mijloc — care trec unul pe
## lângă altul, deși pe panglică sunt la o mie de pixeli distanță — mai trebuie
## 92 px între culoare. Deci:
##
##   3 culoare × 94 px de panglică + 2 spații × 92 px = 466 px
##   Zona utilă are                                      397 px
##   Lipsesc                                              69 px
##
## Măsurat pe traseul de mai sus, cu panglica de azi (248 px): cea mai
## apropiată pereche de noduri ajunge la 36,8 px, iar 871 de drumuri se taie pe
## 293 de hărți din 300. Nu e o reglare fină de făcut; e o constrângere care nu
## are soluție la mărimea asta de nod și de pergament.
##
## Ce ar debloca ȘARPELE, dacă vreodată o să-l vrei: un pergament mai înalt,
## noduri mai mici, sau două culoare în loc de trei (2 × 94 + 92 = 280 px,
## adică încape). Traseul rămâne aici, verificat și măsurat, ca să nu-l
## redescoperi de la zero.
const TRASEU_SARPE := [
	# culoarul de sus, de la stânga la dreapta
	Vector2(0.0300, 0.0945), Vector2(0.1650, 0.0945), Vector2(0.3000, 0.0945),
	Vector2(0.4350, 0.0945), Vector2(0.5700, 0.0945), Vector2(0.7050, 0.0945),
	Vector2(0.8400, 0.0945),
	# cotitura din dreapta: un semicerc, din 22,5° în 22,5°
	Vector2(0.8787, 0.1099), Vector2(0.9114, 0.1539), Vector2(0.9333, 0.2197),
	Vector2(0.9410, 0.2973), Vector2(0.9333, 0.3748), Vector2(0.9114, 0.4406),
	Vector2(0.8787, 0.4846),
	# culoarul de mijloc, înapoi spre stânga
	Vector2(0.8400, 0.5000), Vector2(0.7040, 0.5000), Vector2(0.5680, 0.5000),
	Vector2(0.4320, 0.5000), Vector2(0.2960, 0.5000), Vector2(0.1600, 0.5000),
	# cotitura din stânga
	Vector2(0.1213, 0.5154), Vector2(0.0886, 0.5594), Vector2(0.0667, 0.6252),
	Vector2(0.0590, 0.7027), Vector2(0.0667, 0.7803), Vector2(0.0886, 0.8461),
	Vector2(0.1213, 0.8901),
	# culoarul de jos, iar spre dreapta; Bossul e pe ultimul punct
	Vector2(0.1600, 0.9055), Vector2(0.2950, 0.9055), Vector2(0.4300, 0.9055),
	Vector2(0.5650, 0.9055), Vector2(0.7000, 0.9055), Vector2(0.8350, 0.9055),
	Vector2(0.9700, 0.9055),
]

## POTCOAVĂ — stânga-sus → dreapta-sus → cotitură pe dreapta → dreapta-jos →
## stânga-jos (Bossul).
##
## Două culoare în loc de trei. Socoteala de la ȘARPE, refăcută pentru două:
##
##   2 culoare × 94 px de panglică + 1 spațiu × 92 px = 280 px
##   zona utilă are                                     397 px
##   rămân libere                                       117 px
##
## Cei 117 px liberi se duc ÎN SPAȚIUL DINTRE CULOARE, nu într-o panglică mai
## lată, și asta e o decizie de compoziție, nu de geometrie. O panglică lată ar
## însemna două culoare groase, apropiate — care, la o privire, se citesc ca o
## singură bandă gri de noduri. Culoare subțiri, depărtate, se citesc ca DOUĂ
## RÂNDURI: dus pe sus, întors pe jos. Ochiul are nevoie de golul dintre ele ca
## să vadă că sunt două.
##
## Deci panglica de aici e de 104 px (vezi `LATIMI_PANGLICA`) — aproape minimul
## la care două noduri de pe același strat nu se ating — iar culoarele stau la
## 250 px unul de altul, cu 118 px de hârtie goală între benzile vecine.
##
## Culoarele nu ajung până la marginea din dreapta: se opresc la 0,74 din
## lățime. Restul e al cotiturii. Cotitura e un semicerc de rază 125 px (adică
## jumătate din distanța dintre culoare — nu poate fi altfel, dacă vrei să
## intri și să ieși orizontal), iar semicercul mai iese cu o rază spre dreapta.
## 0,74 × 797 + 125 + 52 (jumătatea panglicii) + 14 (abaterea organică) = 781,
## din 797 disponibili. Încape, cu 16 px de rezervă.
##
## Măsurat, raza cotiturii iese 101,5 px, nu 125: curba netedă trasă prin
## puncte e ceva mai strânsă decât cercul pe care îl descriu ele. Rezerva față
## de abaterea laterală rămâne ×1,54, deci nu e o problemă — dar e genul de
## diferență între desen și intenție pe care o afli doar măsurând-o.
const TRASEU_POTCOAVA := [
	# culoarul de sus, de la stânga la dreapta
	Vector2(0.035, 0.185), Vector2(0.176, 0.185), Vector2(0.317, 0.185),
	Vector2(0.458, 0.185), Vector2(0.599, 0.185), Vector2(0.740, 0.185),
	# cotitura din dreapta: un semicerc, eșantionat din 22,5° în 22,5°.
	#
	# Din 45° în 45° ar fi părut de-ajuns — trei puncte pentru o jumătate de
	# cerc — și raza măsurată ieșea 79 px în loc de 125. Prima bănuială a fost
	# că punctele sunt prea rare, ca la vârfurile VALULUI. Le-am îndesit:
	# 79,2 → 79,0, adică nimic. Bănuiala era greșită, iar măsurătoarea a spus-o
	# imediat: vinovat era SALTUL de densitate dintre culoar și cotitură, reparat
	# în `panglica()` prin mânere pe măsura segmentului. După reparație, raza a
	# sărit la 101,5.
	#
	# Punctele dese rămân, fiindcă acum chiar ajută (cu ele, cotitura e un cerc,
	# nu o aproximare din trei bucăți) — dar merită ținut minte că nu ele au
	# rezolvat problema. Prima explicație care sună bine nu e neapărat cea
	# adevărată; de-aia se măsoară după fiecare schimbare, nu doar la sfârșit.
	Vector2(0.800, 0.209), Vector2(0.851, 0.277), Vector2(0.885, 0.379),
	Vector2(0.897, 0.500),
	Vector2(0.885, 0.621), Vector2(0.851, 0.723), Vector2(0.800, 0.791),
	# culoarul de jos, înapoi spre stânga; Bossul e pe ultimul punct
	Vector2(0.740, 0.815), Vector2(0.599, 0.815), Vector2(0.458, 0.815),
	Vector2(0.317, 0.815), Vector2(0.176, 0.815), Vector2(0.035, 0.815),
]

enum Traseu { VAL, SARPE, POTCOAVA, POTCOAVA_OGLINDITA }

## TRASEE OGLINDITE — cine din cine se naște.
##
## POTCOAVA_OGLINDITĂ e aceeași potcoavă, întoarsă stânga-dreapta: pleacă din
## dreapta-sus, merge spre stânga-sus, cotește pe STÂNGA, coboară și se
## întoarce spre dreapta-jos, unde stă Bossul.
##
## DE CE NU E UN AL DOILEA TABEL DE PUNCTE. Aș fi putut scrie cele
## nouăsprezece perechi cu x-ul deja scăzut din 1. Ar fi mers — până în ziua în
## care mut culoarul de sus de la 0,185 la 0,17 în POTCOAVĂ și uit de geamăna
## ei. Atunci ai două hărți care se numesc la fel și arată diferit, iar
## nepotrivirea n-o vezi decât dacă le compari punct cu punct.
##
## Oglindirea e o OPERAȚIE, nu o copie: `x → 1 − x`, aplicată la citire. Un
## singur tabel de puncte rămâne adevărul; oglinda doar îl citește invers. Orice
## reglaj din POTCOAVĂ ajunge automat și aici.
##
## DE CE ORDINEA PUNCTELOR RĂMÂNE NESCHIMBATĂ. Instinctul zice că un traseu
## întors se parcurge și de la coadă la cap. Nu aici: dacă aș inversa și
## ordinea, Startul ar cădea pe (0,035; 0,815) — adică jos-stânga — și am
## obține potcoava rotită cu 180°, nu oglindită. Cu x-ul răsturnat și ordinea
## păstrată, primul punct (0,035; 0,185) devine (0,965; 0,185): dreapta-sus,
## exact de unde trebuie să plece. Startul rămâne primul punct, Bossul ultimul,
## ca la toate celelalte trasee — regula aia n-are voie să aibă excepții.
##
## ─────────────────────────────────────────────────────────────
## CE AM AFLAT MĂSURÂND: NU E O FOTOGRAFIE ÎNTOARSĂ
##
## Așteptarea firească e ca harta oglindită să fie exact harta veche văzută în
## oglindă — aceleași noduri, aceleași distanțe, doar mutate. Verificarea a
## ieșit ALTFEL: distanța medie între noduri legate 214,9 px față de 215,2, iar
## cea mai apropiată pereche 86,9 px față de 84,2. Aproape, dar nu identic.
##
## Cauza e într-un semn. Un nod se așază la `C(s) + dec · N(s)`, unde `N` e
## normala la curbă, adică tangenta rotită cu 90°. Când oglindești curba,
## tangenta își schimbă semnul lui x — dar normala, fiind tangenta ROTITĂ, iese
## oglindită ȘI cu semn schimbat. Pe scurt: pe traseul oglindit, `dec` pozitiv
## arată în partea cealaltă.
##
## Iar `dec` e dat de coloană. Deci pe harta oglindită coloana 0 stă pe banda pe
## care înainte stătea ultima coloană. Fiecare nod își păstrează sămânța și
## abaterea organică, dar aterizează pe banda opusă — și atunci distanțele nu
## mai pot ieși aceleași.
##
## Măsurat nod cu nod pe sămânța 1000: x-urile se potrivesc la zecimală cu
## oglinda perfectă, iar nodurile de pe același strat sunt EXACT interschimbate.
## Startul și Bossul, singuri pe stratul lor, cad fix în oglindă.
##
## L-am lăsat așa, și nu din lene. O oglindă perfectă ar fi dat aceeași hartă
## întoarsă — același desen, recunoscut imediat. Așa, cele două potcoave au
## aceeași FORMĂ și aranjamente diferite, ceea ce e chiar ce vrei de la un al
## doilea traseu. Dacă vreodată o să vrei oglinda exactă, se face dintr-un semn:
## `dec` negat când traseul e oglindit, în `asezare()`.
const OGLINDIRI := {
	Traseu.POTCOAVA_OGLINDITA: Traseu.POTCOAVA,
}

## CARE TRASEU E ÎN JOC. ← comutatorul. O singură linie de schimbat:
##
##     const TRASEU := Traseu.POTCOAVA             două rânduri și o cotitură (activ)
##     const TRASEU := Traseu.POTCOAVA_OGLINDITA   aceeași, cotitura pe stânga
##     const TRASEU := Traseu.VAL                  ondulația
##     const TRASEU := Traseu.SARPE                trei culoare, strat înclinat
##
## Salvezi fișierul, redeschizi ecranul de expediție, și harta e alta. Nu
## trebuie repornit jocul: `_aseaza_nodurile()` reconstruiește panglica de
## fiecare dată când pânza își schimbă mărimea.
##
## E o constantă, nu o setare de meniu: forma hărții e o decizie de design, nu
## o preferință a jucătorului.
const TRASEU := Traseu.POTCOAVA_OGLINDITA

## Cât de lung e mânerul unui punct, ca fracțiune din segmentul de lângă el.
##
## 1/3 e valoarea care face curba Catmull-Rom — clasica „treci exact prin
## fiecare punct, cu tangenta dată de vecinii lui". (Dacă ai văzut formula
## scrisă cu 1/6, e aceeași: acolo mânerul se ia din vectorul dintre CEI DOI
## vecini, care e de două ori mai lung decât un segment.) Mai mare = bucle;
## mai mic = colțuri.
const NETEZIRE_PANGLICA := 1.0 / 3.0

## Cât de des se măsoară curba când i se calculează lungimea. Mai mic = mai
## exact, mai multă memorie. 2 pixeli e sub pragul vizibil.
const PAS_MASURARE := 2.0

## Cât de departe unul de altul se iau cele trei puncte din care iese raza
## cotiturii. Prea aproape și zgomotul de virgulă mobilă dă raze aiurea; prea
## departe și o cotitură scurtă trece neobservată.
const PAS_RAZA := 4.0

## LĂȚIMEA PANGLICII: distanța dintre banda cea mai de sus și cea mai de jos.
##
## Benzile stau la ±LĂȚIME/2 față de curba centrală. Cu două noduri pe strat,
## asta e chiar distanța dintre ele.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU POATE FI ORICÂT — TREI LIMITE, TOATE MĂSURATE ÎN
## `tools/verifica_harta.gd`
##
## 1. RAZA COTITURII. Cea mai mare abatere laterală a unui nod (jumătate de
##    lățime PLUS abaterea organică) trebuie să fie mai mică decât raza celei
##    mai strânse cotituri. Altfel banda dinspre interiorul cotiturii se
##    întoarce pe ea însăși: la o rază de 130 și un nod la 138 spre interior,
##    nodul trece DINCOLO de centrul cercului, iar ordinea de pe bandă se
##    inversează. Un drum desenat pe o bandă îndoită pe dos face o buclă.
##    Azi: abatere maximă 138, rază minimă 167 — rezervă ×1,21.
##
## 2. ÎNCĂPEREA. Cât urcă și coboară traseul, plus abaterea maximă, trebuie să
##    stea în zona utilă. Azi: 34 + 138 = 172 din 198 (jumătatea zonei).
##
## 3. STRÂNGEREA DIN COTITURĂ, și asta e limita care surprinde. Două noduri de
##    pe straturi vecine sunt la vreo 120 px unul de altul MĂSURAT PE CURBA
##    CENTRALĂ. Pe o bandă dinspre interiorul unei cotituri de rază R, aceeași
##    bucată de drum se scurtează cu factorul (R − abatere) / R. La R = 133 și
##    abatere 138 factorul e negativ; la R = 167 și 138 e 0,17 — adică 120 px
##    de drum devin 20 px pe hârtie, și două noduri se suprapun.
##
##    Din cauza asta lățimea și amplitudinea NU se pot mări amândouă: raza
##    scade cam invers proporțional cu amplitudinea (R ≈ 6000 / amplitudine,
##    pe lățimea hârtiei ăsteia și cu o ondulație și jumătate), deci produsul
##    „lățime × amplitudine” e practic fix. Vrei val mai mare ⇒ panglică mai
##    îngustă, și invers.
##
## Valorile de azi ies dintr-o măsurătoare, nu dintr-o presimțire: harta
## DREAPTĂ de dinainte avea, pe 300 de semințe, cea mai apropiată pereche de
## noduri la 71,4 px. Panglica de acum e la 82,6 px. Adică nu doar că nu s-a
## stricat nimic — s-a și mai aerisit puțin.
## Lățimea e pe TRASEU, fiindcă e legată de forma lui: cât de strânse sunt
## cotiturile, și de câtă hârtie mai rămâne după ce traseul își ia partea.
## ȘARPELE are 50 px — de zece ori mai puțin decât pare rezonabil — și ăsta e
## tot rostul forfecării: pe o panglică forfecată, lățimea nu mai e singura
## sursă de distanță între două noduri de pe același strat. Vezi `FORFECARI`.
const LATIMI_PANGLICA := {
	Traseu.VAL: 248.0,
	Traseu.SARPE: 50.0,
	Traseu.POTCOAVA: 104.0,
}

## Cât din înălțimea zonei are voie să ocupe panglica pe o fereastră mică.
## Pe fereastra implicită nu se activează: 248 din 397 înseamnă 62%.
const PROPORTIE_MAXIMA_PANGLICA := 0.64

## Cât trebuie să rămână între două noduri de pe ACELAȘI strat, măsurat
## perpendicular pe panglică.
##
## `MARIME_NOD.y` e minimul evident: sub el, două simboluri se ating. Cei doi
## pixeli în plus nu se văd, dar au un rol. Fără ei, `_potoleste_abaterea`
## nimerea fix pe limită — 92,0000 pixeli — iar la a șaptea zecimală o scădere
## de numere în virgulă mobilă cădea când deasupra, când dedesubtul ei.
##
## Regula generală merită ținută minte: când o condiție e „cel puțin atât”,
## țintește puțin peste, nu exact. Egalitatea e singurul loc din virgula
## mobilă unde nu te poți baza pe nimic.
const DISTANTA_MINIMA_BANDA := MARIME_NOD.y + 2.0

## ABATEREA ORGANICĂ — TOT PE PANGLICĂ
##
## Nodurile așezate exact pe o grilă arată a tabel, oricât de frumos le-ai
## desena. Fiecare primește deci o împingere într-o direcție oarecare, destul
## cât să se simtă „așezat pe un teren”, prea puțin cât să încurce citirea.
##
## Împingerea vine din SĂMÂNȚA NODULUI, nu din `randf()`: aceeași expediție
## trebuie să arate identic la fiecare redesenare, altfel harta ar tresări la
## fiecare redimensionare de fereastră și la fiecare întoarcere din luptă.
##
## Amândouă abaterile se aplică ÎN COORDONATELE PANGLICII, nu pe ecran:
##
##   DE-A LUNGUL (`ABATERE_LUNG`) mută nodul înainte/înapoi PE curbă. Ca
##   fracțiune din distanța dintre două straturi; mică, fiindcă o abatere mare
##   ar amesteca două straturi vecine și n-ai mai ști care vine după care.
##
##   DE-A CURMEZIȘUL (`ABATERE_LAT`) îl mută între benzi. Ca fracțiune din
##   distanța dintre benzi. Aici nu se poate amesteca nimic — sunt doar două
##   benzi — deci îmi permit mai multă dezordine, cu condiția de ordine ținută
##   de `_potoleste_abaterea`.
##
## De ce pe panglică și nu pe ecran: o abatere „în jos” pe o porțiune unde
## panglica coboară abrupt ar împinge nodul DE-A LUNGUL drumului, nu lateral —
## adică ar strica exact lucrul (distanța dintre straturi) pe care abaterea nu
## trebuie să-l atingă.
const ABATERE_LUNG := 0.13
const ABATERE_LAT := 0.17
const ABATERE_MAXIMA_LUNG := 8.0
const ABATERE_MAXIMA_LAT := 14.0

## BENZILE DIN DOI ÎN DOI SE STRÂNG SPRE MIJLOCUL PANGLICII.
##
## Regula asta exista și pe harta dreaptă, unde straturile impare se trăgeau
## spre centrul hârtiei. Pe panglică e ȘI MAI necesară, din două motive
## măsurate:
##
##   COMPOZIȚIA. Panglica e mai îngustă decât era răsfirarea pe verticală a
##   hărții drepte (vezi `LATIMI_PANGLICA`: lățimea e limitată de raza
##   cotiturilor). Fără strângere, toate nodurile ar sta pe exact două linii
##   paralele, iar hârtia ar rămâne goală între ele.
##
##   DISTANȚA DINTRE STRATURI VECINE. Ăsta e motivul greu. Două noduri de pe
##   straturi vecine și de pe ACEEAȘI bandă sunt despărțite doar de cât
##   înaintează drumul — vreo sută de pixeli, cu un nod de 92. Strângerea le
##   pune pe benzi diferite din doi în doi, deci le mai adaugă o despărțire
##   LATERALĂ. Exact asta ținea harta dreaptă departe de suprapuneri, și tot
##   asta o ține și pe cea curbă.
const STRANGERE_ALTERNATA := 0.40

## FORFECAREA: STRATUL ÎNCLINAT.
##
## Până acum, nodurile unui strat stăteau pe NORMALA panglicii — o perpendiculară
## curată pe drum. Cu forfecare, fiecare bandă primește și o împingere DE-A
## LUNGUL drumului, proporțională cu cea laterală:
##
##     s' = s + k × dec
##
## Adică stratul nu mai e un segment perpendicular, ci o diagonală.
##
## ─────────────────────────────────────────────────────────────
## LA CE FOLOSEȘTE: CUMPERI ÎNĂLȚIME CU LUNGIME
##
## Două noduri de pe același strat trebuie să fie la 92 px unul de altul. Fără
## forfecare, toți cei 92 se plătesc din LĂȚIMEA panglicii, adică din
## înălțimea hârtiei — care la ȘARPE e exact ce lipsește (trei culoare nu
## încăpeau, lipseau 69 px).
##
## Cu forfecare, cele două noduri sunt despărțite și lateral (dec), și
## de-a lungul (k × dec). Distanța dintre ele devine
##
##     lățime × √(1 + k²)
##
## deci aceeași distanță se obține cu o panglică de √(1 + k²) ori mai îngustă.
## La k = 2,0 factorul e 2,24: o panglică de 50 px ține nodurile la 112 px.
## Cei 92 px se plătesc acum din lungimea drumului, unde ȘARPELE are de unde —
## 2340 px de panglică pentru nouă straturi.
##
## ─────────────────────────────────────────────────────────────
## DE CE FORFECAREA NU POATE CREA ÎNCRUCIȘĂRI
##
## Fiindcă e aplicată pe TOT drumul, nu doar pe capete — vezi `puncte_drum()`.
## Un drum se calculează întâi în coordonatele nepieptănate (s, dec), exact ca
## înainte, și abia la final fiecare punct e mutat cu `s → s + k·dec`.
##
## Transformarea asta, Φ(s, dec) = (s + k·dec, dec), e o FORFECARE a planului:
## liniară, cu determinantul 1, deci inversabilă. O aplicație inversabilă și
## continuă a planului duce curbe care nu se taie tot în curbe care nu se taie
## — dacă imaginile s-ar intersecta într-un punct, ar face-o și originalele în
## punctul de dinainte de transformare, fiindcă Φ are un singur invers.
##
## Deci argumentul vechi rămâne valabil întreg: două drumuri între aceleași
## straturi au același `s` la același `t` și diferă doar prin `dec`; dacă unul
## e lateral deasupra celuilalt la plecare ȘI la sosire, rămâne deasupra pe tot
## drumul. Forfecarea nu atinge `dec` — doar strâmbă `s` — deci nu poate
## schimba nicio ordine laterală.
##
## Singura condiție care rămâne e cea dinainte: trecerea din (s, dec) pe ecran
## trebuie să fie și ea inversabilă, adică abaterea laterală să nu treacă de
## raza cotiturii (verificarea (1)). Forfecarea nu schimbă `dec`, deci nu
## schimbă nici condiția asta.
const FORFECARI := {
	Traseu.SARPE: 2.0,
}


## CÂT DE REPEDE SE DESPART DOUĂ DRUMURI CARE PLEACĂ DIN ACELAȘI NOD.
##
## Trecerea de la banda nodului de plecare la banda celui de sosire nu e
## liniară: e un amestec între liniar și `smoothstep`. `smoothstep` singur ar
## pleca din nod cu panta zero — două drumuri spre benzi diferite ar rămâne
## lipite o bună bucată și abia apoi s-ar despărți, ceea ce arată a mănunchi,
## nu a bifurcație. Amestecul cu liniar le dă o pantă nenulă din prima clipă,
## deci se despart imediat, dar tot intră lin în nodul de sosire.
const AMESTEC_LINIAR := 0.7


# ── DRUMURILE ─────────────────────────────────────────────────
# Erau gri-deschise și subțiri, adică invizibile: pe un pergament maro, o linie
# deschisă și de 5 pixeli nu spune nimic despre ce leagă de ce. Acum sunt
# CERNEALĂ: groase, închise, cu liniuțe lungi — ca traseele punctate de pe
# hărțile de aventură din care ne inspirăm.

const GROSIME_DRUM := 6.0
const GROSIME_DRUM_ALES := 11.0

## Unde se OPRESC liniuțele în jurul centrului unui nod, CÂND nu se poate afla
## altfel. E plasa de siguranță, nu regula: se folosește doar la nodurile
## desenate din poligoane (PNG lipsă), unde nu există imagine de citit.
##
## Regula adevărată e `_cerneala_pana_unde()`: drumul se taie la ultimul pixel
## de cerneală al simbolului. Motivul întreg e acolo; pe scurt, o rază fixă
## presupune că fiecare simbol e un cerc, iar săbiile sunt un X subțire —
## cerneala lor se termină la 8 px de centru pe orizontală, deci cifra de mai
## jos lăsa un gol de aproape jumătate de nod.
##
## Rămâne folosită și de verificatoarele din `tools/`, ca zonă de lângă nod în
## care încrucișările nu se numără. Acolo o valoare generoasă e ce trebuie:
## drumurile care pleacă din același nod se apropie oricum lângă el.
const OPRIRE_LA_NOD := 56.0

## Câți pixeli de hârtie goală rămân între cerneala simbolului și prima
## liniuță de drum. Ăsta e numărul de reglat dacă drumul pare prea lipit (sau
## prea depărtat) de icoane — singurul.
const RESPIRO_DRUM := 3.0

## Din cât în cât se pipăie drumul când se caută capătul cernelii. Un pixel:
## mai fin n-are ce arăta pe un ecran, mai grosolan ar rata vârful unei săbii.
const PAS_CERNEALA := 1.0

## Culorile drumurilor, în tonuri de CERNEALĂ. Trei stări, trei nuanțe:
##   parcurs   — pe unde ai fost deja. Cerneală spălată: e istorie, nu opțiune.
##   deschis   — de unde ești, spre unde poți merge. Cea mai apăsată din tot
##               ecranul; practic negru-maro, opac.
##   inchis    — restul hărții. Mai stins, dar CITIBIL: vrei să vezi ce n-ai
##               ales, altfel alegerea nu are greutate. Vechea valoare (0.30
##               opacitate) făcea din „citibil” o vorbă goală.
const CULOARE_DRUM_PARCURS := Color(0.42, 0.28, 0.17, 0.45)
const CULOARE_DRUM_DESCHIS := Color(0.16, 0.08, 0.03, 1.00)
const CULOARE_DRUM_INCHIS := Color(0.31, 0.20, 0.10, 0.44)

## Cerneala textului care stă DIRECT pe pergament (eticheta de hover), cu
## conturul crem care o desprinde de textura de dedesubt.
const CULOARE_TEXT := Color(0.16, 0.10, 0.05)
const CULOARE_TEXT_SLAB := Color(0.30, 0.21, 0.13)
const CULOARE_CONTUR := Color(0.99, 0.95, 0.84, 0.90)
const GROSIME_CONTUR := 7
const LATIME_ETICHETA := 230.0

@onready var eticheta_titlu: Label = %Titlu
@onready var eticheta_stare: Label = %Stare
@onready var eticheta_loadout: Label = %Loadout
@onready var eticheta_picior: Label = %Picior
@onready var pergament: TextureRect = $Pergament
@onready var panza: Control = %Panza

@onready var panou_loadout: Control = %PanouLoadout
@onready var loadout_subtitlu: Label = %LoadoutSubtitlu
@onready var loadout_lista: VBoxContainer = %LoadoutLista
@onready var camp_samanta: LineEdit = %CampSamanta
@onready var buton_loadout: Button = %LoadoutButon

@onready var panou_sumar: Control = %PanouSumar
@onready var sumar_titlu: Label = %SumarTitlu
@onready var sumar_text: Label = %SumarText
@onready var sumar_randuri: VBoxContainer = %SumarRanduri
@onready var buton_sumar: Button = %SumarButon

@onready var panou_magazin: Control = %PanouMagazin
@onready var magazin_subtitlu: Label = %MagazinSubtitlu
@onready var magazin_lista: VBoxContainer = %MagazinLista
@onready var buton_magazin: Button = %MagazinButon

@onready var panou_mesaj: Control = %PanouMesaj
@onready var mesaj_titlu: Label = %MesajTitlu
@onready var mesaj_text: Label = %MesajText
@onready var buton_mesaj: Button = %MesajButon

## Ce discipline sunt bifate în ecranul de loadout. Trăiește doar cât ține
## ecranul: din clipa în care apeși „Pornește”, adevărul e `Expeditie.loadout`.
var alese: Array[String] = []

## Simbolurile nodurilor, ca să le pot reașeza la redimensionarea ferestrei
## fără să reconstruiesc harta. „id de nod → SimbolNod”.
var simboluri_nod := {}

## Eticheta care apare sub nodul survolat. UNA singură, ținută de ecran, nu
## câte una în fiecare nod: zece etichete permanente ar acoperi harta, iar zece
## etichete ascunse s-ar putea suprapune între ele în clipa în care apar două.
var eticheta_nod: VBoxContainer
var eticheta_nod_nume: Label
var eticheta_nod_rol: Label

## Peste ce nod stă mouse-ul acum. `-1` = niciunul. Ținut minte ca să nu ascund
## eticheta când mouse-ul a ieșit dintr-un nod DUPĂ ce intrase deja în altul —
## semnalele vin în ordinea asta mai des decât te-ai aștepta.
var nod_survolat := -1


func _ready() -> void:
	buton_loadout.pressed.connect(_pe_pornire)
	buton_sumar.pressed.connect(_pe_expeditie_noua)
	buton_mesaj.pressed.connect(_pe_mesaj_inchis)
	buton_magazin.pressed.connect(_pe_magazin_inchis)
	# Fereastra redimensionată ⇒ nodurile trebuie reașezate. Semnalul vine de
	# la pânză, nu de la fereastră: pe noi ne interesează cât spațiu a primit
	# ZONA DE HARTĂ, care depinde și de cât ocupă antetul de deasupra.
	panza.resized.connect(_aseaza_nodurile)

	panou_loadout.visible = false
	panou_sumar.visible = false
	panou_mesaj.visible = false
	panou_magazin.visible = false

	Muzica.reda(Muzica.Piesa.HARTA)

	# Un singur loc în care se decide ce ecran vezi — vezi antetul.
	if Expeditie.final != "":
		_arata_sumar()
	elif not Expeditie.activa:
		_arata_loadout()
	else:
		_dupa_un_nod()


# ─────────────────────────────────────────────────────────────
# ECRANUL 1: LOADOUT — „alege N din M”
# ─────────────────────────────────────────────────────────────

func _arata_loadout() -> void:
	alese.clear()
	panou_loadout.visible = true
	eticheta_titlu.text = "EXPEDITIE"
	eticheta_stare.text = ""
	eticheta_loadout.text = ""
	eticheta_picior.text = ""
	_goleste_panza()
	var fara_muchii: Array[Dictionary] = []
	panza.arata(fara_muchii)
	_construieste_loadout()
	_actualizeaza_loadout()


## Un rând per disciplină din CATALOG. Nicio cifră scrisă de mână: numărul de
## rânduri e M, iar cât poți bifa e N. Când apare a patra disciplină, apare al
## patrulea rând, fără nicio linie schimbată aici.
func _construieste_loadout() -> void:
	for copil in loadout_lista.get_children():
		loadout_lista.remove_child(copil)
		copil.queue_free()

	for date in Discipline.CATALOG:
		loadout_lista.add_child(_rand_disciplina(date))


## `CheckButton` = un comutator care își ține singur starea apăsată. Pentru o
## alegere multiplă e mai cinstit decât un buton obișnuit: vezi dintr-o privire
## ce e bifat, fără să ții minte pe ce ai apăsat.
func _rand_disciplina(date: Dictionary) -> Control:
	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 0)

	var comutator := CheckButton.new()
	comutator.text = String(date["nume"])
	comutator.modulate = date["culoare"]
	comutator.toggled.connect(_pe_disciplina_bifata.bind(String(date["cheie"])))
	coloana.add_child(comutator)

	# Ce ANTRENEAZĂ, sub nume. O alegere între trei cuvinte fără explicație nu
	# e o alegere — e o ghicitoare. (Azi le iei pe toate trei, deci rândul ăsta
	# pare degeaba; cu opt discipline, el e tot ecranul.)
	var rol := Label.new()
	rol.text = String(date["rol"])
	rol.modulate = Color(0.58, 0.58, 0.66)
	rol.add_theme_font_size_override("font_size", 13)
	rol.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coloana.add_child(rol)

	return coloana


func _pe_disciplina_bifata(bifat: bool, cheie: String) -> void:
	if bifat and not (cheie in alese):
		alese.append(cheie)
	elif not bifat:
		alese.erase(cheie)
	_actualizeaza_loadout()


## Subtitlul și butonul, scrise din N și M — niciodată din cifre.
func _actualizeaza_loadout() -> void:
	var n := Expeditie.DISCIPLINE_IN_LOADOUT
	var m := Discipline.cate()

	if m <= n:
		# Cazul de azi: ai exact atâtea discipline câte încap. Spune-o pe față,
		# în loc să ceri o „alegere” care n-are variante.
		loadout_subtitlu.text = "Ai %d discipline si incap toate %d. Alegerea incepe cand vei avea mai multe." % [m, n]
	else:
		loadout_subtitlu.text = "Alege %d din %d. Raman fixe pe toata expeditia." % [n, m]

	buton_loadout.disabled = alese.size() != n
	if alese.size() == n:
		buton_loadout.text = "Porneste expeditia"
	else:
		buton_loadout.text = "Alese: %d / %d" % [alese.size(), n]


func _pe_pornire() -> void:
	# Sămânța scrisă de mână e unealta de depanare: același număr, aceeași
	# hartă, de fiecare dată. Gol sau nenumeric = una la întâmplare, dar tot
	# ținută minte (vezi `Expeditie.incepe`).
	var text := camp_samanta.text.strip_edges()
	var samanta := int(text) if text.is_valid_int() else 0
	Expeditie.incepe(alese, samanta)
	panou_loadout.visible = false
	_arata_harta()


# ─────────────────────────────────────────────────────────────
# ECRANUL 2: HARTA
# ─────────────────────────────────────────────────────────────

func _arata_harta() -> void:
	panou_loadout.visible = false
	panou_sumar.visible = false
	_construieste_harta()
	_actualizeaza_antet()


## Antetul: unde ești, cât PV ai, ce ai adunat, cu ce lupți, din ce sămânță.
## Sămânța stă la vedere DINADINS — un bug raportat ca „se blochează la nodul
## 6" nu se poate reproduce dacă numărul ăla e ascuns în cod.
## CE S-A ÎNTÂMPLAT CU „NODUL X DIN Y”.
##
## Scria „nodul 4 din 12”, unde 12 erau straturile hărții. Pe harta generată era
## adevărat oricum ai fi mers: toate traseele aveau exact câte un nod pe strat,
## deci și exact aceeași lungime. Pe o planșă desenată de mână, un traseu are
## șapte noduri și altul nouă — iar un antet care scrie „din 9” în timp ce tu
## mergi pe drumul de 7 minte la fiecare pas, și nu se poate repara alegând
## celălalt număr: niciunul nu e al DRUMULUI TĂU, fiindcă drumul tău nu e ales
## încă.
##
## Numărul care rămâne adevărat pe orice hartă și pe orice drum e CÂT MAI AI
## PÂNĂ LA BOSS, pe cel mai scurt drum. „Cel puțin”, fiindcă poți alege și
## ocolul. Pe harta generată dă exact câte straturi au rămas — adică fix
## informația veche — deci nu s-a pierdut nimic; s-a pierdut doar presupunerea
## că toate drumurile sunt la fel de lungi.
func _actualizeaza_antet() -> void:
	var pas := Expeditie.parcurse.size()
	var ramas := Expeditie.pasi_pana_la_boss()
	if ramas <= 0:
		eticheta_titlu.text = "EXPEDITIE  —  nodul %d: Bossul" % (pas + 1)
	else:
		eticheta_titlu.text = "EXPEDITIE  —  nodul %d, Bossul la cel putin %d pasi" % [
			pas + 1, ramas]
	# Monedele stau lângă Fragmente, dar înseamnă altceva, și antetul o spune:
	# Fragmentele sunt averea care rămâne, Monedele sunt ce ai pe drumul ăsta.
	# Un jucător care nu le vede crescând n-o să caute niciodată un Magazin.
	eticheta_stare.text = "%d / %d PV     %d Monede     %d Fragmente     samanta %d" % [
		Expeditie.pv, Expeditie.pv_max, Expeditie.monede,
		Tezaur.cat(Tezaur.Resursa.FRAGMENTE), Expeditie.samanta
	]

	var nume: Array[String] = []
	for cheie in Expeditie.loadout:
		nume.append(Discipline.nume(cheie))
	eticheta_loadout.text = "Unelte: " + ", ".join(nume)

	# Acum că numele nodurilor apar doar la survolare, piciorul e locul în care
	# scrie CUM se citește harta. Un semn pe care nu știi să-l interoghezi e un
	# semn degeaba.
	eticheta_picior.text = "Treci peste un semn ca sa vezi ce te asteapta. Drumul nu se poate reface."


## Șterge tot ce e desenat pe pânză: simbolurile și eticheta lor.
##
## Cheamă-l ORIUNDE harta nu mai e valabilă, nu doar înainte de a o reconstrui.
## Un simbol rămas dintr-o expediție încheiată nu doar că se vede pe sub voal —
## continuă și să pulseze, fiindcă nu știe că datele din spatele lui au dispărut.
func _goleste_panza() -> void:
	for copil in panza.get_children():
		panza.remove_child(copil)
		copil.queue_free()
	simboluri_nod.clear()
	nod_survolat = -1


## Construiește simbolurile nodurilor. Poziția lor se pune în
## `_aseaza_nodurile`, fiindcă depinde de cât spațiu a primit pânza — iar asta
## se află abia după ce Godot a terminat de așezat containerele de deasupra.
##
## Starea fiecărui nod se alege AICI, într-un singur lanț de `if`-uri, și e
## singurul loc din tot ecranul care hotărăște „cum arată nodul ăsta”. Nodul nu
## întreabă expediția nimic; primește o stare și o desenează.
##
## Pe lângă stare, nodul primește și „te-ai consumat?” (`terminat`). Sunt două
## întrebări, nu una: starea spune unde stă figura, `terminat` spune ce s-a
## întâmplat acolo. Nodul CURENT răspunde da la amândouă — deci se desenează
## cu aură ȘI cu X, ca pe harta de referință, unde figura stă pe un loc deja
## tăiat. Regula lui `terminat` e „ai intrat deja în el”, adică apare în
## `parcurse` — iar `intra_in_nod()` pune nodul acolo chiar în clipa în care îl
## alegi. Asta e corect atâta vreme cât harta se desenează DOAR între noduri:
## o luptă înlocuiește scena hărții cu totul, iar Magazinul și Odihna se
## redesenează dinadins ca „parcurse” sub voal (vezi `_arata_magazin`), ca să
## fie deja tăiate când voalul se ridică. Singurul caz care ar sparge regula
## vine odată cu save-ul (pasul 8): un save făcut în mijlocul unei lupte
## trebuie să se întoarcă ÎN LUPTĂ, nu pe hartă — altfel nodul ar apărea tăiat
## înainte să fi fost jucat.
func _construieste_harta() -> void:
	_goleste_panza()
	var accesibile := Expeditie.accesibile()

	for nod in Expeditie.harta:
		var id := int(nod["id"])
		# Ordinea contează: nodul curent e ȘI parcurs, deci trebuie întrebat
		# primul, altfel aura caldă n-ar apărea niciodată.
		var stare := SimbolNod.Stare.INCHIS
		if id == Expeditie.pozitie:
			stare = SimbolNod.Stare.CURENT
		elif id in Expeditie.parcurse:
			stare = SimbolNod.Stare.PARCURS
		elif id in accesibile:
			stare = SimbolNod.Stare.ACCESIBIL

		# A doua întrebare, independentă de lanțul de sus: nodul e consumat?
		# `parcurse` îl conține și pe cel curent, deci răspunsul e da și pentru
		# el — fix ce ne trebuie ca să-i desenăm X-ul fără să-i luăm aura.
		var terminat := id in Expeditie.parcurse

		var simbol := SimbolNod.new()
		simbol.size = MARIME_NOD
		simbol.configureaza(
			id, int(nod["tip"]), stare, int(nod["samanta"]), terminat
		)
		simbol.apasat.connect(_pe_nod_apasat)
		simbol.survolat.connect(_pe_nod_survolat)
		panza.add_child(simbol)
		simboluri_nod[id] = simbol

	# Adăugată ULTIMA, deci desenată peste toate simbolurile: un nod vecin n-are
	# cum să treacă peste eticheta care tocmai a apărut.
	_creeaza_eticheta_nod()
	_aseaza_nodurile()


## Eticheta de hover: numele nodului și ce te așteaptă acolo.
##
## Textul nodurilor nu mai stă permanent pe hartă (patru cuvinte scrise peste
## pergament în zece locuri = zgomot). Simbolul spune TIPUL dintr-o privire;
## numele și descrierea sunt pentru clipa în care chiar te uiți la un nod anume.
##
## Nu are fond: are CONTUR crem în jurul literelor. Un dreptunghi opac ar fi un
## petic de interfață lipit pe hartă; conturul face literele lizibile peste
## orice textură, fără să acopere nimic.
func _creeaza_eticheta_nod() -> void:
	eticheta_nod = VBoxContainer.new()
	eticheta_nod.visible = false
	# IGNORE: eticheta apare exact sub cursor, iar dacă ar prinde ea mouse-ul,
	# nodul de dedesubt ar crede că i-ai ieșit de pe el — ar clipi la nesfârșit.
	eticheta_nod.mouse_filter = Control.MOUSE_FILTER_IGNORE
	eticheta_nod.add_theme_constant_override("separation", 1)

	eticheta_nod_nume = _eticheta_pe_pergament(16, CULOARE_TEXT)
	eticheta_nod_rol = _eticheta_pe_pergament(13, CULOARE_TEXT_SLAB)
	eticheta_nod.add_child(eticheta_nod_nume)
	eticheta_nod.add_child(eticheta_nod_rol)

	panza.add_child(eticheta_nod)


## O etichetă scrisă cu cerneală și conturată cu crem, lată cât să se poată
## rupe pe două rânduri.
func _eticheta_pe_pergament(marime: int, culoare: Color) -> Label:
	var eticheta := Label.new()
	eticheta.custom_minimum_size = Vector2(LATIME_ETICHETA, 0)
	eticheta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eticheta.add_theme_font_size_override("font_size", marime)
	eticheta.add_theme_color_override("font_color", culoare)
	eticheta.add_theme_color_override("font_outline_color", CULOARE_CONTUR)
	eticheta.add_theme_constant_override("outline_size", GROSIME_CONTUR)
	return eticheta


## Arată sau ascunde eticheta nodului survolat.
##
## Se arată pentru ORICE nod, inclusiv pentru cele în care nu poți intra: „ce
## mă așteaptă pe drumul pe care NU-l pot lua acum" e exact informația care
## face alegerea de la pasul următor o decizie.
func _pe_nod_survolat(id: int, intrat: bool) -> void:
	if not intrat:
		# Numai dacă mouse-ul a ieșit din nodul pe care chiar îl arătam: dacă a
		# intrat deja în altul, eticheta e a celuilalt acum.
		if id == nod_survolat:
			nod_survolat = -1
			eticheta_nod.visible = false
		return

	nod_survolat = id
	var date_tip := Expeditie.date_nod(int(Expeditie.harta[id]["tip"]))
	eticheta_nod_nume.text = String(date_tip["nume"]).to_upper()
	eticheta_nod_rol.text = String(date_tip["descriere"])
	eticheta_nod.visible = true
	# `reset_size()` strânge cutia la cât ocupă textul ACUM. Fără el, eticheta
	# ar păstra mărimea de la nodul dinainte și s-ar centra greșit.
	eticheta_nod.reset_size()
	_aseaza_eticheta(id)


## Sub nod, centrată pe el — dar întotdeauna în pânză. Un nod de pe marginea
## de jos și-ar arăta eticheta în afara ecranului, deci acolo o punem deasupra.
func _aseaza_eticheta(id: int) -> void:
	var simbol: Control = simboluri_nod[id]
	var centru := simbol.position + MARIME_NOD * 0.5
	var marime := eticheta_nod.size

	var loc := Vector2(
		centru.x - marime.x * 0.5,
		centru.y + MARIME_NOD.y * 0.42
	)
	if loc.y + marime.y > panza.size.y:
		loc.y = centru.y - MARIME_NOD.y * 0.42 - marime.y
	loc.x = clampf(loc.x, 0.0, maxf(0.0, panza.size.x - marime.x))
	eticheta_nod.position = loc


## Pune fiecare nod la locul lui și cere pânzei liniile dintre ele.
##
## Adâncimea 0 e în STÂNGA, capătul în dreapta — vezi nota de la
## `ZONA_PERGAMENT`. Coloana nodului devine poziția lui pe verticală.
func _aseaza_nodurile() -> void:
	if simboluri_nod.is_empty():
		return

	var zona := _zona_utila()
	if zona.size.x <= 0.0 or zona.size.y <= 0.0:
		return   # încă nu s-a așezat nimic; semnalul `resized` ne mai cheamă o dată

	# Geometria se face O SINGURĂ DATĂ și se dă mai departe și nodurilor, și
	# drumurilor. Dacă fiecare și-ar face-o pe a lui, două curbe construite din
	# aceleași puncte ar fi egale azi și diferite în ziua în care cineva strecoară
	# un zar în construcție — iar drumurile n-ar mai porni exact din noduri.
	var geo := _geometria(zona)
	var centre: Dictionary = geo["centre"]

	for id_nod in centre:
		var id := int(id_nod)
		if not simboluri_nod.has(id):
			continue
		var simbol: Control = simboluri_nod[id]
		simbol.position = centre[id] - MARIME_NOD * 0.5
		simbol.size = MARIME_NOD

	panza.arata(_muchii(geo["drumuri"]))


## De unde vine geometria hărții CURENTE.
##
## Întrebarea se pune o singură dată, aici, și se pune STĂRII (`Expeditie.plansa`),
## nu comutatorului (`Expeditie.SURSA_HARTII`). Diferența contează la save: o
## expediție pornită pe o planșă trebuie să se deseneze pe planșa aia și după ce
## comutatorul a fost mutat înapoi pe „generată”.
func _geometria(zona: Rect2) -> Dictionary:
	if Expeditie.plansa == "":
		return geometrie_pe_panglica(Expeditie.harta, zona)

	var geo := geometrie_desenata(
		Expeditie.harta, Plansa.incarca(Expeditie.plansa), zona)

	# Excepția din colțul de jos-dreapta, aplicată PESTE geometria desenată.
	# Drumurile sunt îndreptate odată cu nodul, deci `_muchii()` de după
	# primește forme gata mutate și le taie la cerneală ca pe oricare altele.
	#
	# DE CE NU ȘI PE PANGLICĂ, deși funcția n-ar avea nimic împotrivă: acolo
	# poziția nu e o alegere, e rezultatul unui sistem cu regulile lui (benzi,
	# ordinea lor, abaterea potolită ca să nu se inverseze). Măsurat pe 300 de
	# semințe în `tools/verifica_coltul.gd`, regula ar împinge nodul cu până la
	# 326 px și l-ar lipi de vecin la fix 72 px — fiindcă panglica își termină
	# ultimul strat departe de marginea din dreapta, INTENȚIONAT. N-au ieșit
	# încrucișări, dar un sistem care are deja un răspuns nu are nevoie de al
	# doilea. Pe planșă nu există niciun sistem de stricat: nodurile sunt puse
	# cu mâna, iar singurele reguli sunt cele pe care regula asta le verifică
	# ea însăși — carte, vecini, pânză.
	impinge_nodul_de_jos_dreapta(
		Expeditie.harta, geo["centre"], geo["drumuri"],
		_pergamentul_in_panza(), panza.size.x)
	return geo


## Dreptunghiul texturii de fundal, mutat în coordonatele PÂNZEI.
##
## `Pergament` se întinde peste toată fereastra și cu `STRETCH_SCALE`, deci o
## fracțiune din imagine e aceeași fracțiune din dreptunghiul lui — de-aia
## `CARTE_SUS` / `CARTE_JOS` se pot da în fracțiuni și rămân corecte la orice
## mărime de fereastră, fără nicio recalculare.
func _pergamentul_in_panza() -> Rect2:
	var cutia := pergament.get_global_rect()
	cutia.position -= panza.global_position
	return cutia


## PANGLICA MĂSURATĂ — curba centrală, plus tot ce trebuie ca s-o poți folosi
## ca sistem de coordonate.
##
## E o clasă, nu doar un `Curve2D`, pentru un motiv de viteză pe care l-am
## aflat măsurând. `Curve2D.sample_baked()` face o CĂUTARE la fiecare apel (ca
## să afle între ce două bucățele cade lungimea cerută). Un singur drum are
## peste o sută de puncte, iar fiecare punct are nevoie de trei apeluri: el
## însuși și cei doi vecini din care iese tangenta. Pe o hartă întreagă ies
## zeci de mii de căutări, iar la verificarea pe 300 de semințe, milioane.
##
## Calculate O DATĂ, la pași egali de lungime, și ținute în două șiruri, toate
## întrebările de mai târziu devin „ia elementul i și interpolează spre i+1”.
## Asta e o idee generală, nu un truc: când aceeași funcție scumpă e chemată de
## multe ori pe același domeniu, o tabelezi.
class Panglica:
	extends RefCounted

	## Punctele curbei centrale, la `pas` pixeli de arc unul de altul.
	var puncte := PackedVector2Array()
	## Normala în fiecare din punctele de mai sus. Vezi `_normale()`.
	var normale := PackedVector2Array()
	## Lungimea totală a curbei, în pixeli.
	var lungime := 0.0
	## Distanța (de arc) dintre două elemente ale șirurilor.
	var pas := 1.0

	## Porțiunile pe care au voie să stea noduri: perechi (început, sfârșit), în
	## pixeli de arc. Vezi `_afla_portiunile()`.
	var portiuni: Array[Vector2] = []
	## Lungimea lor însumată — „drumul folosibil”.
	var lungime_utila := 0.0

	func _init(curba: Curve2D, pas_cerut: float, raza_minima := 0.0, marja := 0.0) -> void:
		lungime = curba.get_baked_length()
		var cate := maxi(2, int(ceil(lungime / maxf(pas_cerut, 0.5))) + 1)
		# Pasul se recalculează după ce știm câte puncte intră: așa ultimul
		# punct cade EXACT pe capătul curbei, iar împărțirea `s / pas` de mai
		# jos e valabilă peste tot, fără un caz special la sfârșit.
		pas = lungime / float(cate - 1)
		for i in range(cate):
			puncte.append(curba.sample_baked(pas * float(i), true))
		_normale(cate)
		_afla_portiunile(raza_minima, marja)

	## RAZA CERCULUI care trece prin trei puncte de pe curbă, luate la `PAS_RAZA`
	## unul de altul. E măsura „cât de strânsă e cotitura aici”.
	##
	## Trei puncte pe o dreaptă dau un triunghi de suprafață zero, adică rază
	## infinită — exact ce vrei pe porțiunile drepte. Formula e cea clasică:
	## raza cercului circumscris = produsul laturilor / (4 × aria).
	func raza(s: float) -> float:
		var a := centru(s - PAS_RAZA)
		var b := centru(s)
		var c := centru(s + PAS_RAZA)
		var arie: float = absf((b - a).cross(c - a)) * 0.5
		if arie < 0.000001:
			return INF
		return (a.distance_to(b) * b.distance_to(c) * c.distance_to(a)) / (4.0 * arie)

	## UNDE AU VOIE SĂ STEA NODURILE: porțiunile aproape drepte.
	##
	## Se merge din pas în pas pe curbă și se strâng laolaltă bucățile unde raza
	## cotiturii e destul de mare. Apoi fiecare bucată se scurtează cu `marja` la
	## capetele care dau într-o cotitură — fiindcă abaterea de-a lungul și
	## forfecarea mai mută nodul înainte-înapoi, iar un nod care iese din bucată
	## ar cădea exact în cotitura pe care încercăm s-o ocolim.
	##
	## Capetele PANGLICII (s = 0 și s = lungime) nu se scurtează: acolo nu e
	## nicio cotitură, iar Startul și Bossul trebuie să rămână fix pe ele.
	##
	## `raza_minima` = 0 înseamnă „toată panglica e bună” — cazul VALULUI și al
	## POTCOAVEI, unde nu există cotitură prea strânsă. Atunci iese o singură
	## porțiune, [0, lungime], iar așezarea e identică cu cea de dinainte.
	func _afla_portiunile(raza_minima: float, marja: float) -> void:
		portiuni.clear()
		var inceput := -1.0
		var s := 0.0
		while s <= lungime:
			var buna := raza_minima <= 0.0 or raza(s) >= raza_minima
			if buna and inceput < 0.0:
				inceput = s
			elif not buna and inceput >= 0.0:
				_adauga_portiune(inceput, s - pas, marja)
				inceput = -1.0
			s += pas
		if inceput >= 0.0:
			_adauga_portiune(inceput, lungime, marja)

		if portiuni.is_empty():
			# PLASA, și una care trebuie să se audă. Se ajunge aici doar dacă
			# pragul de rază e mai mare decât orice loc de pe panglică — adică
			# panglica e prea îngustă pentru forfecarea cerută, și nicio bucată
			# de drum nu e destul de dreaptă. Harta tot se desenează (jocul nu
			# are voie să rămână fără hartă), dar nodurile ajung și în cotituri,
			# unde se vor înghesui.
			#
			# M-a costat o măsurătoare: la k = 1,9 pe o panglică de 50 px,
			# `raza_minima_noduri` iese infinit, plasa se activa în tăcere, iar
			# raportul arăta „o porțiune, toată panglica” — care seamănă leit cu
			# „totul e în regulă”. De-aia scrie acum în consolă.
			push_warning("Panglica: nicio porțiune destul de dreaptă. "
				+ "Panglica e prea îngustă pentru forfecarea cerută.")
			portiuni.append(Vector2(0.0, lungime))

		lungime_utila = 0.0
		for portiune in portiuni:
			lungime_utila += portiune.y - portiune.x

	func _adauga_portiune(de_la: float, pana_la: float, marja: float) -> void:
		if de_la > 0.0:
			de_la += marja
		if pana_la < lungime:
			pana_la -= marja
		if pana_la - de_la > 1.0:
			portiuni.append(Vector2(de_la, pana_la))

	## LUNGIMEA UTILĂ, ca sistem de coordonate: `f` de la 0 la 1 înseamnă „atât
	## din drumul pe care se poate sta", iar cotiturile nu se pun la socoteală.
	##
	## Efectul e exact cel cerut: straturile se împart între drepte PROPORȚIONAL
	## CU LUNGIMEA lor, fără să fie nevoie să numeri tu câte pui pe fiecare. O
	## dreaptă de două ori mai lungă primește de două ori mai multe straturi,
	## fiindcă ocupă de două ori mai mult din scara asta.
	func s_la_fractie(f: float) -> float:
		var tinta := clampf(f, 0.0, 1.0) * lungime_utila
		for portiune in portiuni:
			var cat: float = portiune.y - portiune.x
			if tinta <= cat:
				return portiune.x + tinta
			tinta -= cat
		return portiuni[portiuni.size() - 1].y

	## NORMALA: tangenta rotită cu 90°, MEREU ÎN ACELAȘI SENS.
	##
	## „Mereu în același sens” e singurul lucru care contează aici. Dacă normala
	## s-ar întoarce undeva pe drum, banda de sus ar deveni banda de jos fix în
	## punctul ăla, iar toate drumurile care trec pe acolo s-ar încrucișa.
	## Rotind întotdeauna cu +90° (în 2D, cu y în jos, asta înseamnă „spre
	## dreapta drumului"), sensul nu are cum să se schimbe.
	##
	## Tangenta se măsoară prin DIFERENȚĂ FINITĂ: încotro se duce curba dacă mai
	## fac un pas mic? E metoda pe care ai folosi-o cu creionul, și e de-ajuns —
	## derivata analitică a unei Bézier n-ar schimba nimic vizibil.
	func _normale(cate: int) -> void:
		for i in range(cate):
			var a: Vector2 = puncte[maxi(i - 1, 0)]
			var b: Vector2 = puncte[mini(i + 1, cate - 1)]
			var tangenta := b - a
			if tangenta.length() < 0.00001:
				normale.append(Vector2.DOWN)
			else:
				normale.append(tangenta.normalized().rotated(PI * 0.5))

	## Punctul de pe curba centrală, la `s` pixeli de la început.
	func centru(s: float) -> Vector2:
		return _citeste(puncte, s)

	## Normala la `s`. Re-normalizată fiindcă media a două direcții vecine e
	## puțin mai scurtă decât 1 — nu contează la desen, contează la înmulțit cu
	## o lățime de bandă.
	func normala(s: float) -> Vector2:
		return _citeste(normale, s).normalized()

	## COORDONATELE HĂRȚII, într-o singură funcție: mergi `s` pixeli pe curbă,
	## apoi ieși `dec` pixeli în lateral.
	func punct(s: float, dec: float) -> Vector2:
		return centru(s) + normala(s) * dec

	## Același lucru, dar cu stratul înclinat: cu cât ieși mai în lateral, cu
	## atât ai mers și mai departe pe drum. O singură linie, și e SINGURUL loc
	## din tot codul unde se aplică forfecarea — și nodurile, și drumurile trec
	## pe aici. Vezi `FORFECARI` pentru de ce asta nu poate crea încrucișări.
	func punct_forfecat(s: float, dec: float, k: float) -> Vector2:
		return punct(s + k * dec, dec)

	func _citeste(sir: PackedVector2Array, s: float) -> Vector2:
		var f := clampf(s, 0.0, lungime) / pas
		var i := clampi(int(f), 0, sir.size() - 1)
		var j := mini(i + 1, sir.size() - 1)
		return sir[i].lerp(sir[j], f - float(i))


## Construiește panglica pe zona dată.
##
## Tangentele punctelor de trecere se calculează Catmull-Rom: mânerul din
## punctul `i` arată de la vecinul dinainte spre vecinul de după, scurtat la a
## șasea parte. La capete nu există un vecin, deci se folosește punctul însuși —
## ceea ce face curba să intre și să iasă drept, nu strâmb.
##
## E `static` fiindcă nu atinge niciun nod de interfață: aceeași funcție poate
## fi chemată dintr-un test headless, fără fereastră și fără scenă.
##
## `traseu` are o valoare implicită ca să nu fie nevoie s-o dea nimeni din joc:
## acolo e mereu `TRASEU`. Verificarea headless o dă explicit, fiindcă ea
## trebuie să măsoare amândouă traseele în aceeași rulare.
static func panglica(zona: Rect2, traseu := TRASEU) -> Panglica:
	var puncte := []
	for reper in repere_traseu(traseu):
		puncte.append(zona.position + Vector2(reper) * zona.size)

	var curba := curba_neteda(puncte)

	# Cât de departe de locul lui „de manual” poate ajunge un nod pe lungime:
	# abaterea organică plus cât îl mută forfecarea. Cu atât se scurtează
	# porțiunile drepte la capetele dinspre cotituri.
	var latime := latime_panglica(zona, traseu)
	var k := forfecare(traseu)
	var marja := ABATERE_MAXIMA_LUNG + k * abatere_maxima_dec(latime)
	return Panglica.new(curba, PAS_MASURARE, raza_minima_noduri(latime, k), marja)


## O CURBĂ NETEDĂ CARE TRECE PRIN TOATE PUNCTELE DATE — Catmull-Rom.
##
## Aceeași funcție pentru două lucruri care par foarte diferite: curba centrală
## a panglicii (dintr-un traseu scris în cod) și fiecare drum al unei planșe
## desenate (dintr-o listă de puncte scrisă în fișier). Sunt același lucru:
## „am niște puncte, treci prin ele fără colțuri”.
##
## CUM: fiecare punct primește două mânere pe ACEEAȘI direcție — de la vecinul
## dinainte spre cel de după. Asta e ce face curba netedă: mânerul cu care intri
## și cel cu care ieși sunt coliniare, deci nu se rupe panta. La capete nu există
## un vecin, deci se folosește punctul însuși — curba intră și iese drept.
##
## LUNGIMEA mânerelor e proporțională cu segmentul de lângă FIECARE, nu aceeași
## în ambele părți, și asta a costat o măsurătoare ca s-o aflu.
##
## Varianta simplă (un singur mâner, `(dupa - inainte) / 6`) merge cât timp
## punctele sunt răsfirate egal. La POTCOAVĂ nu sunt: culoarele au puncte din
## 112 în 112 px, iar cotitura din 49 în 49. Fix la trecerea dintre ele, mânerul
## scurt al cotiturii trebuia să ducă o schimbare de direcție de-a lungul unui
## segment lung — iar un mâner scurt care trebuie să întoarcă mult înseamnă o
## cotitură strânsă. Raza măsurată acolo ieșea 79 px în loc de 125, și nu se
## repara îndesind cotitura (am încercat: 79,2 → 79,0), fiindcă problema nu era
## cotitura, ci SALTUL de densitate dintre ea și culoar.
##
## Cu mânere pe măsura fiecărui segment, saltul dispare: partea dinspre culoar
## primește mâner lung, partea dinspre cotitură mâner scurt, iar curbura trece
## lin dintr-una în alta. Când segmentele sunt egale, formula dă exact ce dădea
## cea veche — deci e o generalizare, nu o schimbare de formă.
##
## Pentru o planșă desenată de mână, regula asta e și mai folositoare: acolo
## punctele sunt puse cu ochiul, deci NICIODATĂ răsfirate egal. Un drum cu două
## puncte dese pe o cotitură și unul lung după ea iese exact cum l-ai desenat.
static func curba_neteda(puncte: Array) -> Curve2D:
	var curba := Curve2D.new()
	curba.bake_interval = PAS_MASURARE
	for i in range(puncte.size()):
		var aici: Vector2 = puncte[i]
		var inainte: Vector2 = puncte[maxi(i - 1, 0)]
		var dupa: Vector2 = puncte[mini(i + 1, puncte.size() - 1)]

		# DIRECȚIA tangentei: de la vecinul dinainte spre cel de după.
		var directie := dupa - inainte
		if directie.length() < 0.00001:
			directie = Vector2.RIGHT
		directie = directie.normalized()

		var spre_inapoi := aici.distance_to(inainte) * NETEZIRE_PANGLICA
		var spre_inainte := aici.distance_to(dupa) * NETEZIRE_PANGLICA
		curba.add_point(aici, -directie * spre_inapoi, directie * spre_inainte)
	return curba


## Cât de lată are voie să fie panglica pe zona asta.
##
## Lățimea e în pixeli (ține de mărimea unui nod), iar traseul e în fracțiuni
## (ține de forma hârtiei). Pe o fereastră mică, fracțiunile se strâng singure,
## pixelii nu — deci benzile ar ieși de pe hârtie. Limita de mai jos e plasa: pe
## fereastra implicită nu se activează (148 din 397 înseamnă 37%), pe una mică
## strânge panglica în loc s-o lase să dea pe afară.
static func latime_panglica(zona: Rect2, traseu := TRASEU) -> float:
	var ceruta: float = LATIMI_PANGLICA.get(traseu_de_baza(traseu), 148.0)
	return minf(ceruta, zona.size.y * PROPORTIE_MAXIMA_PANGLICA)


## Cât de tare e înclinat stratul pe traseul ăsta. 0 = perpendicular, ca înainte.
static func forfecare(traseu := TRASEU) -> float:
	return float(FORFECARI.get(traseu_de_baza(traseu), 0.0))


## DIN CE TRASEU E FĂCUT TRASEUL ĂSTA.
##
## Un traseu oglindit are exact geometria originalului: aceleași lungimi,
## aceleași raze de cotitură, aceeași înălțime ocupată — o oglindă nu schimbă
## nicio distanță. Deci și lățimea panglicii, și forfecarea, sunt ale
## originalului, iar tabelele `LATIMI_PANGLICA` și `FORFECARI` nu au nevoie de
## rânduri noi.
##
## Alternativa ar fi fost să copiez `Traseu.POTCOAVA_OGLINDITA: 104.0` în
## amândouă tabelele. Merge azi și minte mâine: reglez 104 într-un loc, uit
## celălalt, și ies două potcoave cu panglici de lățimi diferite — o diferență
## care se vede pe ecran, dar pe care n-ai s-o cauți în tabel.
##
## Pentru un traseu care nu e oglinda nimănui, răspunsul e el însuși, deci
## funcția se poate chema peste tot fără să întrebi întâi dacă e cazul.
static func traseu_de_baza(traseu := TRASEU) -> int:
	return int(OGLINDIRI.get(traseu, traseu))


## PUNCTELE DE TRECERE ale unui traseu, gata oglindite dacă e cazul.
##
## Singurul loc din fișier care știe care tabel de puncte aparține cărui traseu.
## `panglica()` cere puncte și primește puncte; nu are de unde ști — și nici de
## ce să știe — că unele au trecut printr-o oglindă pe drum.
static func repere_traseu(traseu := TRASEU) -> Array:
	var repere: Array = TRASEU_VAL
	match traseu_de_baza(traseu):
		Traseu.SARPE:
			repere = TRASEU_SARPE
		Traseu.POTCOAVA:
			repere = TRASEU_POTCOAVA

	if not OGLINDIRI.has(traseu):
		return repere

	# Reperele sunt FRACȚIUNI din zona utilă (0..1), deci oglinda pe verticala
	# din mijlocul hârtiei e chiar `x → 1 − x`. Dacă ar fi fost pixeli, ar fi
	# trebuit `zona.position.x * 2 + zona.size.x - x` — încă un motiv pentru
	# care traseele se țin în fracțiuni.
	var intoarse := []
	for reper in repere:
		intoarse.append(Vector2(1.0 - reper.x, reper.y))
	return intoarse


## CÂT TREBUIE SĂ RĂMÂNĂ ÎNTRE DOUĂ BENZI, ca nodurile lor să nu se atingă.
##
## Fără forfecare răspunsul e simplu: `DISTANTA_MINIMA_BANDA`, adică o înălțime
## de nod. Cu forfecare, o parte din distanță vine din LUNGIME, deci lateral e
## nevoie de mai puțin — dar cu cât mai puțin, exact?
##
## Două noduri de pe același strat, despărțite lateral de `x`, sunt despărțite
## de-a lungul de `k·x` din forfecare. Numai că fiecare primește și o abatere
## organică DE-A LUNGUL, independentă de a celuilalt (±`ABATERE_MAXIMA_LUNG`),
## iar în cel mai rău caz cele două abateri se apropie una de alta și MĂNÂNCĂ
## din despărțirea dată de forfecare — până la `2 × ABATERE_MAXIMA_LUNG`.
##
## Deci partea de-a lungul, în cel mai rău caz, e `k·x − 2a` (și zero dacă
## abaterile o pot anula cu totul), iar condiția e
##
##     (k·x − 2a)² + x² ≥ minim²
##
## o ecuație de gradul doi în `x`, rezolvată mai jos. Pentru `k = 0` iese exact
## `x ≥ minim`, adică fix regula dinainte — deci traseele neforfecate nu simt
## nimic din codul ăsta.
##
## `c` e cât se scurtează partea de-a lungul din cauza cotiturii (1 pe dreaptă);
## vezi `raza_minima_noduri()`, care folosește aceeași formulă pe dos.
##
## Costul abaterii de-a lungul, în cifre: la ȘARPE, fără ea `k` ar fi putut
## rămâne 1,6; cu ea, trebuie 2,0. Am păstrat-o, fiindcă altfel toate nodurile
## unui strat ar sta pe o diagonală perfectă și s-ar vedea rigla.
static func dec_minim(k: float, c := 1.0) -> float:
	var a := 2.0 * ABATERE_MAXIMA_LUNG
	var d := DISTANTA_MINIMA_BANDA
	var kc := k * c
	if kc <= 0.0:
		return d
	# Sub discriminant nu se poate ajunge negativ: `d² > 0` face termenul
	# `(kc² + 1)(a² − d²)` negativ ori de câte ori `a < d`, iar `a` e de
	# șaisprezece pixeli, `d` de nouăzeci și patru.
	var sub := kc * kc * a * a - (kc * kc + 1.0) * (a * a - d * d)
	var x := (kc * a + sqrt(maxf(sub, 0.0))) / (kc * kc + 1.0)
	# Dacă forfecarea e prea slabă ca să depășească abaterea, nu ajută deloc.
	if kc * x <= a:
		return d
	return x


## SUB CE RAZĂ DE COTITURĂ NU SE AȘAZĂ NODURI.
##
## Nu e o constantă ghicită, ci pragul CALCULAT din cât de mult se sprijină
## traseul pe forfecare. Merită urmărit raționamentul, fiindcă prima variantă
## (un 90 pus cu ochiul) trecea toate verificările în afară de una — și exact
## aia spunea adevărul.
##
## Într-o cotitură de rază R, banda dinspre interior are raza R − dec, deci
## orice bucată de drum de pe ea se scurtează cu factorul c = (R − dec) / R.
## Partea LATERALĂ nu se scurtează, partea DE-A LUNGUL da — iar forfecarea își
## ține toată contribuția în partea de-a lungul. Cu alte cuvinte: cu cât
## cotitura e mai strânsă, cu atât forfecarea ajută mai puțin.
##
## Aici se rezolvă `dec_minim(k, c) = lățime` pentru `c`, apoi `c` pentru `R`.
## Două lucruri bune ies pe gratis:
##
##   Un traseu FĂRĂ forfecare (k = 0) are `lățime ≥ minim` prin construcție,
##   condiția e adevărată oricare ar fi R, iar pragul iese 0: toată panglica e
##   folosibilă. VALUL și POTCOAVA se așază exact ca înainte, fără nicio
##   excepție scrisă undeva pentru ele.
##
##   Un traseu care se sprijină TARE pe forfecare cere, singur, drepte tot mai
##   lungi. Nu trebuie reglat de mână pe fiecare traseu: cere exact cât are
##   nevoie, și cu asta se așază doar pe drepte.
static func raza_minima_noduri(latime: float, k: float) -> float:
	if k <= 0.0 or latime >= DISTANTA_MINIMA_BANDA:
		return 0.0
	var a := 2.0 * ABATERE_MAXIMA_LUNG
	var d := DISTANTA_MINIMA_BANDA
	# Cât trebuie să dea partea de-a lungul, ca împreună cu `lățime` să ajungă
	# la `d`. Din (k·c·lățime − a)² + lățime² = d².
	var de_a_lungul := a + sqrt(d * d - latime * latime)
	var c_minim := de_a_lungul / (k * latime)
	if c_minim >= 1.0:
		return INF   # nici pe dreaptă nu ajunge: niciun loc nu e bun
	return abatere_maxima_dec(latime) / (1.0 - c_minim)


## CEA MAI MARE ABATERE LATERALĂ la care poate ajunge un nod: banda plus
## organicul.
##
## Un singur loc care o calculează, fiindcă trei lucruri au nevoie de ea și ar
## fi trei ocazii să se dezacordeze: cât de departe de curbă poate ajunge un
## nod (verificarea de fold-over), cât de mult poate muta forfecarea un nod pe
## lungime, și cât spațiu îi trebuie panglicii pe hârtie.
static func abatere_maxima_dec(latime: float) -> float:
	var pas_dec := latime / float(maxi(Expeditie.NODURI_PE_STRAT - 1, 1))
	return latime * 0.5 + minf(pas_dec * ABATERE_LAT, ABATERE_MAXIMA_LAT)


## AȘEZAREA: pentru fiecare nod, unde cade pe panglică.
##
## Întoarce „id de nod → { s, dec, centru }”. Nu doar centrul, fiindcă
## drumurile au nevoie de coordonatele PE PANGLICĂ ale capetelor: un drum se
## desenează mergând pe curbă de la un `s` la altul, nu tăind în linie dreaptă
## printre ele. Dacă i-aș da pânzei doar două centre, ea ar trebui să ghicească
## panglica înapoi din ele — ceea ce nu se poate, fiindcă prin două puncte trec
## o mie de curbe.
##
## Primește harta ca parametru (nu citește `Expeditie.harta` singură) ca să
## poată fi chemată cu o hartă inventată, dintr-un test.
static func asezare(harta: Array, pang: Panglica, latime: float, k := 0.0) -> Dictionary:
	var straturi := 1
	# „Cine e pe stratul ăsta”, în ordinea coloanei. Am nevoie de STRATUL
	# întreg, nu doar de câte noduri are, fiindcă abaterea laterală nu se poate
	# hotărî nod cu nod — vezi `_potoleste_abaterea`.
	var pe_strat := {}
	for nod in harta:
		var a := int(nod["adancime"])
		straturi = maxi(straturi, a + 1)
		if not pe_strat.has(a):
			pe_strat[a] = []
		pe_strat[a].append(nod)
	for a in pe_strat:
		pe_strat[a].sort_custom(func(x, y): return int(x["coloana"]) < int(y["coloana"]))

	# Cât drum revine unui strat, și cât spațiu lateral unei benzi. De aici se
	# calculează cât are voie să bată abaterea organică: legată de distanța
	# dintre vecini, nu de un număr fix de pixeli, ca harta să arate la fel de
	# „așezată” și pe o fereastră mică, și pe una mare.
	#
	# `pas_s` se socotește din lungimea UTILĂ (fără cotituri): e distanța dintre
	# două straturi vecine măsurată pe drumul pe care chiar stau noduri.
	var pas_s := pang.lungime_utila / float(maxi(straturi - 1, 1))
	var pas_dec := latime / float(maxi(Expeditie.NODURI_PE_STRAT - 1, 1))

	# Cât trebuie să rămână între două benzi. Cu forfecare e mai puțin decât o
	# înălțime de nod, fiindcă o parte din distanță vine din lungime — vezi
	# `dec_minim()`, care face toată socoteala, abaterea de-a lungul inclusă.
	var minim_dec := dec_minim(k)

	# Un singur generator, reînsămânțat pentru fiecare nod din sămânța LUI.
	# Dacă l-aș lăsa să curgă de la un nod la altul, abaterea nodului 5 ar
	# depinde de câte numere a cerut nodul 4 — adică s-ar schimba în ziua în
	# care adaug o singură aruncare de zar mai sus.
	var rng := RandomNumberGenerator.new()

	var rezultat := {}
	for a in pe_strat:
		var strat: Array = pe_strat[a]
		var cate := strat.size()
		# Capetele panglicii nu se clatină DELOC: Startul stă fix pe primul
		# punct de trecere și Bossul fix pe ultimul.
		#
		# De-a lungul, fiindcă altfel abaterea i-ar împinge dincolo de curbă și
		# ar trebui tăiați înapoi la loc. Lateral, fiindcă la capete normala e
		# îndreptată spre marginea hârtiei: o abatere de 25 de pixeli acolo
		# scotea nodul de Start cu 15 pixeli în afara zonei utile, pe 293 de
		# hărți din 300. Și, oricum, un strat cu un singur nod n-are ce să
		# răsfire lateral — abaterea lui nu adăuga niciun pic de dezordine
		# folositoare, doar risc.
		var e_capat: bool = int(a) == 0 or int(a) == straturi - 1

		# Întâi locurile „de manual” și abaterile dorite, separat. Nu le adun
		# încă: ca să știu cu cât trebuie potolită abaterea laterală, trebuie să
		# le văd pe toate din stratul ăsta deodată.
		var baza_dec := []
		var abateri_dec := []
		var s_uri := []
		for nod in strat:
			var coloana := int(nod["coloana"])

			# DE-A CURMEZIȘUL: benzile se răsfiră pe toată lățimea panglicii.
			# Un strat cu un singur nod (primul și ultimul) stă pe mijloc — n-ai
			# ce răsfira, iar mijlocul e locul de unde pleci și unde ajungi.
			var dec := 0.0
			if cate > 1:
				var deschidere := latime
				if int(a) % 2 == 1:
					# Strânge, dar NU sub minimul la care nodurile se ating.
					# Pe o panglică lată (248) limita nu se atinge niciodată:
					# 248 × 0,40 = 99 e peste 94. Pe una îngustă (POTCOAVA, 104)
					# se atinge imediat — 104 × 0,40 = 42 ar lipi nodurile —
					# și atunci strângerea se oprește singură la 94.
					#
					# Rezultatul e o regulă care nu trebuie reglată pe fiecare
					# traseu: „strânge cât poți, dar nu până la suprapunere”.
					# O constantă în plus pentru fiecare traseu ar fi fost încă
					# un loc unde se poate uita ceva.
					deschidere = clampf(
						latime * STRANGERE_ALTERNATA, minf(minim_dec, latime), latime)
				dec = (float(coloana) / float(cate - 1) - 0.5) * deschidere
			baza_dec.append(dec)

			rng.seed = int(nod["samanta"])
			var lung := rng.randf_range(-1.0, 1.0) * minf(
				pas_s * ABATERE_LUNG, ABATERE_MAXIMA_LUNG)
			var lat := rng.randf_range(-1.0, 1.0) * minf(
				pas_dec * ABATERE_LAT, ABATERE_MAXIMA_LAT)
			if e_capat:
				lung = 0.0
				lat = 0.0
			# DE-A LUNGUL: stratul 0 la începutul panglicii, ultimul la capăt,
			# restul împărțite egal între ele — egal pe DRUMUL FOLOSIBIL, nu pe
			# orizontală și nici măcar pe toată curba. `s_la_fractie` sare peste
			# cotituri, deci „la jumătatea drumului” înseamnă „la jumătatea
			# porțiunilor drepte".
			var fractie := float(a) / float(maxi(straturi - 1, 1))
			s_uri.append(clampf(
				pang.s_la_fractie(fractie) + lung, 0.0, pang.lungime))
			abateri_dec.append(lat)

		var potolire := _potoleste_abaterea(baza_dec, abateri_dec, minim_dec)

		for i in range(cate):
			var s: float = s_uri[i]
			var dec: float = baza_dec[i] + abateri_dec[i] * potolire
			rezultat[int(strat[i]["id"])] = {
				# `s` rămâne NEFORFECAT: e locul stratului pe panglică, același
				# pentru toate nodurile lui. Forfecarea se aplică la desen, în
				# `punct_forfecat` — și tot acolo se aplică și drumurilor, ceea
				# ce e singurul motiv pentru care ele nu se pot încrucișa.
				"s": s,
				"dec": dec,
				"centru": pang.punct_forfecat(s, dec, k),
			}

	return rezultat


## ─────────────────────────────────────────────────────────────
## GEOMETRIA HĂRȚII — un singur rezultat, două surse
##
## Întoarce mereu aceleași două lucruri, oricine le-ar fi calculat:
##
##   "centre"  — id de nod → punctul lui pe ecran
##   "drumuri" — id → { id_urmator → PackedVector2Array cu punctele drumului }
##
## Asta e granița pe care stă tot comutatorul GENERATA / DESENATA. Deasupra ei,
## ecranul așază simboluri și colorează drumuri și nu are de unde ști dacă
## nodurile vin dintr-o panglică sau dintr-un fișier. Dedesubt, cele două surse
## n-au nimic în comun și nici nu trebuie să aibă.
##
## Dacă granița ar fi fost pusă mai jos — să zicem, „planșa își face și ea o
## panglică" — ar fi trebuit să inventez o curbă centrală pentru un desen care
## n-are așa ceva. Dacă ar fi fost mai sus — „ecranul întreabă din ce sursă e” —
## fiecare funcție de desen ar fi căpătat un `if`. Locul potrivit e exact unde
## cele două surse au același răspuns de dat.
## ─────────────────────────────────────────────────────────────

## Geometria din PANGLICĂ: nodurile pe benzi, drumurile pe curbă.
static func geometrie_pe_panglica(harta: Array, zona: Rect2) -> Dictionary:
	var pang := panglica(zona)
	var k := forfecare()
	var asez := asezare(harta, pang, latime_panglica(zona), k)

	var centre := {}
	var drumuri := {}
	for nod in harta:
		var id := int(nod["id"])
		if not asez.has(id):
			continue
		centre[id] = asez[id]["centru"]

	for nod in harta:
		var id := int(nod["id"])
		if not asez.has(id):
			continue
		for id_brut in nod["spre"]:
			var urmator := int(id_brut)
			if not asez.has(urmator):
				continue
			if not drumuri.has(id):
				drumuri[id] = {}
			drumuri[id][urmator] = puncte_drum(
				pang, asez[id]["s"], asez[id]["dec"],
				asez[urmator]["s"], asez[urmator]["dec"], k)

	return {"centre": centre, "drumuri": drumuri}


## Geometria dintr-o PLANȘĂ desenată: totul citit din fișier și scalat.
##
## Nodurile își iau poziția după „reper” — id-ul text pe care `Expeditie` l-a
## pus în fiecare nod când a construit harta din planșă. Drumurile își iau
## punctele din fișier, trecute printr-o curbă netedă ca să nu se vadă colțuri.
##
## De ce drumurile se caută în PLANȘĂ și nu în câmpul „spre” al nodurilor: ca să
## nu existe două surse pentru aceeași informație. „spre” e graful — cine duce
## unde — și el e adevărul pentru NAVIGARE. Punctele sunt desenul, și el e
## adevărul pentru DESEN. Când un drum e în graf dar n-are puncte în fișier (nu
## se poate azi: `spre` e construit chiar din lista de drumuri), pur și simplu
## nu se desenează — nu se inventează o linie dreaptă care ar minți.
static func geometrie_desenata(
	harta: Array, plansa: Dictionary, zona: Rect2
) -> Dictionary:
	var cutia := Plansa.cutie(zona, float(plansa["raport"]))

	var id_al := {}       # reper → id de nod
	var centre := {}
	for nod in harta:
		var reper := String(nod.get("reper", ""))
		var id := int(nod["id"])
		id_al[reper] = id
		centre[id] = Plansa.in_pixeli(
			plansa["poz"].get(reper, Vector2.ZERO), cutia)

	var drumuri := {}
	for drum in plansa["drumuri"]:
		var de_la := String(drum["de_la"])
		var la := String(drum["la"])
		if not (id_al.has(de_la) and id_al.has(la)):
			continue   # un capăt a fost sărit (nod inaccesibil); n-are ce desena

		var puncte := []
		for fractie in drum["puncte"]:
			puncte.append(Plansa.in_pixeli(fractie, cutia))

		var id: int = id_al[de_la]
		if not drumuri.has(id):
			drumuri[id] = {}
		# `get_baked_points()` întoarce curba deja eșantionată, la `PAS_MASURARE`
		# pixeli — exact forma pe care o așteaptă pânza: un șir de puncte pe
		# care ea pune liniuțe, fără să știe ce le-a produs.
		drumuri[id][int(id_al[la])] = curba_neteda(puncte).get_baked_points()

	return {"centre": centre, "drumuri": drumuri}


## ─────────────────────────────────────────────────────────────
## NODUL DIN JUMĂTATEA DE JOS, ÎMPINS LÂNGĂ BOSS
##
## Rulează DUPĂ geometrie și înaintea desenului, pe centrele gata calculate.
## Nu atinge nimic din STRUCTURĂ: nu adaugă, nu șterge, nu releagă, nu schimbă
## adâncimi. Se schimbă o singură coordonată x, plus drumurile care ajung în ea.
##
## Funcția nu întreabă din ce sursă vine harta — la nivelul ăsta o planșă și o
## panglică au același răspuns de dat, „unde stă fiecare nod". CHEMAREA, însă,
## se face doar pe planșă; motivul e la `_geometria()`, fiindcă acolo e locul
## în care se știe de unde vine harta.
##
## ─────────────────────────────────────────────────────────────
## CINE E „NODUL ĂLA”
##
## Nu un id scris de mână — ar fi legat regula de planșa de azi și ar fi murit
## la prima hartă nouă. E o DESCRIERE: dintre nodurile aflate sub mijlocul
## hărții, cel cu x-ul cel mai mare, Bossul nefiind la socoteală.
##
## Mijlocul se ia din cutia care ține toate centrele, nu din zona utilă: cutia
## planșei se scalează uniform (vezi `Plansa.cutie()`), deci desenul aproape
## niciodată nu umple hârtia pe verticală. „Jumătatea de jos” trebuie să fie
## jumătatea DESENULUI, nu a hârtiei.
##
## ─────────────────────────────────────────────────────────────
## CE-L POATE OPRI, în ordinea în care strâng
##
##   cartea  — cotorul, măsurat la marginea de SUS și la cea de JOS a casetei;
##             e înclinat, deci cea mai strânsă dintre ele decide;
##   pânza   — un simbol care iese din dreptunghiul care-l desenează e tăiat;
##   vecinii — `DISTANTA_MINIMA_NODURI` față de orice alt centru.
##
## Dacă limitele îl țin acolo unde e deja, nodul NU se mută. E important că
## asta e un rezultat acceptabil, nu un eșec: o hartă cu nodul la locul lui
## vechi e corectă, una cu un nod peste carte nu e. Regula are voie să nu facă
## nimic; n-are voie să strice.
##
## Întoarce o fișă cu ce s-a întâmplat, ca s-o poată tipări verificatorul:
##   { "id", "x_vechi", "x_nou", "x_tinta", "x_maxim", "oprit_de" }
## `id == -1` înseamnă că n-a avut pe cine alege (hartă goală, ori fără Boss).
static func impinge_nodul_de_jos_dreapta(
	harta: Array, centre: Dictionary, drumuri: Dictionary,
	pergament: Rect2, latime_panza: float
) -> Dictionary:
	var fisa := {
		"id": -1, "x_vechi": 0.0, "x_nou": 0.0,
		"x_tinta": 0.0, "x_maxim": 0.0, "oprit_de": "",
	}
	if centre.size() < 2:
		return fisa

	var id_boss := -1
	for nod in harta:
		if int(nod["tip"]) == Expeditie.Nod.BOSS and centre.has(int(nod["id"])):
			id_boss = int(nod["id"])
	if id_boss < 0:
		return fisa

	# Mijlocul DESENULUI, pe verticală.
	var sus := INF
	var jos := -INF
	for id_brut in centre:
		var c: Vector2 = centre[id_brut]
		sus = minf(sus, c.y)
		jos = maxf(jos, c.y)
	var mijloc := (sus + jos) * 0.5

	var id_ales := -1
	for id_brut in centre:
		var id := int(id_brut)
		if id == id_boss:
			continue
		var c: Vector2 = centre[id]
		if c.y <= mijloc:
			continue
		if id_ales < 0 or c.x > float(centre[id_ales].x):
			id_ales = id
	if id_ales < 0:
		return fisa

	var centru: Vector2 = centre[id_ales]
	var jumate := MARIME_NOD * 0.5
	var tinta: float = float(centre[id_boss].x) + PESTE_BOSS

	# Cotorul e o linie înclinată, deci caseta îl atinge întâi cu unul din
	# colțuri. `minf` pe amândouă marginile nu presupune cu care.
	var limita_carte := minf(
		x_cotorului(centru.y - jumate.y, pergament),
		x_cotorului(centru.y + jumate.y, pergament)
	) - MARGINE_CARTE - jumate.x
	var limita_panza := latime_panza - jumate.x - MARGINE_PANZA
	var limita := minf(limita_carte, limita_panza)

	var x := minf(tinta, limita)
	var x_liber := _x_fara_vecini(x, centru, id_ales, centre, limita)
	# Ultima vamă. `_x_fara_vecini` CAUTĂ, nu garantează: dacă nodul e prins
	# între un vecin și carte, se întoarce cu ce-a găsit, iar aici se decide că
	# „ce-a găsit” nu e bun și nu se mută nimic.
	if x_liber > limita or not _e_liber(x_liber, centru, id_ales, centre):
		x_liber = centru.x

	fisa["id"] = id_ales
	fisa["x_vechi"] = centru.x
	fisa["x_tinta"] = tinta
	fisa["x_maxim"] = limita
	fisa["x_nou"] = maxf(x_liber, centru.x)

	if float(fisa["x_nou"]) < tinta - 0.5:
		if x >= limita - 0.5:
			fisa["oprit_de"] = "carte" if limita_carte <= limita_panza else "pânză"
		else:
			fisa["oprit_de"] = "vecin"
		if x_liber <= centru.x and x > centru.x + 0.5:
			fisa["oprit_de"] = "vecin"

	var delta := Vector2(float(fisa["x_nou"]) - centru.x, 0.0)
	if delta.x <= 0.5:
		fisa["x_nou"] = centru.x
		return fisa

	centre[id_ales] = centru + delta
	_trage_drumurile(drumuri, id_ales, delta)
	return fisa


## Unde e cotorul cărții, pe orizontală, la înălțimea `y`.
##
## `CARTE_SUS` și `CARTE_JOS` sunt două puncte de pe aceeași dreaptă, deci
## `lerpf` cu un `t` NEplafonat e răspunsul corect și în afara lor: cotorul e
## drept, nu se oprește unde s-a întâmplat să fie măsurat.
static func x_cotorului(y: float, pergament: Rect2) -> float:
	var sus := pergament.position + CARTE_SUS * pergament.size
	var jos := pergament.position + CARTE_JOS * pergament.size
	if absf(jos.y - sus.y) < 0.0001:
		return sus.x
	return lerpf(sus.x, jos.x, (y - sus.y) / (jos.y - sus.y))


## E destul de departe de toate celelalte centre un nod pus la `x`?
static func _e_liber(
	x: float, centru: Vector2, id_sarit: int, centre: Dictionary
) -> bool:
	for id_brut in centre:
		if int(id_brut) == id_sarit:
			continue
		var alt: Vector2 = centre[id_brut]
		if Vector2(x, centru.y).distance_to(alt) < DISTANTA_MINIMA_NODURI - 0.001:
			return false
	return true


## Cel mai apropiat `x` de cel cerut care nu calcă pe niciun vecin.
##
## Nodul se mișcă doar pe orizontală, deci un vecin nu interzice un PUNCT, ci un
## INTERVAL de x: cel în care distanța dintre centre ar scădea sub prag. Cât de
## lat e intervalul iese dintr-un triunghi dreptunghic — cateta orizontală de
## care e nevoie ca ipotenuza să ajungă fix la prag.
##
## Se încearcă întâi ieșirea prin DREAPTA vecinului (acolo mergeam oricum); dacă
## dincolo de el nu mai e loc până la limită, se iese prin stânga, iar mutarea
## iese mai mică sau deloc.
static func _x_fara_vecini(
	x: float, centru: Vector2, id_sarit: int, centre: Dictionary, x_max: float
) -> float:
	# Cel mult o trecere pentru fiecare vecin: fiecare ori scapă de unul, ori se
	# oprește. Fără plafon, doi vecini apropiați ar putea trimite căutarea
	# înainte și înapoi la nesfârșit.
	for _pas in range(centre.size() + 1):
		var vinovat := -1
		var nevoie := 0.0
		for id_brut in centre:
			var id := int(id_brut)
			if id == id_sarit:
				continue
			var alt: Vector2 = centre[id]
			var dy := absf(alt.y - centru.y)
			if dy >= DISTANTA_MINIMA_NODURI:
				continue   # oricât de aproape pe x, distanța verticală ajunge
			var cat := sqrt(
				DISTANTA_MINIMA_NODURI * DISTANTA_MINIMA_NODURI - dy * dy)
			if absf(x - alt.x) >= cat - 0.001:
				continue
			vinovat = id
			nevoie = cat
			break
		if vinovat < 0:
			return x
		var dupa: float = float(centre[vinovat].x) + nevoie
		x = dupa if dupa <= x_max else float(centre[vinovat].x) - nevoie
	return x


## Drumurile care ating nodul mutat, trase după el.
static func _trage_drumurile(
	drumuri: Dictionary, id_nod: int, delta: Vector2
) -> void:
	for id_brut in drumuri:
		var de_la := int(id_brut)
		for id_la_brut in drumuri[de_la]:
			var la := int(id_la_brut)
			if de_la == id_nod:
				drumuri[de_la][la] = _tras_de_capat(
					drumuri[de_la][la], true, delta)
			elif la == id_nod:
				drumuri[de_la][la] = _tras_de_capat(
					drumuri[de_la][la], false, delta)


## Un drum al cărui capăt s-a mutat cu `delta`, îndoit lin până se așază la loc.
##
## Ponderea scade de la 1 (chiar în capăt, ca drumul să rămână lipit de centrul
## nodului — de-acolo îl taie `_taiat_la_simboluri` la marginea cernelii) la 0
## după `INFLUENTA_TRAGERII` pixeli de drum. `smoothstep`, nu o scădere dreaptă:
## o pondere liniară ar lăsa un COLȚ exact acolo unde se termină influența,
## fiindcă panta ar sări de la ceva la zero dintr-o dată.
##
## Se măsoară pe lungimea de ARC, nu pe indicele punctului: punctele vin azi de
## la `get_baked_points()`, adică la pas egal, dar un drum cules altfel n-ar
## avea de ce să fie uniform, iar îndoitura n-are voie să depindă de asta.
static func _tras_de_capat(
	puncte: PackedVector2Array, la_inceput: bool, delta: Vector2
) -> PackedVector2Array:
	var n := puncte.size()
	if n == 0:
		return puncte

	var lungimi := PackedFloat32Array()
	lungimi.resize(n)
	lungimi[0] = 0.0
	var total := 0.0
	for i in range(1, n):
		total += puncte[i - 1].distance_to(puncte[i])
		lungimi[i] = total

	var raza := minf(INFLUENTA_TRAGERII, total)
	var iesire := PackedVector2Array()
	iesire.resize(n)
	if raza < 0.0001:
		# Drum de lungime zero (două noduri unul peste altul): nu e nimic de
		# îndoit, se mută tot. Nu se vede oricum, dar nici nu rămâne agățat.
		for i in range(n):
			iesire[i] = puncte[i] + delta
		return iesire

	for i in range(n):
		var d: float = lungimi[i] if la_inceput else total - lungimi[i]
		var pondere := 1.0 - smoothstep(0.0, 1.0, clampf(d / raza, 0.0, 1.0))
		iesire[i] = puncte[i] + delta * pondere
	return iesire


## PUNCTELE UNUI DRUM, calculate PE PANGLICĂ.
##
##   P(t) = C( lerp(s_a, s_b, t) ) + N(…) · lerp(dec_a, dec_b, u)
##
## Două interpolări cu doi parametri diferiți, și în asta stă toată forma:
##
##   `t` merge LINIAR înainte pe curbă — drumul avansează uniform, deci
##       urmează terenul în loc să taie peste el;
##   `u` merge AMESTECAT în lateral — trecerea de pe o bandă pe alta e lină la
##       capete, dar pornește din prima clipă (vezi `AMESTEC_LINIAR`).
##
## De ce nu mai e Bézier: o Bézier între două centre nu știe nimic despre
## teren. Pe o panglică ondulată, ea ar tăia coarda, iar drumul ar trece pe
## lângă curbă în loc să meargă pe ea — și două drumuri care taie două coarde
## diferite se pot intersecta oriunde.
##
## De ce, calculate așa, nu se pot tăia: două drumuri între aceleași straturi
## au (aproape) același `s` la același `t`, deci stau pe aceeași normală și
## diferă doar prin `dec`. Dacă unul e lateral deasupra celuilalt la plecare ȘI
## la sosire, `dec`-urile lor nu se pot întâlni la mijloc — ar însemna să se
## inverseze și apoi să se inverseze la loc, adică să se taie de două ori.
## Verificarea din `tools/verifica_harta.gd` numără exact asta, pe aceleași
## puncte pe care le desenează jocul.
##
## Întoarce puncte gata calculate. Pânza desenează liniuțe pe ele și nu are de
## unde ști — și nici de ce să știe — ce e o panglică.
static func puncte_drum(
	pang: Panglica, s_a: float, dec_a: float, s_b: float, dec_b: float, k := 0.0
) -> PackedVector2Array:
	# Cât de des măsurăm. Lungimea adevărată a drumului e între „cât înaintează”
	# și „cât înaintează plus cât se dă lateral”; a doua e o supraestimare
	# ieftină, adică doar câteva eșantioane în plus.
	var aproximativ := absf(s_b - s_a) + absf(dec_b - dec_a) * (1.0 + k)
	var esantioane := maxi(16, int(aproximativ / PAS_MASURARE))

	var puncte := PackedVector2Array()
	for i in range(esantioane + 1):
		var t := float(i) / float(esantioane)
		var u := lerpf(t, smoothstep(0.0, 1.0, t), AMESTEC_LINIAR)
		var dec := lerpf(dec_a, dec_b, u)
		# Drumul se calculează întâi NEFORFECAT — `lerpf(s_a, s_b, t)` merge
		# între `s`-urile straturilor, nu între cele ale nodurilor — și abia
		# punctul gata calculat e forfecat. Ordinea asta e ce face argumentul de
		# la `FORFECARI` valabil: forfecarea se aplică drumului ÎNTREG, ca o
		# transformare a planului, nu doar capetelor lui.
		puncte.append(pang.punct_forfecat(lerpf(s_a, s_b, t), dec, k))
	return puncte


## CÂT DIN ABATEREA LATERALĂ ARE VOIE SĂ RĂMÂNĂ, într-un strat.
##
## Întoarce un număr între 0 și 1 cu care se înmulțesc toate abaterile laterale
## din stratul ăla.
##
## ─────────────────────────────────────────────────────────────
## DE CE E NEVOIE DE EL
##
## Abaterea organică se trage la sorți nod cu nod. Dacă nodul de pe banda de
## sus e împins spre cea de jos și cel de jos spre cea de sus, între ei rămâne
## mai puțin decât o înălțime de nod: se suprapun și, mai rău, uneori se
## INVERSEAZĂ — cel de pe coloana 0 ajunge dincolo de cel de pe coloana 1.
##
## Asta strică tot ce am câștigat în altă parte: graful poate fi curat, dar dacă
## nodurile își schimbă locurile pe bandă, drumurile se taie la desenare.
##
## ─────────────────────────────────────────────────────────────
## DE CE ÎNMULȚIM TOT STRATUL, ÎN LOC SĂ ÎMPINGEM NODUL VINOVAT
##
## „Îl mai împing pe cel de jos cu douăzeci de pixeli” e prima idee, și e
## greșită: nodul mutat poate ieși de pe pergament, iar dacă îl oprim la
## margine se strâmbă și mai tare.
##
## Înmulțind toate abaterile stratului cu același număr, formele rămân
## PROPORȚIONALE — stratul arată la fel, doar mai puțin dezordonat — și niciun
## nod nu se apropie de margine mai mult decât se apropia înainte, fiindcă
## abaterea doar scade.
##
## Cum se află numărul: pentru fiecare pereche de vecini avem nevoie ca
##   (baza_jos + f·abatere_jos) − (baza_sus + f·abatere_sus) ≥ DISTANTA_MINIMA_BANDA
## Distanța de bază e deja destul de mare, deci singurul caz în care se strică
## e când abaterile se apropie una de alta. Atunci scoatem `f` din inegalitate
## și luăm cel mai mic `f` cerut de vreo pereche. Dacă nicio pereche nu se
## plânge, `f` rămâne 1 și nu s-a schimbat nimic.
static func _potoleste_abaterea(baza: Array, abateri: Array, minim: float) -> float:
	var factor := 1.0
	for i in range(baza.size() - 1):
		var loc: float = baza[i + 1] - baza[i]
		var strangere: float = abateri[i] - abateri[i + 1]   # cât apropie abaterea
		if strangere <= 0.0:
			continue   # abaterile depărtează nodurile; n-are cum să strice
		if loc <= minim:
			return 0.0   # nici fără abatere nu încap: n-o lăsa să mai strice ceva
		factor = minf(factor, (loc - minim) / strangere)
	return clampf(factor, 0.0, 1.0)


## Dreptunghiul de hârtie pe care au voie să stea nodurile, în coordonatele
## PÂNZEI.
##
## Două traduceri într-una. Întâi `ZONA_PERGAMENT` (fracțiuni de ECRAN) devine
## pixeli și se mută în sistemul pânzei — cele două nu sunt același lucru,
## fiindcă fundalul se întinde peste toată fereastra, iar pânza e doar
## dreptunghiul din interiorul marginilor paginii.
##
## ─────────────────────────────────────────────────────────────
## DE CE PÂNZA ȚINE ACUM TOATĂ PAGINA (septembrie 2026)
##
## Înainte, pânza era ultima căsuță dintr-o coloană: antet, linia de unelte,
## pânză, picior. Coloana îi dădea ce rămânea, adică un dreptunghi care începea
## la 95 px de sus și se oprea la 87 px de jos. Rezultatul se vedea: harta se
## înghesuia în mijlocul pergamentului, cu hârtie nefolosită sus, în stânga și
## în dreapta.
##
## Acum pânza e suprapusă peste toată pagina, iar textul PLUTEȘTE peste ea
## (`mouse_filter = IGNORE`, ca să treacă clicurile la noduri). Nu e un truc:
## pe o hartă desenată, titlul și legenda SE SCRIU pe hârtie, nu lângă ea.
## Nodurile au câștigat din asta vreo 21% pe fiecare latură — 666 × 353 px de
## hartă au devenit 805 × 427 — iar cele mai apropiate două noduri au trecut de
## la 103 la 125 px unul de altul, fără să fi atins nicio formulă de așezare.
##
## Ca să nu ajungă un simbol sub litere, linia de unelte s-a mutat sub starea
## din dreapta-sus: acolo colțul hârtiei e oricum al textului.
##
## Intersecția cu pânza rămâne, fiindcă hârtia poate începe deasupra ei pe o
## fereastră cu alte proporții. E răspunsul la „unde e ȘI hârtie, ȘI loc al meu”.
##
## La final scădem jumătate de nod din fiecare margine: `zona` e locul unde pot
## sta CENTRELE, iar un centru lipit de margine ar însemna un simbol pe
## jumătate în afară.
func _zona_utila() -> Rect2:
	var ecran := get_viewport_rect().size
	var hartie := Rect2(ZONA_PERGAMENT.position * ecran, ZONA_PERGAMENT.size * ecran)
	hartie.position -= panza.global_position

	var zona := hartie.intersection(Rect2(Vector2.ZERO, panza.size))
	return zona.grow_individual(
		-(MARIME_NOD.x * 0.5 + MARGINE_PANZA), -(MARIME_NOD.y * 0.5 + MARGINE_PANZA),
		-(MARIME_NOD.x * 0.5 + MARGINE_PANZA), -(MARIME_NOD.y * 0.5 + MARGINE_PANZA)
	)


## Un punct adus înapoi în zonă, dacă a ieșit din ea.
static func _in_zona(punct: Vector2, zona: Rect2) -> Vector2:
	return Vector2(
		clampf(punct.x, zona.position.x, zona.end.x),
		clampf(punct.y, zona.position.y, zona.end.y)
	)


## Liniile, cu starea lor. Se construiesc din aceleași date ca butoanele, deci
## nu pot ajunge să arate un drum care nu există.
##
## Primește drumurile GATA CALCULATE (vezi `_geometria`) și nu adaugă decât
## culoarea și grosimea. Funcția asta nu mai știe nici ce e o panglică, nici ce
## e o planșă — știe doar cine e în urma ta și încotro poți merge.
func _muchii(drumuri: Dictionary) -> Array[Dictionary]:
	var accesibile := Expeditie.accesibile()
	var muchii: Array[Dictionary] = []

	for nod in Expeditie.harta:
		var id := int(nod["id"])
		for id_urmator in nod["spre"]:
			var urmator := int(id_urmator)
			if not drumuri.has(id) or not drumuri[id].has(urmator):
				continue

			# Drumul e „parcurs” doar dacă AMÂNDOUĂ capetele sunt în urma ta ȘI
			# sunt vecine în drumul efectiv mers. Fără verificarea a doua, un
			# nod vizitat ar aprinde toate drumurile care pleacă din el, inclusiv
			# cele pe care NU le-ai luat.
			var parcurs := _sunt_vecini_in_drum(id, urmator)
			var deschis := id == Expeditie.pozitie and urmator in accesibile
			var culoare := CULOARE_DRUM_INCHIS
			var grosime := GROSIME_DRUM
			if parcurs:
				culoare = CULOARE_DRUM_PARCURS
			elif deschis:
				culoare = CULOARE_DRUM_DESCHIS
				grosime = GROSIME_DRUM_ALES

			# Drumul ajunge TĂIAT la pânză, nu întreg cu o instrucțiune de
			# „lasă atâta liber la capete". Motivul e același cu al despărțirii
			# de dinainte, dus un pas mai departe: cât de departe începe
			# cerneala unui simbol e o întrebare despre NODURI, iar pânza nu
			# știe ce e un nod. Înainte îi trimiteam un număr; acum îi trimitem
			# exact linia pe care o are de desenat, iar ea n-o mai scurtează
			# deloc. Un desenator care nu mai are nicio părere despre capete.
			muchii.append({
				"puncte": _taiat_la_simboluri(
					drumuri[id][urmator], id, urmator, grosime),
				"culoare": culoare,
				"grosime": grosime,
			})
	return muchii


# ─────────────────────────────────────────────────────────────
# TĂIEREA DRUMULUI LA MARGINEA SIMBOLULUI
#
# Problema, în cuvinte simple: drumul punctat pleacă din CENTRUL nodului, deci
# prima lui bucată trece pe sub simbol. Trebuie tăiată. Întrebarea e unde.
#
# Răspunsul de dinainte era „la 56 de pixeli de centru, oricare ar fi nodul".
# Merge dacă toate simbolurile umplu caseta ca un disc. Niciunul nu o umple,
# iar săbiile — două lame subțiri în diagonală — n-au cerneală decât până la
# 8 px de centru pe orizontală. Drumul se oprea la 56. Restul de 48 era golul.
#
# Răspunsul de acum: mergem pe drum din centru spre afară, din pixel în pixel,
# și întrebăm imaginea nodului „aici mai ești tu?". Ultimul „da" e locul unde
# se termină simbolul PE DIRECȚIA AIA. Adăugăm `RESPIRO_DRUM` și tăiem.
#
# Trei lucruri fără de care n-ar merge:
#
#   • ULTIMUL da, nu primul nu. Simbolurile au goluri (aerul dintre limbile de
#     flacără, spațiile dintre vârfurile coroanei). „Primul transparent" s-ar
#     opri la primul gol și am fi înapoi de unde am plecat.
#
#   • Se merge PE DRUM, nu pe coarda dintre capete. Drumurile sunt curbe pe
#     panglică; o dreaptă dusă din centru ar ieși din curbă exact acolo unde ne
#     trebuie precizie, adică lângă nod.
#
#   • Se pipăie o BANDĂ lată cât drumul, nu un fir. O liniuță are 6-11 px
#     grosime; dacă am întreba doar linia din mijloc, un gol de 4 px din simbol
#     ar fi declarat „hârtie liberă", iar liniuța ar intra sub cerneală cu
#     marginile ei.
#
# Se calculează O SINGURĂ DATĂ, la reașezarea hărții: `_muchii()` e chemată
# doar din `_aseaza_nodurile()`, nu la fiecare cadru.
# ─────────────────────────────────────────────────────────────

## Drumul, scurtat la amândouă capetele până la marginea vizibilă a simbolului.
func _taiat_la_simboluri(
	puncte: PackedVector2Array, id_a: int, id_b: int, grosime: float
) -> PackedVector2Array:
	if puncte.size() < 2:
		return puncte
	return _scurtat(
		puncte,
		_oprirea_la(puncte, id_a, true, grosime),
		_oprirea_la(puncte, id_b, false, grosime))


## Cât trebuie tăiat la un capăt: până unde ține cerneala, plus respiro.
##
## Dacă nodul n-are imagine (e desenat din poligoane), nu există alfa de citit
## și ne întoarcem la raza fixă. Plasa asta e singurul motiv pentru care
## `OPRIRE_LA_NOD` mai e folosită la desen.
func _oprirea_la(
	puncte: PackedVector2Array, id_nod: int, de_la_inceput: bool, grosime: float
) -> float:
	if not simboluri_nod.has(id_nod):
		return OPRIRE_LA_NOD
	var simbol: SimbolNod = simboluri_nod[id_nod]
	if not simbol.are_imagine():
		return OPRIRE_LA_NOD
	return _cerneala_pana_unde(puncte, simbol, de_la_inceput, grosime) + RESPIRO_DRUM


## Ultimul punct de cerneală, mergând pe drum dinspre nod spre afară.
##
## Întoarce distanța MĂSURATĂ PE DRUM (nu în linie dreaptă) de la capătul dat.
## Zero înseamnă „nici măcar sub centru nu e cerneală" — s-ar putea întâmpla la
## o imagine cu gaură fix în mijloc, și atunci drumul pornește de la respiro.
func _cerneala_pana_unde(
	puncte: PackedVector2Array, simbol: SimbolNod, de_la_inceput: bool,
	grosime: float
) -> float:
	var raza := simbol.raza_cernelii()
	# Punctele sunt în coordonatele PÂNZEI, iar simbolul e copilul ei: scăzând
	# colțul lui din stânga-sus ajungem în coordonatele LUI, cele în care își
	# desenează imaginea.
	var coltul: Vector2 = simbol.position
	var n := puncte.size()

	var ultima := 0.0
	var parcurs := 0.0
	var i := 0
	while parcurs < raza:
		# Mergem pe segmente, în ordinea dinspre capătul care ne interesează.
		var a: Vector2
		var b: Vector2
		if de_la_inceput:
			if i + 1 >= n:
				break
			a = puncte[i]
			b = puncte[i + 1]
		else:
			if n - 2 - i < 0:
				break
			a = puncte[n - 1 - i]
			b = puncte[n - 2 - i]
		i += 1

		var lungime := a.distance_to(b)
		if lungime < 0.0001:
			continue
		var directie := (b - a) / lungime
		# Perpendiculara pe drum: pe ea se pipăie lățimea liniuței.
		var normala := Vector2(-directie.y, directie.x)

		var s := 0.0
		while s <= lungime and parcurs + s < raza:
			if _acoperit(simbol, a + directie * s - coltul, normala, grosime):
				ultima = parcurs + s
			s += PAS_CERNEALA
		parcurs += lungime

	return ultima


## Atinge liniuța cerneala simbolului, undeva pe lățimea ei?
##
## Trei sonde: mijlocul și cele două margini. Mai multe n-ar schimba nimic la
## grosimile pe care le avem; una singură ar rata golurile înguste.
func _acoperit(
	simbol: SimbolNod, punct_local: Vector2, normala: Vector2, grosime: float
) -> bool:
	var jumatate := normala * grosime * 0.5
	return (
		simbol.are_cerneala(punct_local)
		or simbol.are_cerneala(punct_local + jumatate)
		or simbol.are_cerneala(punct_local - jumatate)
	)


## Drumul fără primii `de_la` și ultimii `pana_la` pixeli de lungime.
##
## Tăietura se face PE CURBĂ: punctul nou de capăt se interpolează în segmentul
## în care cade tăietura, deci drumul scurtat merge exact pe unde mergea cel
## întreg — nu se îndreaptă la capete.
##
## Dacă cele două tăieturi ar mânca tot drumul (două noduri apropiate, cu
## simboluri mari), se micșorează amândouă proporțional până rămâne `RAMAS_MINIM`
## de desenat. Mai bine un drum scurt decât unul care dispare: un drum lipsă se
## citește ca „nu poți merge acolo", adică o minciună despre hartă.
func _scurtat(
	puncte: PackedVector2Array, de_la: float, pana_la: float
) -> PackedVector2Array:
	const RAMAS_MINIM := 12.0

	# Lungimea cumulată până la fiecare punct. O singură trecere prin drum,
	# folosită pe urmă de trei ori — și de tăiere, și de cele două interpolări.
	var lungimi := PackedFloat32Array()
	var total := 0.0
	lungimi.append(0.0)
	for i in range(1, puncte.size()):
		total += puncte[i - 1].distance_to(puncte[i])
		lungimi.append(total)

	de_la = maxf(de_la, 0.0)
	pana_la = maxf(pana_la, 0.0)
	var cerut := de_la + pana_la
	if cerut > total - RAMAS_MINIM and cerut > 0.0:
		var factor := maxf(total - RAMAS_MINIM, 0.0) / cerut
		de_la *= factor
		pana_la *= factor

	var start := de_la
	var stop := total - pana_la
	if stop <= start:
		return PackedVector2Array()

	var rezultat := PackedVector2Array()
	rezultat.append(_punct_la(puncte, lungimi, start))
	for i in range(puncte.size()):
		if lungimi[i] > start and lungimi[i] < stop:
			rezultat.append(puncte[i])
	rezultat.append(_punct_la(puncte, lungimi, stop))
	return rezultat


## Punctul aflat la distanța `unde`, măsurată pe drum de la început.
func _punct_la(
	puncte: PackedVector2Array, lungimi: PackedFloat32Array, unde: float
) -> Vector2:
	if unde <= 0.0:
		return puncte[0]
	for i in range(1, puncte.size()):
		if lungimi[i] >= unde:
			var bucata := lungimi[i] - lungimi[i - 1]
			if bucata < 0.0001:
				return puncte[i]
			return puncte[i - 1].lerp(puncte[i], (unde - lungimi[i - 1]) / bucata)
	return puncte[puncte.size() - 1]


## Au fost nodurile astea două, una după alta, chiar pe drumul meu?
func _sunt_vecini_in_drum(a: int, b: int) -> bool:
	for i in range(Expeditie.parcurse.size() - 1):
		if Expeditie.parcurse[i] == a and Expeditie.parcurse[i + 1] == b:
			return true
	return false


# ─────────────────────────────────────────────────────────────
# INTRAREA ÎNTR-UN NOD
# ─────────────────────────────────────────────────────────────

func _pe_nod_apasat(id: int) -> void:
	Expeditie.intra_in_nod(id)
	var nod := Expeditie.nod_curent()

	match int(nod["tip"]):
		Expeditie.Nod.LUPTA, Expeditie.Nod.ELITA, Expeditie.Nod.BOSS:
			# Lupta e o SCENĂ ALTA. Tot ce trebuie să știe despre nodul ăsta
			# citește singură din `Expeditie.nod_curent()` — n-avem ce să-i
			# „trimitem”, și e bine așa: un parametru pasat între scene ar fi
			# exact lucrul care se pierde la un save.
			get_tree().change_scene_to_file(SCENA_LUPTA)
		Expeditie.Nod.ODIHNA:
			var recuperat := Expeditie.odihneste()
			_arata_mesaj(
				"ODIHNA",
				"Regele isi recapata suflul: +%d PV.\nAcum %d / %d." % [
					recuperat, Expeditie.pv, Expeditie.pv_max]
			)
		Expeditie.Nod.MAGAZIN:
			_arata_magazin()
		Expeditie.Nod.EVENIMENT:
			# Placeholder, și scris ca atare. Un nod care nu face nimic dar
			# pretinde că face e mai rău decât unul care recunoaște.
			_arata_mesaj(
				"EVENIMENT",
				"Aici va fi o alegere, candva. Deocamdata drumul doar trece pe langa."
			)


## Ce se întâmplă după ce un nod s-a rezolvat pe loc (odihnă, eveniment) sau
## după ce te-ai întors dintr-o luptă. UN SINGUR loc, ca cele trei drumuri să
## nu poată ajunge la trei concluzii diferite despre același final.
func _dupa_un_nod() -> void:
	if Expeditie.e_doborat():
		Expeditie.incheie(false)
		_arata_sumar()
	elif Expeditie.la_capat():
		Expeditie.incheie(true)
		_arata_sumar()
	else:
		_arata_harta()


# ─────────────────────────────────────────────────────────────
# MAGAZINUL
#
# Singurul loc din expediție în care Monedele înseamnă ceva. Ecranul ăsta nu
# știe nicio regulă: citește `Expeditie.PUTERI`, cere `Expeditie.cumpara()`, și
# se redesenează după. Prețurile, efectele și ce se poate cumpăra de două ori
# stau toate în expediție — aici e doar vitrina.
#
# De ce nu se închide singur după o cumpărătură: fiindcă poți cumpăra mai
# multe, dacă ai Monede. Un magazin care te dă afară după primul lucru cumpărat
# te-ar face să numeri înainte, nu să alegi.
# ─────────────────────────────────────────────────────────────

func _arata_magazin() -> void:
	panou_magazin.visible = true
	_construieste_magazin()
	buton_magazin.grab_focus()
	# Harta de sub voal se redesenează ACUM, ca să arate deja nodul devenit
	# „parcurs” când voalul se ridică. Același tipar ca la `_arata_mesaj`.
	_arata_harta()


## Un rând per putere din tabel. Niciun nume scris de mână: o putere nouă e un
## rând în `Expeditie.PUTERI`, nu o linie aici.
func _construieste_magazin() -> void:
	magazin_subtitlu.text = "Ai %d Monede. Ce cumperi tine pana la capatul expeditiei — apoi dispare." % Expeditie.monede

	for copil in magazin_lista.get_children():
		magazin_lista.remove_child(copil)
		copil.queue_free()

	for fisa in Expeditie.PUTERI:
		magazin_lista.add_child(_rand_magazin(fisa))


func _rand_magazin(fisa: Dictionary) -> Control:
	var cheie := String(fisa["cheie"])

	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 2)

	# Butonul se stinge singur când nu se poate cumpăra, ȘI SPUNE DE CE — fie
	# „iti mai trebuie 8”, fie „PV plin”. Un buton stins fără explicație e o ușă
	# închisă fără tăbliță: te uiți la ea și nu știi dacă e vina ta sau a jocului.
	var refuz := Expeditie.motiv_refuz(cheie)

	var buton := Button.new()
	buton.text = "%s  —  %d Monede" % [String(fisa["nume"]), int(fisa["cost"])]
	if refuz != "":
		buton.text += "   (%s)" % refuz
	buton.custom_minimum_size = Vector2(0, 40)
	buton.disabled = refuz != ""
	buton.pressed.connect(_pe_putere_cumparata.bind(cheie))
	coloana.add_child(buton)

	var descriere := Label.new()
	descriere.text = String(fisa["descriere"])
	descriere.modulate = Color(0.58, 0.58, 0.66)
	descriere.add_theme_font_size_override("font_size", 13)
	descriere.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coloana.add_child(descriere)

	return coloana


func _pe_putere_cumparata(cheie: String) -> void:
	var urmare := Expeditie.cumpara(cheie)
	if urmare == "":
		return   # n-au ajuns Monedele; butonul era oricum stins

	Sunet.reda(Sunet.Efect.CORECT)
	# Rescriem vitrina: Monedele au scăzut, deci alte butoane trebuie stinse.
	_construieste_magazin()
	# Și antetul, fiindcă și el arată Monedele — și, la „Zale ferecate”, PV-ul.
	_actualizeaza_antet()
	magazin_subtitlu.text = "%s  Ti-au ramas %d Monede." % [urmare, Expeditie.monede]


func _pe_magazin_inchis() -> void:
	panou_magazin.visible = false
	_dupa_un_nod()


func _arata_mesaj(titlu: String, text: String) -> void:
	mesaj_titlu.text = titlu
	mesaj_text.text = text
	panou_mesaj.visible = true
	buton_mesaj.grab_focus()
	# Harta de sub voal se redesenează ACUM, ca să arate deja starea nouă
	# (PV-ul recuperat, nodul devenit „parcurs”) când voalul se ridică.
	_arata_harta()


func _pe_mesaj_inchis() -> void:
	panou_mesaj.visible = false
	_dupa_un_nod()


# ─────────────────────────────────────────────────────────────
# ECRANUL 3: SUMARUL
# ─────────────────────────────────────────────────────────────

func _arata_sumar() -> void:
	var victorie := Expeditie.final == "victorie"

	panou_loadout.visible = false
	panou_mesaj.visible = false
	panou_sumar.visible = true
	_actualizeaza_antet()
	_construieste_harta()   # harta rămâne dedesubt: vezi drumul pe care l-ai mers

	sumar_titlu.text = "EXPEDITIE INCHEIATA" if victorie else "EXPEDITIE PIERDUTA"
	sumar_titlu.modulate = Color(1, 0.85, 0.45) if victorie else Color(0.72, 0.38, 0.38)

	if victorie:
		sumar_text.text = "Ai mers drumul pana la capat, cu %d / %d PV." % [
			Expeditie.pv, Expeditie.pv_max]
	else:
		# Tot fără „din câte”: vezi nota de la `_actualizeaza_antet`. Aici e și
		# mai la locul lui — „Bossul mai era la 4 pași” spune cât de aproape ai
		# fost, ceea ce „nodul 8 din 12” nu spunea niciodată.
		sumar_text.text = "Regele a cazut dupa %d noduri. Bossul mai era la %d pasi." % [
			Expeditie.parcurse.size(), Expeditie.pasi_pana_la_boss()]

	_construieste_sumar()
	buton_sumar.grab_focus()


## Rândurile sumarului, din același tabel din care se desenează și defalcarea
## recompenselor din luptă: etichetă la stânga, cifră la dreapta.
##
## Fragmentele apar de DOUĂ ori dinadins — „în expediția asta” și „cu totul” —
## fiindcă sunt două lucruri diferite: primul măsoară runul, al doilea e averea
## care rămâne după el. Un singur număr ar fi ascuns exact despărțirea pe care
## se sprijină tot save-ul.
func _construieste_sumar() -> void:
	for copil in sumar_randuri.get_children():
		sumar_randuri.remove_child(copil)
		copil.queue_free()

	var linii := [
		["Noduri parcurse", "%d din %d" % [
			Expeditie.parcurse.size(), Expeditie.harta.size()]],
		["Lupte castigate", str(Expeditie.recorduri["lupte_castigate"])],
		["Cel mai lung lant", str(Expeditie.recorduri["cel_mai_lung_lant"])],
		["Lovituri critice", str(Expeditie.recorduri["critice"])],
		["Cea mai grea lupta", "%d daune" % Expeditie.recorduri["daune_intr_o_lupta"]],
		["Fragmente din expeditie", str(Expeditie.fragmente_castigate)],
		["Cumparat la magazin", Expeditie.puteri_pe_scurt()],
		["Fragmente cu totul", str(Tezaur.cat(Tezaur.Resursa.FRAGMENTE))],
	]

	for linie in linii:
		sumar_randuri.add_child(_rand_sumar(String(linie[0]), String(linie[1])))

	sumar_randuri.add_child(_rand_sumar("Samanta", str(Expeditie.samanta)))


func _rand_sumar(eticheta: String, valoare: String) -> Control:
	var rand := HBoxContainer.new()

	var stanga := Label.new()
	stanga.text = eticheta
	stanga.modulate = Color(0.58, 0.58, 0.66)
	stanga.add_theme_font_size_override("font_size", 15)
	stanga.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var dreapta := Label.new()
	dreapta.text = valoare
	dreapta.modulate = Color(0.82, 0.82, 0.90)
	dreapta.add_theme_font_size_override("font_size", 15)
	dreapta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	rand.add_child(stanga)
	rand.add_child(dreapta)
	return rand


func _pe_expeditie_noua() -> void:
	# `goleste()` face starea „nicio expediție”, iar `_arata_loadout()` e
	# ecranul pentru starea aia. Nu reîncărcăm scena: n-ar aduce nimic în plus
	# și ar arunca muzica de la capăt.
	Expeditie.goleste()
	panou_sumar.visible = false
	_arata_loadout()
