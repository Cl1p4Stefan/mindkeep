extends TextureRect
## FUNDALUL ESTOMPAT, DESENAT O SINGURĂ DATĂ.
##
## Se pune pe un `TextureRect` care are deja imaginea și materialul cu
## `fundal_estompat.gdshader`. Fără scriptul ăsta, shaderul rulează la FIECARE
## cadru, pentru fiecare pixel al ecranului, cu 24 de probe pe pixel — deși
## imaginea nu se schimbă niciodată. Pe desktop nu se simte. În browser, pe
## ecran complet (de ~1,8 ori mai mulți pixeli decât în chenarul de pe itch.io),
## jocul începea să sacadeze, iar sunetul odată cu el: în build-ul web cu un
## singur fir, sunetul se amestecă pe același fir cu desenul.
##
## CUM: shaderul desenează o dată într-o pânză ascunsă (`SubViewport`), iar
## nodul arată apoi poza gata făcută. O pânză care se desenează „o dată”
## (`UPDATE_ONCE`) e exact o fotografie: costul shaderului se plătește la
## deschiderea ecranului și la redimensionarea ferestrei, nu de 60 de ori pe
## secundă.
##
## Pânza are mărimea nodului în pixelii PÂNZEI DE DESEN (1152×648, sau mai lată
## pe un ecran lat), nu ai ecranului real. Pe ecran complet poza se mărește,
## dar e o poză neclară: o mărire nu-i strică nimic.

var _panza: SubViewport
var _copie: TextureRect


func _ready() -> void:
	_panza = SubViewport.new()
	_panza.render_target_update_mode = SubViewport.UPDATE_ONCE

	# Copia poartă imaginea și shaderul; nodul ăsta rămâne doar „ramă”.
	_copie = TextureRect.new()
	_copie.texture = texture
	_copie.material = material
	_copie.expand_mode = expand_mode
	_copie.stretch_mode = stretch_mode
	_panza.add_child(_copie)
	add_child(_panza)

	material = null
	texture = _panza.get_texture()
	# Poza din pânză nu are mipmap-uri; filtrul liniar o mărește lin.
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	resized.connect(_redeseneaza)
	_redeseneaza()


## La fiecare schimbare de mărime pânza se potrivește din nou și mai face
## O fotografie. Vinieta din shader se măsoară pe `SCREEN_UV`, adică pe pânză —
## care acoperă exact nodul, deci colțurile rămân colțurile ecranului.
func _redeseneaza() -> void:
	var marime := Vector2i(size.round())
	if marime.x <= 0 or marime.y <= 0:
		return
	_panza.size = marime
	_copie.size = Vector2(marime)
	_panza.render_target_update_mode = SubViewport.UPDATE_ONCE
