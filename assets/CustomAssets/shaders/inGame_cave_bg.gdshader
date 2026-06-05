shader_type canvas_item;

// ==========================================
// UNIFORMS - Rythmizontai apo to Godot Inspector
// ==========================================

// Taxytita tis synolikis kinisis (vroxh, drips)
uniform float time_scale : hint_range(0.1, 2.0) = 1.0;

// Xroma ton rixon ths spilias
uniform vec4 stone_color : source_color = vec4(0.22, 0.22, 0.22, 1.0);

// Xroma tis fotias ton pyrson
uniform vec4 torch_color : source_color = vec4(1.0, 0.55, 0.12, 1.0);

// Xroma tis vroxis
uniform vec4 rain_color : source_color = vec4(0.27, 0.47, 0.60, 1.0);

// Xroma tou nerou sto patwma
uniform vec4 water_color : source_color = vec4(0.10, 0.25, 0.45, 1.0);

// Thesis tou aristera pyrso (x, y se UV space 0.0 - 1.0)
uniform vec2 torch_left  = vec2(0.12, 0.45);

// Thesis tou deksia pyrso (x, y se UV space 0.0 - 1.0)
uniform vec2 torch_right = vec2(0.88, 0.45);


// ==========================================
// VOITHITIKES SYNARTISEIS
// ==========================================

// Hash: Epistrefei enan pseudotyxaio arithmo 0.0-1.0 apo ena vec2
// Xrisimopoieitai gia na dosoume diaforeto mikos se kathe stalaktiti
float hash(vec2 point) {
    return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453);
}

// Cave_ceiling: Epistrefei to Y tis orofis gia kathe X tis othonis
// Ta sin() dinoune fysikoteri morfh sthn orofi (oxi evtheia grammi)
float cave_ceiling(float screen_x) {
    return 0.18
        + sin(screen_x * 3.5) * 0.04   // megalo "kymata" orofis
        + sin(screen_x * 7.2 + 0.8) * 0.02; // mikroleptomereies
}

// Cave_floor: Epistrefei to Y tou patwmatos gia kathe X tis othonis
// Paromomio me tin orofi alla pio omo (ligotero varys)
float cave_floor(float screen_x) {
    return 0.82
        - abs(sin(screen_x * 4.1 + 1.0)) * 0.03
        - abs(sin(screen_x * 8.5)) * 0.015;
}


// ==========================================
// KYRIOS SHADER - Ekteleitai gia KATHE pixel
// ==========================================
void fragment() {
    // Xronos pou proxwraei - pollaplasiazetai me time_scale gia elegxo taxytitas
    float time = TIME * time_scale * 0.25;

    // UV = position tou pixel (0.0, 0.0) = panw aristera, (1.0, 1.0) = katw deksia
    vec2 pixel_uv = UV;

    // Ypologizw pou vrisketai h orofi kai to patwma gia ayto to pixel
    float ceiling_y = cave_ceiling(pixel_uv.x);
    float floor_y   = cave_floor(pixel_uv.x);


    // ==========================================
    // ΒΗΜΑ 1: ΤΟΙΧΟΙ ΣΠΗΛΙΑΣ
    // ==========================================
    vec4 pixel_color;

    if (pixel_uv.y < ceiling_y || pixel_uv.y > floor_y) {
        // To pixel einai mesa ston toixo (orofi h patwma)
        // Smoothstep: kanei smooth metavasi sto xrwma sto orio toixou/aera
        float edge_distance = smoothstep(0.0, 0.012,
            min(abs(pixel_uv.y - ceiling_y), abs(pixel_uv.y - floor_y)));
        // Pio anoixto xrwma sto orio (edge highlight), pio skotino sto vayos
        pixel_color = mix(vec4(0.38, 0.38, 0.38, 1.0), stone_color, edge_distance);
    } else {
        // To pixel einai aeras mesa stin spilia - skotino background
        pixel_color = stone_color * 0.72;
    }


    




    // ==========================================
    // ΒΗΜΑ 4: ΒΡΟΧΗ (3 parallax layers)
    // ==========================================
    // 3 layers vroxis me diaforetiko depth:
    // Layer 0 = makria (argi, diafani)
    // Layer 2 = konta (grigori, pio emphanhs)
    for (int rain_layer = 0; rain_layer < 2; rain_layer++) {

        // Taxytita katavasis
        float drop_speed = 0.6 + float(rain_layer) * 0.25;

        // Klisi tis vroxis (poso loksa peftei)
        float drop_slant = 0.025 + float(rain_layer) * 0.01;

        // Diafaneia - ta konta layers einai pio emfanh
        float drop_alpha = 0.12 + float(rain_layer) * 0.10;

        // Apostasi metaxy stagonon
        float drop_spacing = 0.07 - float(rain_layer) * 0.15;

        // Metakinoume to UV coordinate gia na dhmiourgoume tin kinoymeni vroxh:
        // - X: prosthetoume klisi + oristiki olisthisi gia na peftei loxia
        // - Y: afairoume ton xrono gia na peftei katw (- = pros ta katw)
        vec2 rain_uv = vec2(
            pixel_uv.x + pixel_uv.y * drop_slant + time * drop_slant * 0.3,
            pixel_uv.y - time * drop_speed
        );

        // fract() dhmiourghei epanalamvanomeno pattern (to "grid" twn stagonwn)
        float rain_x = fract(rain_uv.x / drop_spacing);
        float rain_y = fract(rain_uv.y / 0.15);

        // An to pixel vrisketai entos mias stagonas kai entos tis spilias
        if (rain_x < 0.06 && rain_y < 0.35
            && pixel_uv.y > ceiling_y
            && pixel_uv.y < floor_y) {
            pixel_color = mix(pixel_color, rain_color, drop_alpha);
        }
    }

    // Teliko xrwma tou pixel
    COLOR = pixel_color;
}                    