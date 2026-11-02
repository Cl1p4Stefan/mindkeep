class_name GlifaSah
extends Silueta
## GLIFA de pe butonul unui Obelisc: pionul, calul, nebunul, turnul, regina —
## și, de la a șasea disciplină, busola, clepsidra și fulgerul.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU MAI SUNT TOATE PIESE DE ȘAH
##
## Fișierul se cheamă `glifa_sah.gd` fiindcă primele cinci glife au fost piese
## de șah, iar numele lui a rămas: șahul are ȘASE piese, regele e luat (el E
## PV-ul jucătorului, vezi `rege.gd`), deci cinci au fost tot ce se putea
## împărți Obeliscurilor. Problema era scrisă de mult, lângă formele reginei, cu
## întrebarea care trebuia pusă când va veni a șasea: rămân piesele skin-ul
## comun al TUTUROR Obeliscurilor, sau devin skin-ul primelor cinci?
##
## RĂSPUNS, dat la Spațial: devin skin-ul primelor cinci. A șaptea (Reținerea)
## a luat clepsidra din aceeași listă, iar a opta (Reflexul) fulgerul, fără ca
## întrebarea să se mai pună nici o dată — ceea ce e tot rostul unei decizii
## scrise o dată. Din cele patru simboluri propuse de pitch s-au folosit trei;
## al patrulea (spirala) rămâne nefolosit, fiindcă Tiparele, singura disciplină
## pentru care fusese propus, își primise deja regina. Ieșirea e cea scrisă
## în pitch de la bun început, care propunea un simbol pe disciplină (clepsidră,
## spirală, busolă, fulger) — deci nu s-a inventat azi, s-a folosit. Cele cinci
## de dinainte nu se ating: o renumerotare a glifelor ar fi însemnat cinci
## siluete noi și patru PNG-uri aruncate, pentru o disciplină în plus.
##
## Numele fișierului NU s-a schimbat. O redenumire ar fi atins `obelisc.gd`,
## `discipline.gd` și cheia `piesa` din catalog — adică o zi de curățenie
## pentru un cuvânt. Ce contează e scris aici: de la a șasea încolo, glifa unei
## discipline e simbolul ei, nu o piesă.
##
## ─────────────────────────────────────────────────────────────
## DE CE DESENATĂ, ȘI NU SCRISĂ CU ♟ ♞ ♝
##
## Ăsta a fost primul lucru încercat, și nu merge: fontul implicit al lui Godot
## (Open Sans SemiBold) NU conține caracterele de șah. Verificat, nu presupus —
## `ThemeDB.fallback_font.has_char(0x265F)` întoarce `false` pentru toate trei.
## Pe ecran ar fi ieșit trei dreptunghiuri goale („tofu"), adică exact opusul a
## ce voiam.
##
## Se putea rezolva în două feluri, și amândouă costau mai mult decât desenul:
##   • un `SystemFont` (Segoe UI Symbol) — merge pe Windows, dar fonturile de
##     sistem nu există în export web, iar web-ul e pe lista de pași;
##   • un font adus în proiect — un fișier de câteva sute de KB și o licență de
##     verificat, pentru trei simboluri.
##
## Desenate, piesele merg oriunde (inclusiv pe web), se colorează cu culoarea
## disciplinei fără trucuri și sunt tăioase la orice mărime.
##
## ─────────────────────────────────────────────────────────────
## CUM E CONSTRUITĂ
##
## Moștenește `Silueta`, aceeași bază folosită de rege și de Pagina Goală: ea
## știe deja să potrivească o casetă cu proporții corecte în orice cutie îi dă
## containerul și să traducă „fracțiuni" (numere între 0 și 1) în pixeli.
## Formele de mai jos sunt deci liste de numere între 0 și 1 — ușor de citit,
## ușor de ajustat, independente de mărimea butonului.
##
## Singura diferență față de siluetele din arenă: piesa asta NU respiră
## (`amplitudine = 0`) și, ca urmare, nu are nevoie de `_process` — trei icoane
## care pulsează sub trei butoane ar fi zgomot, nu viață.

enum Piesa { PION, CAL, NEBUN, TURN, REGINA, BUSOLA, CLEPSIDRA, FULGER }

## Culoarea piesei. O pune `obelisc.gd`, din tabelul disciplinelor.
@export var culoare := Color(0.85, 0.88, 1.0):
	set(valoare):
		culoare = valoare
		queue_redraw()

