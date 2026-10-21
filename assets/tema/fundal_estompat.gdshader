shader_type canvas_item;
// FUNDAL ESTOMPAT — o imagine care stă ÎN SPATELE ecranului, nu în prim-plan.
//
// Folosit în Practice peste `fight_background.jpg`: aceeași bibliotecă din
// luptă, dar neclară, întunecată și cu colțurile stinse, ca să se citească
// pagina de deasupra. Trei pași, în ordinea în care îi face un fotograf:
//
//   1. ESTOMPAREA: media a 24 de puncte așezate pe o spirală în jurul
//      pixelului. O spirală (unghiul de aur, ~137,5°) împrăștie punctele
//      uniform cu puține probe; un pătrat de 5×5 ar da aproape același cost
//      și margini „în trepte".
//   2. LUMINA: culoarea se înmulțește cu `tenta` și cu `luminozitate`. Tenta
//      caldă trage albastrul rece al bibliotecii spre sepia hărții.
//   3. VINIETA: colțurile se întunecă după poziția pe ECRAN (`SCREEN_UV`), nu
//      în imagine — imaginea e tăiată ca să umple ecranul, deci centrul ei nu
//      e centrul ecranului.
//
// De ce shader și nu o imagine pregătită: aceeași poză, fără o a doua copie
// de 1-2 MB în proiect, iar cifrele de mai jos se reglează din Inspector.

// Raza estompării, în pixeli ai IMAGINII (nu ai ecranului). Fundalul are
// 2752 px lățime și se vede pe ~1150, deci 1 px de ecran ≈ 2,4 px de imagine.
uniform float raza : hint_range(0.0, 60.0) = 22.0;
uniform float luminozitate : hint_range(0.0, 1.0) = 0.42;
uniform vec4 tenta : source_color = vec4(1.0, 0.86, 0.68, 1.0);
uniform float vinieta : hint_range(0.0, 1.0) = 0.7;

const int PROBE = 24;
const float UNGHI_AUR = 2.39996;

void fragment() {
	vec4 suma = vec4(0.0);
	for (int i = 0; i < PROBE; i++) {
		// sqrt: punctele se răresc spre margine exact cât cere aria cercului,
		// deci fiecare acoperă cam aceeași suprafață.
		float r = sqrt((float(i) + 0.5) / float(PROBE)) * raza;
		float a = float(i) * UNGHI_AUR;
		suma += texture(TEXTURE, UV + vec2(cos(a), sin(a)) * r * TEXTURE_PIXEL_SIZE);
	}
	vec3 culoare = suma.rgb / float(PROBE);
	culoare *= tenta.rgb * luminozitate;

	float d = distance(SCREEN_UV, vec2(0.5));
	culoare *= 1.0 - vinieta * smoothstep(0.25, 0.85, d);

	COLOR = vec4(culoare, 1.0);
}
