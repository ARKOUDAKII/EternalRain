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
    // ΒΗΜΑ 2: ΣΤΑΛΑΚΤΙΤΕΣ
    // ==========================================
    // Kanw loop gia 8 stalaktites, o kathenas se diaforetiko X
    for (int stalactite_index = 0; stalactite_index < 8; stalactite_index++) {

        // Kathe stalaktitis exei diaforeto X (isotaxeis apostaseis)
        float stalactite_x = 0.08 + float(stalactite_index) * 0.12;

        // Tyxaio mikos gia kathe stalaktiti (vasi tou index tou)
        float stalactite_length = 0.04 + hash(vec2(float(stalactite_index), 0.0)) * 0.07;

        // Platos tou stalaktiti se UV space
        float stalactite_width = 0.012;

        // An to pixel vrisketai entos toy stalaktiti...
        if (abs(pixel_uv.x - stalactite_x) < stalactite_width
            && pixel_uv.y > ceiling_y
            && pixel_uv.y < ceiling_y + stalactite_length) {

            // Vapse to pixel me to xrwma petras
            pixel_color = vec4(0.35, 0.35, 0.35, 1.0);

            // --- Stagonida vroxis pou peftei apo ton stalaktiti ---
            // fract() kanei to drip_progress na kykloforei 0.0 -> 1.0 -> 0.0 -> ...
            // to float(stalactite_index) * 0.37 kanei kathe stalaktiti na arxizei
            // se diaforeto simeio tou kyklou, gia na min peftoun oloi taytoxrona
            float drip_progress = fract(time * 0.3 + float(stalactite_index) * 0.37);

            // H stagonida xekinaei apo tin akri tou stalaktiti kai katevainei
            float drip_y = ceiling_y + stalactite_length + drip_progress * 0.12;

            // An to pixel einai poly konta stin thesis tis stagonidas, vapse to
            if (abs(pixel_uv.x - stalactite_x) < 0.006
                && abs(pixel_uv.y - drip_y) < 0.008) {
                pixel_color = rain_color * 0.9;
            }
        }
    }


    // ==========================================
    // ΒΗΜΑ 3: ΝΕΡΟ ΣΤΟ ΠΑΤΩΜΑ (mish othoni kai deksia)
    // ==========================================
    float water_start_x   = 0.5;  // Apo pou arxizei to nero (50% tis othonis)
    float water_surface_y = floor_y - 0.018; // H epifaneia tou nerou (ligo panw apo to patwma)

    if (pixel_uv.x > water_start_x
        && pixel_uv.y > water_surface_y
        && pixel_uv.y < floor_y) {

        // Smooth fade-in sto orio aristera tou nerou (den kovetai apotoma)
        float fade_in = smoothstep(water_start_x, water_start_x + 0.08, pixel_uv.x);

        // Shimmer: mikres alages lamprotitas gia efekt kymaton
        float shimmer = sin(pixel_uv.x * 40.0 + time * 2.0) * 0.08;

        // Depth: oso pio katw, oso pio skotino (vaythera)
        float depth_factor = (pixel_uv.y - water_surface_y) / 0.018;
        vec4  deep_water   = mix(water_color * 1.4, water_color, depth_factor);

        pixel_color = mix(pixel_color, deep_water, fade_in * (0.75 + shimmer));
    }

    // Lamberi grammi stin epifaneia tou nerou (reflection tis fotias)
    if (pixel_uv.x > water_start_x
        && abs(pixel_uv.y - water_surface_y) < 0.004) {
        float fade_in   = smoothstep(water_start_x, water_start_x + 0.08, pixel_uv.x);
        // Sin() gia kymatisman highlight panw stin epifaneia
        float highlight = sin(pixel_uv.x * 60.0 + time * 3.0) * 0.5 + 0.5;
        pixel_color     = mix(pixel_color, rain_color * 1.2, fade_in * highlight * 0.5);
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


    // ==========================================
    // ΒΗΜΑ 5: TORCH GLOW (fwtia pyrswn)
    // ==========================================
    // Flicker: sin() me diaforetikes sixnotites dinoun fysikoteri tremoyla fotias
    float left_flicker  = 0.88 + sin(time * 7.3) * 0.07  + sin(time * 13.1) * 0.07;
    float right_flicker = 0.88 + sin(time * 6.9 + 1.2) * 0.07 + sin(time * 11.7) * 0.08;

    // Apostasi apo ton pyro - to vec2(1.0, 0.6) kanei tin fwtia pio platia orisontia
    float left_dist  = length((pixel_uv - torch_left)  * vec2(1.0, 0.6));
    float right_dist = length((pixel_uv - torch_right) * vec2(1.0, 0.6));

    // pow() kanei tin fwtia na eksasfaleizei pio grigora - pio kendrikis eksodo
    // max(0.0, ...) apotreptei arnhtikes times
    float left_glow  = pow(max(0.0, 1.0 - left_dist  / 0.32), 2.2) * left_flicker  * 0.55;
    float right_glow = pow(max(0.0, 1.0 - right_dist / 0.32), 2.2) * right_flicker * 0.55;

    // Prosthetoume to glow xrwma ston teliko pixel
    pixel_color.rgb += torch_color.rgb * left_glow;
    pixel_color.rgb += torch_color.rgb * right_glow;

    // Clamp: diamorphonoume ta xrwmata sto 0.0-1.0 range (apofygoume overflow)
    pixel_color.rgb = clamp(pixel_color.rgb, 0.0, 1.0);

    // Teliko xrwma tou pixel
    COLOR = pixel_color;
}                    