## Culoarea GĂURILOR: ochiul și nara calului, fanta nebunului. Nu e „negru", e
## „culoarea a ceea ce se vede prin piesă" — adică fondul butonului. De-aia o
## primește din afară: dacă butonul își schimbă fondul, tăieturile îl urmează.
@export var culoare_gol := Color(0.11, 0.11, 0.15):
	set(valoare):
		culoare_gol = valoare
		queue_redraw()

## Cât de aprins e halo-ul din spatele piesei, de la 0 (deloc) la ~1.
## E o valoare ANIMATĂ din `obelisc.gd` (mai tare la hover), de-aia e o simplă
## proprietate cu setter: un Tween poate scrie în ea de 60 de ori pe secundă.
@export var glow := 0.32:
	set(valoare):
		glow = valoare
		queue_redraw()

## Desenăm doar halo-ul, fără piesă?
##
## Așa stă glifa sub un Obelisc care și-a primit ARTA ADEVĂRATĂ (vezi câmpul
## „imagine" din tabelul `OBELISCURI`): imaginea se pune peste nodul ăsta, iar
## nodul rămâne să facă singurul lucru pe care un PNG nu-l poate face singur —
## să se aprindă și să se stingă în culoarea disciplinei, la hover.
##
## De ce nu ștergem pur și simplu nodul când există imagine: atunci hover-ul ar
## trebui să anime altă proprietate pentru Obeliscurile cu artă decât pentru cele
## desenate, iar `obelisc.gd` ar avea două feluri de a se aprinde. Așa are unul.
@export var doar_aura := false:
	set(valoare):
		doar_aura = valoare
		queue_redraw()

## Ce piesă desenăm. Schimbarea ei schimbă și proporția casetei: un cal e mai
## lat decât un pion, iar o casetă comună ar turti-o pe una din ele.
@export var piesa: Piesa = Piesa.PION:
	set(valoare):
		piesa = valoare
		proportie = FORME[piesa]["proportie"]
		queue_redraw()

# ─────────────────────────────────────────────────────────────
# FORMELE, ÎN FRACȚIUNI
#
# (0,0) e colțul din stânga-sus al casetei, (1,1) cel din dreapta-jos.
# Deci y MIC = sus. Toate piesele sunt construite la fel, de sus în jos:
# cap sau mitră, guler, corp care se evazează, talpă.
# ─────────────────────────────────────────────────────────────

# DE CE `static var` ȘI NU `const`, deși numerele astea nu se schimbă niciodată:
# GDScript acceptă drept constantă doar o expresie pe care o poate calcula la
# citirea fișierului, iar `PackedVector2Array([...])` e o CHEMARE de funcție —
# deci refuză („Assigned value for constant isn't a constant expression").
# `static var` înseamnă „aparține SCRIPTULUI, nu fiecărui buton": se calculează
# o singură dată, la încărcarea scriptului, și e aceeași listă pentru toate cele
# trei butoane. Scrise cu MAJUSCULE fiindcă asta rămân: niște constante.

# PIONUL — cel mai simplu: o bilă, un guler, un corp care se lărgește, o talpă.
static var PION_GULER := PackedVector2Array([
	Vector2(0.355, 0.400), Vector2(0.645, 0.400),
	Vector2(0.625, 0.455), Vector2(0.375, 0.455),
])
static var PION_CORP := PackedVector2Array([
	Vector2(0.375, 0.450), Vector2(0.625, 0.450),
	Vector2(0.660, 0.620), Vector2(0.720, 0.780),
	Vector2(0.280, 0.780), Vector2(0.340, 0.620),
])
static var PION_TALPA := PackedVector2Array([
	Vector2(0.220, 0.770), Vector2(0.780, 0.770),
	Vector2(0.840, 0.895), Vector2(0.860, 0.965),
	Vector2(0.140, 0.965), Vector2(0.160, 0.895),
])

# NEBUNUL — mitra cu fantă, bila din vârf, același corp-talpă ca pionul.
static var NEBUN_MITRA := PackedVector2Array([
	Vector2(0.500, 0.140), Vector2(0.608, 0.190),
	Vector2(0.678, 0.288), Vector2(0.692, 0.382),
	Vector2(0.648, 0.458), Vector2(0.352, 0.458),
	Vector2(0.308, 0.382), Vector2(0.322, 0.288),
	Vector2(0.392, 0.190),
])
static var NEBUN_FANTA := PackedVector2Array([
	Vector2(0.452, 0.228), Vector2(0.478, 0.210),
	Vector2(0.612, 0.360), Vector2(0.586, 0.378),
])
static var NEBUN_GULER := PackedVector2Array([
	Vector2(0.330, 0.452), Vector2(0.670, 0.452),
	Vector2(0.648, 0.522), Vector2(0.352, 0.522),
])
static var NEBUN_CORP := PackedVector2Array([
	Vector2(0.378, 0.515), Vector2(0.622, 0.515),
	Vector2(0.700, 0.770), Vector2(0.300, 0.770),
])
static var NEBUN_TALPA := PackedVector2Array([
	Vector2(0.200, 0.760), Vector2(0.800, 0.760),
	Vector2(0.862, 0.890), Vector2(0.880, 0.965),
	Vector2(0.120, 0.965), Vector2(0.138, 0.890),
])

# CALUL — singura piesă care nu e o coloană cu ceva pe vârf, deci singura care
# NU se lasă scrisă ca un contur unic. Prima încercare a fost exact asta: un
# singur poligon de 35 de puncte, ajustat din ochi. Ieșea, pe rând, un iepure,
# o lamă și o lebădă — fiindcă într-un contur închis fiecare punct ține de doi
# vecini, iar când tragi de unul ca să lungești botul se strică falca.
#
# Acum calul e COMPUS din părți care se suprapun: talpă, gât, cap, două urechi,
# un obraz rotund. Toate se desenează în aceeași culoare, una peste alta, deci
# nu e nevoie de niciun calcul de reuniune — pata rezultată E silueta.
# Avantajul real: poți lungi botul fără să atingi gâtul.
static var CAL_TALPA := PackedVector2Array([
	Vector2(0.140, 0.968), Vector2(0.860, 0.968),
	Vector2(0.806, 0.884), Vector2(0.770, 0.848),
	Vector2(0.230, 0.848), Vector2(0.194, 0.884),
])
static var CAL_GAT := PackedVector2Array([
	Vector2(0.300, 0.856), Vector2(0.752, 0.856),
	Vector2(0.812, 0.470), Vector2(0.392, 0.500),
])
static var CAL_CAP := PackedVector2Array([
	Vector2(0.452, 0.150), Vector2(0.760, 0.146),
	Vector2(0.852, 0.360), Vector2(0.716, 0.560),
	Vector2(0.300, 0.604), Vector2(0.104, 0.512),
	Vector2(0.120, 0.360),
])
static var CAL_URECHE_FATA := PackedVector2Array([
	Vector2(0.566, 0.058), Vector2(0.628, 0.148), Vector2(0.524, 0.168),
])
static var CAL_URECHE_SPATE := PackedVector2Array([
	Vector2(0.700, 0.052), Vector2(0.768, 0.156), Vector2(0.648, 0.150),
])

# TURNUL — a patra piesă, pentru Numere. Cea mai simplă din toate patru, și
# singura care nu are nimic rotund în ea: numai drepte și colțuri.
#
# Asta nu e o întâmplare, e tot ce o face recognoscibilă. Criteriul din pitch
# („distinct ca siluetă, recunoscut periferic, în mijlocul unei ture
# cronometrate") e cel care alege forma: pionul, nebunul și turnul sunt toate
# trei coloane cu talpă, deci ce le deosebește la 40 px e DOAR vârful —
# o bilă, o mitră ascuțită, o coroană crenelată. Trei feluri de contur de sus:
# rotund, ascuțit, dințat.
#
# Crenelurile sunt o bandă plină cu două CRESTĂTURI tăiate în ea (în
# „goluri"), nu trei dreptunghiuri desenate separat. Același truc ca fanta
# nebunului, și din același motiv: trei forme lipite una de alta lasă fire de
# fond între ele la anumite mărimi, fiindcă marginile cad între pixeli.
static var TURN_CRENELURI := PackedVector2Array([
	Vector2(0.255, 0.140), Vector2(0.745, 0.140),
	Vector2(0.745, 0.300), Vector2(0.255, 0.300),
])
static var TURN_CRESTATURA_STANGA := PackedVector2Array([
	Vector2(0.360, 0.132), Vector2(0.448, 0.132),
	Vector2(0.448, 0.232), Vector2(0.360, 0.232),
])
static var TURN_CRESTATURA_DREAPTA := PackedVector2Array([
	Vector2(0.553, 0.132), Vector2(0.641, 0.132),
	Vector2(0.641, 0.232), Vector2(0.553, 0.232),
])
static var TURN_GULER := PackedVector2Array([
	Vector2(0.235, 0.296), Vector2(0.765, 0.296),
	Vector2(0.738, 0.362), Vector2(0.262, 0.362),
])
static var TURN_CORP := PackedVector2Array([
	Vector2(0.330, 0.355), Vector2(0.670, 0.355),
	Vector2(0.700, 0.700), Vector2(0.740, 0.790),
	Vector2(0.260, 0.790), Vector2(0.300, 0.700),
])
static var TURN_TALPA := PackedVector2Array([
	Vector2(0.205, 0.775), Vector2(0.795, 0.775),
	Vector2(0.855, 0.898), Vector2(0.875, 0.965),
	Vector2(0.125, 0.965), Vector2(0.145, 0.898),
])

# REGINA — a cincea piesă, pentru Tipare. Și ULTIMA piesă de șah din joc.
#
# Întrebarea pe care o pusese comentariul ăsta — „rămân piesele skin-ul comun
# al tuturor Obeliscurilor, sau devin skin-ul primelor cinci?" — a primit
# răspuns la a șasea disciplină (Spațial): skin-ul primelor cinci. Vezi antetul
# fișierului. Problema fusese scrisă aici înainte să existe, și de-aia a costat
# o decizie și nu o zi: ieșirea era deja aleasă când a venit nevoia.
#
# NUMELE SE LOVEȘTE CU O MECANICĂ AMÂNATĂ, și nu e o neatenție: „Regina" era
# supapa care dădea acces, contra cost, la o disciplină neechipată, iar ea stă
# amânată (vezi CLAUDE.md). Piesa de aici e un DESEN pe un buton, nu mecanica;
# dacă supapa se întoarce vreodată, ce trebuie să se schimbe e numele ei, nu
# această formă — o supapă nu e un Obelisc și n-ar purta niciodată glifa unuia.
#
# FORMA: o coroană cu cinci colțuri ascuțite, cel din mijloc cel mai înalt, cu
# o bilă pe el. Criteriul e cel din pitch („distinct ca siluetă, recunoscut
# periferic"), iar la 40 px el se traduce tot în conturul de SUS, fiindcă
# pionul, nebunul, turnul și regina sunt toate coloane cu talpă:
#   pion → bilă · nebun → mitră ascuțită · turn → creneluri drepte ·
#   regina → colțuri ascuțite, cu vârful mijlociu mai înalt.
# Turnul și regina sunt perechea cea mai apropiată (amândouă au un contur
# dințat), și de-aia diferența dintre ele e făcută pe DOUĂ căi deodată: dinți
# drepți contra colțuri ascuțite, și o coroană plată contra una cu vârf.
#
# Coroana e UN SINGUR poligon în zigzag, nu cinci triunghiuri lipite — același
# motiv ca la crenelurile turnului: formele alăturate lasă fire de fond între
# ele la anumite mărimi, fiindcă marginile cad între pixeli.
static var REGINA_COROANA := PackedVector2Array([
	Vector2(0.215, 0.300),
	Vector2(0.258, 0.140), Vector2(0.320, 0.248),
	Vector2(0.379, 0.102), Vector2(0.440, 0.232),
	Vector2(0.500, 0.070), Vector2(0.560, 0.232),
	Vector2(0.621, 0.102), Vector2(0.680, 0.248),
	Vector2(0.742, 0.140), Vector2(0.785, 0.300),
])
static var REGINA_GULER := PackedVector2Array([
	Vector2(0.228, 0.294), Vector2(0.772, 0.294),
	Vector2(0.742, 0.366), Vector2(0.258, 0.366),
])
static var REGINA_CORP := PackedVector2Array([
	Vector2(0.318, 0.358), Vector2(0.682, 0.358),
	Vector2(0.716, 0.700), Vector2(0.758, 0.790),
	Vector2(0.242, 0.790), Vector2(0.284, 0.700),
])
static var REGINA_TALPA := PackedVector2Array([
	Vector2(0.192, 0.775), Vector2(0.808, 0.775),
	Vector2(0.868, 0.898), Vector2(0.888, 0.965),
	Vector2(0.112, 0.965), Vector2(0.132, 0.898),
])

# BUSOLA — a șasea glifă, pentru Spațial, și prima care nu e o piesă de șah
# (vezi antetul fișierului pentru decizia întreagă).
#
# FORMA: un DISC, cu o roză a vânturilor tăiată în el. E singura glifă care nu
# e o coloană cu talpă, și asta nu e o întâmplare — e chiar criteriul din pitch
# („distinct ca siluetă, recunoscut periferic, la 40 px") luat în serios.
#
# Pionul, nebunul, turnul și regina se deosebesc între ele prin CONTURUL DE
# SUS: bilă, mitră, creneluri, colțuri. Patru diferențe pe o siluetă comună,
# și la a cincea (regina lângă turn) a trebuit deja să fie făcută pe două căi
# deodată ca să se mai vadă. A șasea pe aceeași siluetă n-ar fi fost
# recognoscibilă nici cu cea mai inspirată coroană.
#
# Deci busola rupe silueta: un cerc nu seamănă cu nicio coloană, la nicio
# mărime, nici cu ochiul periferic. Ăsta e și tot câștigul renunțării la șah —
# dacă n-ar fi fost, n-ar fi meritat plătit.
#
# DE CE ROZA E TĂIATĂ, NU DESENATĂ DEASUPRA. Un inel plus o stea desenată
# înăuntru ar fi avut, la 40 px, un gol de doi pixeli între vârfurile stelei și
# inel — iar două forme despărțite de doi pixeli se lipesc pe ecran într-o pată.
# Tăiată, roza e chiar fondul butonului care se vede prin disc: nu poate să se
# lipească de nimic, fiindcă nu e desenată, e absentă. Aceeași metodă ca ochiul
# calului și fanta nebunului, care sunt tot „goluri".
#
# Vârfurile ajung la 0,36 din casetă, deci rămâne o margine de disc de 0,10 —
# patru pixeli la 40 px. Sub atât, discul s-ar fi rupt în patru felii.
static var BUSOLA_ROZA := PackedVector2Array([
	Vector2(0.500, 0.140),                          # nord
	Vector2(0.585, 0.415),
	Vector2(0.860, 0.500),                          # est
	Vector2(0.585, 0.585),
	Vector2(0.500, 0.860),                          # sud
	Vector2(0.415, 0.585),
	Vector2(0.140, 0.500),                          # vest
	Vector2(0.415, 0.415),
])

# CLEPSIDRA — a șaptea glifă, pentru Reținere.
#
# FORMA: capac, talpă, și două pahare care se ating la mijloc. Nu e o coloană
# cu talpă (pionul, nebunul, turnul, regina) și nu e un disc (busola) — e
# SIMETRICĂ SUS-JOS, și ăsta e tot criteriul.
#
# Cele cinci piese de șah se deosebesc între ele prin conturul de SUS, pe o
# siluetă comună care e grea jos și subțire sus. Busola a rupt silueta cu un
# cerc. Clepsidra o rupe pe cealaltă axă: la 40 px, „la fel de greu sus ca
# jos" se prinde cu coada ochiului mai repede decât orice coroană — și e
# singura formă din tabel despre care se poate spune asta.
#
# ASTA E ȘI AL DOILEA SEMN AL DISCIPLINEI, nu doar un desen frumos. Culoarea
# ei (verde-albastru, vezi `discipline.gd`) e cea care fusese respinsă la a
# cincea disciplină, fiindcă stă între albastrul Memoriei și verdele Logicii.
# Argumentul s-a schimbat fiindcă s-a schimbat ce duce recunoașterea: de la a
# șasea încoace, glifele nu mai sunt variații pe aceeași siluetă, deci forma
# poate purta singură deosebirea, iar culoarea rămâne al doilea semnal.
#
# DE CE PATRU POLIGOANE ȘI NU UNUL. Un singur poligon în formă de clepsidră e
# CONCAV (se strânge la mijloc). `draw_colored_polygon` îl taie în triunghiuri
# și, până la proba contrarie, corect — dar „până la proba contrarie" nu e un
# verdict. Patru forme convexe (capac, pahar sus, gât, pahar jos, talpă) nu au
# nimic de dedus, iar gâtul e chiar ce le ține lipite: fără el, cele două
# pahare s-ar atinge într-un punct, adică ar părea rupte la mijloc.
static var CLEPSIDRA_CAPAC := PackedVector2Array([
	Vector2(0.060, 0.020), Vector2(0.940, 0.020),
	Vector2(0.940, 0.130), Vector2(0.060, 0.130),
])
static var CLEPSIDRA_PAHAR_SUS := PackedVector2Array([
	Vector2(0.170, 0.130), Vector2(0.830, 0.130),
	Vector2(0.560, 0.480), Vector2(0.440, 0.480),
])
static var CLEPSIDRA_GAT := PackedVector2Array([
	Vector2(0.440, 0.460), Vector2(0.560, 0.460),
	Vector2(0.560, 0.540), Vector2(0.440, 0.540),
])
static var CLEPSIDRA_PAHAR_JOS := PackedVector2Array([
	Vector2(0.440, 0.520), Vector2(0.560, 0.520),
	Vector2(0.830, 0.870), Vector2(0.170, 0.870),
])
static var CLEPSIDRA_TALPA := PackedVector2Array([
	Vector2(0.060, 0.870), Vector2(0.940, 0.870),
	Vector2(0.940, 0.980), Vector2(0.060, 0.980),
])

# NISIPUL SCURS: golul din vârful paharului de sus. E un „gol", deci chiar
# fondul butonului văzut prin sticlă — aceeași metodă ca ochiul calului și roza
# busolei, și singurul fel în care se poate arăta „pe jumătate golită" fără o a
# doua culoare în tabel.
#
# Și e tot ce face clepsidra să fie o clepsidră care MERGE, nu un simbol gol:
# un pahar plin de sus în jos ar fi arătat ca un X îngroșat.
#
# Adâncimea (0,32 din casetă) e măsurată, nu aleasă: la prima scriere golul
# cobora până la 0,37, iar pe butonul de 40 px paharul de sus rămânea aproape
# negru — adică exact simetria sus-jos pe care se bazează recunoașterea se
# pierdea tocmai la mărimea la care contează. Mai sus de atât, nisipul n-ar mai
# părea scurs.
static var CLEPSIDRA_SCURS := PackedVector2Array([
	Vector2(0.235, 0.180), Vector2(0.765, 0.180),
	Vector2(0.645, 0.320), Vector2(0.355, 0.320),
])

# FULGERUL — a opta glifă, pentru Reflex. A treia care nu e o piesă de șah, și
# tot din lista pitch-ului (clepsidră, spirală, busolă, fulger): până aici s-au
# folosit trei din cele patru propuse, fără să se inventeze niciuna.
#
# FORMA: două tăieturi oblice, decalate, cu vârf în jos. E singura glifă
# ASIMETRICĂ din tabel, și ăsta e criteriul — exact cum al clepsidrei era
# simetria sus-jos.
#
# Cele cinci piese de șah sunt simetrice stânga-dreapta (o coloană grea jos),
# busola e simetrică în toate părțile (un disc), clepsidra e simetrică și
# sus-jos. La 40 px, o formă care se CLATINĂ pe diagonală se prinde periferic
# fără să fie recunoscută: nu trebuie să vezi că e un fulger ca să vezi că nu e
# niciuna din celelalte șapte.
#
# DE CE DOUĂ POLIGOANE ȘI NU UNUL. Un fulger dintr-o bucată e concav de două
# ori (la fiecare cot), iar `draw_colored_polygon` ar trebui să-l taie singur în
# triunghiuri. Aceeași însemnare ca la clepsidră: până la proba contrarie îl
# taie bine, dar „până la proba contrarie" nu e un verdict, iar două
# patrulatere CONVEXE n-au nimic de dedus.
#
# Se suprapun la mijloc (de la 0,42 la 0,50): fără suprapunere, cele două
# tăieturi s-ar atinge într-un punct, adică fulgerul ar părea rupt în două —
# aceeași grijă pentru care clepsidra are un gât.
static var FULGER_SUS := PackedVector2Array([
	Vector2(0.520, 0.020), Vector2(0.980, 0.020),
	Vector2(0.620, 0.500), Vector2(0.160, 0.500),
])
# Partea de jos se termină într-un VÂRF (un singur punct, la 0,42 / 0,98), nu
# într-o latură: un fulger cu fundul drept arată ca o treaptă de scară.
static var FULGER_JOS := PackedVector2Array([
	Vector2(0.380, 0.420), Vector2(0.840, 0.420),
	Vector2(0.420, 0.980), Vector2(0.240, 0.700),
])

## Catalogul formelor. Un rând per piesă: poligoanele pline, cercurile pline,
## „golurile" (desenate peste, în culoarea fondului) și proporția casetei.
## Turnul a fost chiar proba promisiunii scrise aici înainte („o a patra piesă
## e un rând"): a costat un rând în `enum`, cinci forme și rândul de mai jos.
## Regina, a cincea, a costat exact la fel — a doua probă a aceleiași
## promisiuni, și ultima pe care șahul o mai putea plăti (vezi comentariul de
## la formele ei).
static var FORME := {
	Piesa.PION: {
		"proportie": 0.62,
		"poligoane": [PION_TALPA, PION_CORP, PION_GULER],
		"cercuri": [{"centru": Vector2(0.5, 0.262), "raza": 0.145}],
		"goluri": [],
		"cercuri_gol": [],
	},
	Piesa.CAL: {
		"proportie": 0.72,
		"poligoane": [CAL_TALPA, CAL_GAT, CAL_CAP, CAL_URECHE_FATA, CAL_URECHE_SPATE],
		"cercuri": [
			{"centru": Vector2(0.640, 0.330), "raza": 0.190},
			{"centru": Vector2(0.196, 0.430), "raza": 0.092},
		],
		"goluri": [],
		"cercuri_gol": [
			{"centru": Vector2(0.530, 0.268), "raza": 0.034},
			{"centru": Vector2(0.148, 0.430), "raza": 0.020},
		],
	},
	Piesa.NEBUN: {
		"proportie": 0.62,
		"poligoane": [NEBUN_TALPA, NEBUN_CORP, NEBUN_GULER, NEBUN_MITRA],
		"cercuri": [{"centru": Vector2(0.5, 0.086), "raza": 0.049}],
		"goluri": [NEBUN_FANTA],
		"cercuri_gol": [],
	},
	# Mai lat decât pionul și nebunul (0.64 față de 0.62): un turn îndesat se
	# citește ca un turn, unul subțire ca un pion cu capul tăiat.
	Piesa.TURN: {
		"proportie": 0.64,
		"poligoane": [TURN_TALPA, TURN_CORP, TURN_GULER, TURN_CRENELURI],
		"cercuri": [],
		"goluri": [TURN_CRESTATURA_STANGA, TURN_CRESTATURA_DREAPTA],
		"cercuri_gol": [],
	},
	# Cea mai lată din toate cinci (0.68): regina are nevoie de lățime ca
	# zigzagul coroanei să aibă loc. Strânsă la lățimea pionului, cele cinci
	# colțuri ar fi căzut unul peste altul la 40 px și ar fi arătat ca o pată
	# dințată.
	Piesa.REGINA: {
		"proportie": 0.68,
		"poligoane": [REGINA_TALPA, REGINA_CORP, REGINA_GULER, REGINA_COROANA],
		# Bila din vârful colțului mijlociu. Mai mică decât cea a pionului
		# (0.145) și cât cea a nebunului: ea nu e capul piesei, e bijuteria de
		# pe el.
		"cercuri": [{"centru": Vector2(0.500, 0.062), "raza": 0.052}],
		"goluri": [],
		"cercuri_gol": [],
	},
	# Singura glifă PĂTRATĂ (proporția 1.0): un cerc turtit după proporția unei
	# piese de șah n-ar mai fi fost un cerc, ar fi fost o elipsă — adică o
	# busolă văzută dintr-o parte.
	Piesa.BUSOLA: {
		"proportie": 1.0,
		"poligoane": [],
		"cercuri": [{"centru": Vector2(0.5, 0.5), "raza": 0.46}],
		"goluri": [BUSOLA_ROZA],
		"cercuri_gol": [],
	},
	# Cea mai ÎNGUSTĂ din toate șapte (0.56, față de 0.62-0.68 la piesele de
	# șah și 1.0 la busolă). Nu e o preferință: o clepsidră lată seamănă cu o
	# fundă, iar una îngustă se citește din prima. Lățimea e și al doilea semn
	# al simetriei — un dreptunghi înalt și subțire, strâns la mijloc.
	Piesa.CLEPSIDRA: {
		"proportie": 0.56,
		"poligoane": [
			CLEPSIDRA_CAPAC, CLEPSIDRA_PAHAR_SUS, CLEPSIDRA_GAT,
			CLEPSIDRA_PAHAR_JOS, CLEPSIDRA_TALPA,
		],
		"cercuri": [],
		"goluri": [CLEPSIDRA_SCURS],
		"cercuri_gol": [],
	},
	# A doua cea mai îngustă (0,58), aproape cât clepsidra — și tocmai de-aia
	# forma trebuia să fie asimetrică: dacă ar fi fost și ea lată, deosebirea de
	# clepsidră ar fi căzut iar pe culoare, adică pe axa terminată. Un fulger
	# lat se citește ca un zigzag decorativ; unul îngust cade ca o lovitură.
	Piesa.FULGER: {
		"proportie": 0.58,
		"poligoane": [FULGER_SUS, FULGER_JOS],
		"cercuri": [],
		"goluri": [],
		"cercuri_gol": [],
	},
}

## Cât de departe se întinde halo-ul dincolo de piesă, ca fracțiune din
## înălțimea casetei. Peste ~0.35 nu mai e un halo, e o ceață.
const RAZA_AURA := 0.34

## Halo-ul: o pată radială care se STINGE spre margini. E o textură generată din
## cod, nu un fișier — un degrade descris în patru rânduri.
##
## De ce o textură și nu conturul desenat de mai multe ori, din ce în ce mai
## mare: straturile suprapuse se văd ca inele, oricât de transparente le-ai
## face. Un degrade radial e o singură desenare și chiar se stinge, în loc să se
## oprească. `static` = se face o dată pentru tot jocul, nu o dată per buton.
static var _aura: GradientTexture2D = null


func _init() -> void:
	amplitudine = 0.0   # piesele de pe butoane nu respiră
	ancora_y = 0.5
	proportie = FORME[Piesa.PION]["proportie"]


func _ready() -> void:
	super()              # `Silueta._ready()` — conectează `resized`
	# Fără respirație n-avem ce calcula în fiecare cadru. `Silueta._process()`
	# ar chema `queue_redraw()` de 60 de ori pe secundă ca să deseneze exact
	# aceeași imagine. Redesenăm doar când chiar se schimbă ceva (culoare,
	# glow, piesă) — adică din seterele de sus.
	set_process(false)
	if _aura == null:
		_aura = _fa_aura()


## Degradeul radial, făcut o singură dată. ALB, nu colorat: îl colorăm la
## desenare, cu culoarea disciplinei, deci aceeași textură servește toate
## piesele (alb × culoare = culoare).
static func _fa_aura() -> GradientTexture2D:
	var degrade := Gradient.new()
	degrade.offsets = PackedFloat32Array([0.0, 0.42, 1.0])
	degrade.colors = PackedColorArray([
		Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.16), Color(1, 1, 1, 0.0),
	])
	var textura := GradientTexture2D.new()
	textura.gradient = degrade
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5, 0.5)
	textura.fill_to = Vector2(1.0, 0.5)   # raza = jumătate din lățime
	textura.width = 64
	textura.height = 64
	return textura


func _deseneaza_silueta() -> void:
	var forma: Dictionary = FORME[piesa]

	# ÎNTÂI halo-ul, ca să rămână SUB piesă. Pătrat și centrat pe casetă:
	# un halo turtit după proporția piesei ar arăta ca o umbră, nu ca o lumină.
	if glow > 0.0:
		var latura := _caseta.size.y * (1.0 + RAZA_AURA * 2.0)
		var centru := _caseta.position + _caseta.size * 0.5
		draw_texture_rect(
			_aura,
			Rect2(centru - Vector2(latura, latura) * 0.5, Vector2(latura, latura)),
			false,
			Color(culoare, glow)
		)

	if doar_aura:
		return

	for poligon: PackedVector2Array in forma["poligoane"]:
		_poligon(poligon, culoare)
	for cerc: Dictionary in forma["cercuri"]:
		_cerc(cerc["centru"], cerc["raza"], culoare)

	# GOLURILE se desenează LA FINAL, peste piesă: sunt tăieturi în ea.
	for poligon: PackedVector2Array in forma["goluri"]:
		_poligon(poligon, culoare_gol)
	for cerc: Dictionary in forma["cercuri_gol"]:
		_cerc(cerc["centru"], cerc["raza"], culoare_gol)
