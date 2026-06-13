// =========================================================================
// HDD/SSD RACK – MET WERKENDE SCHUIF-LOCK (SLIDER) AAN DE VOORZIJDE
// v3: captive T-geleiding + dead-bolt die in een keeper-kolom op het rack grijpt
// -------------------------------------------------------------------------
// Werking van de lock:
//   * Op het front van iedere tray zit een schuif (slider) die in een holle
//     T-geleiding zijwaarts (X) heen en weer glijdt en niet kan losvallen.
//   * De slider draagt een grendel (bolt) die in de VERGRENDELDE stand in een
//     pocket van de keeper-kolom op het rack steekt. De voorwand van die
//     pocket blokkeert dan de tray: hij kan niet meer naar voren worden
//     getrokken.
//   * Schuif de slider naar binnen (ONTGRENDELD) en de grendel trekt terug
//     binnen de tray-omtrek, zodat de tray vrij naar buiten kan.
// =========================================================================

/* [Render Options] */
render_mode = "all";   // [all, rack, tray, slider, lock_top_section, lock_side_section]
lock_state  = "locked"; // [locked, unlocked]

/* [Global Dimensions] */
$fn = 48;
clearance = 0.5;
wall_thickness = 3.0;

/* [Drive Dimensions] */
hdd_w = 101.6;
hdd_l = 147.0;
ssd_w = 69.85;
ssd_l = 100.0;

/* [Tray & Bay Dimensions] */
tray_h = 28.0;
num_bays = 4;
rail_w = 4.0;
rail_h = 3.0;

/* [Slider Lock Parameters] */
sl_clear     = 0.4;    // speling rondom de slider in de geleiding
bolt_t       = 5.0;    // grendel-dikte in Y (diepte, vóór het front)
bolt_h       = 8.0;    // grendel-hoogte in Z
bolt_travel  = 5.0;    // schuifslag (X) van ontgrendeld -> vergrendeld
flange_h     = 11.0;   // hoogte (Z) van de gevangen flens in de T-geleiding
neck_h       = 5.0;    // hoogte (Z) van de hals door de gleuf
sl_len       = 22.0;   // lengte (X) van de flens/slider-lichaam
handle_w     = 7.0;    // breedte (X) van de duim-greep
handle_y     = 2.0;    // hoe ver de greep vóór de geleiding uitsteekt (Y)

/* [Lock Keeper Column] */
col_w        = 6.0;    // breedte (X) van de keeper-kolom op het rack
col_depth    = 11.0;   // diepte (Y) van de kolom, vóór het rack-front
keeper_wall_t = 1.0;   // achterwand-dikte (X) die in de kolom blijft staan

// --- Afgeleide hoofdmaten ---------------------------------------------------
inner_w = hdd_w + (wall_thickness * 2) + (clearance * 2);
rack_h  = (tray_h + clearance) * num_bays + wall_thickness;
tray_w  = hdd_w + (wall_thickness * 2);
rack_l  = hdd_l + wall_thickness + 2;

// --- Gedeelde referenties (één bron van waarheid voor alle onderdelen) ------
tray_ox       = wall_thickness + clearance;     // globale X-oorsprong van de tray
right_inner_x = wall_thickness + inner_w;        // globale X van binnenvlak rechter rackwand
lock_z        = tray_h / 2;                       // tray-lokale Z van het grendel-hart

// Boss (geleidingsblok) op het tray-front, in tray-lokale coördinaten.
boss_x0   = 74;
boss_x1   = 110;
boss_h    = flange_h + 3;            // hoogte (Z) van het geleidingsblok
boss_y    = -wall_thickness;         // achterkant boss = voorvlak frontpaneel
boss_yf   = boss_y - (bolt_t + (neck_h) + 1) - handle_y; // voorvlak boss

// Grendel: in tray-lokale X is de ingetrokken tip gelijk aan tray_w (= omtrek).
bolt_retract_tip = tray_w;           // tray-lokale X van de tip in ONTGRENDELDE stand
flange_x0_home   = boss_x0 + 6;      // tray-lokale X van flens-linkerkant (ontgrendeld)

// Y-indeling van de slider (tray-lokaal, voorvlak frontpaneel op y = -wall_thickness)
fl_y1 = -wall_thickness;             // flens/grendel achterkant (tegen het paneel)
fl_y0 = fl_y1 - bolt_t;              // flens/grendel voorkant
neck_y0 = fl_y0 - neck_h;            // hals voorkant
handle_y0 = neck_y0 - handle_y;      // greep voorkant

// Schuif-offset afhankelijk van de stand
slide_offset = (lock_state == "locked") ? bolt_travel : 0;

// =========================================================================
// BEHUIZING
// =========================================================================
module drive_rack() {
    difference() {
        union() {
            cube([inner_w + (wall_thickness * 2), rack_l, rack_h]);

            // --- KEEPER-KOLOM: massieve kolom aan de rechter rackwand, steekt
            //     naar voren. Hierin zitten per bay de grendel-pockets. ---
            translate([right_inner_x, -col_depth, 0])
                cube([col_w, col_depth, rack_h]);
        }

        // Bay-uitsparingen + SATA-doorvoer
        for (i = [0 : num_bays - 1]) {
            z_pos = wall_thickness + i * (tray_h + clearance);
            translate([wall_thickness, -1, z_pos])
                cube([inner_w, rack_l - wall_thickness + 1, tray_h]);
            translate([inner_w - 55, rack_l - wall_thickness - 1, z_pos + 3])
                cube([50, wall_thickness + 2, 14]);
        }

        // Ventilatie
        translate([-1, 25, 12])
            cube([inner_w + wall_thickness * 5, rack_l - 60, rack_h - 24]);

        // --- GRENDEL-POCKETS in de keeper-kolom (per bay) ---
        for (i = [0 : num_bays - 1]) {
            zc = wall_thickness + i * (tray_h + clearance) + lock_z;
            translate([right_inner_x - 0.2,
                       fl_y0 - sl_clear,
                       zc - bolt_h/2 - sl_clear])
                cube([col_w - keeper_wall_t + 0.2,   // laat achterwand staan
                      bolt_t + sl_clear * 2,
                      bolt_h + sl_clear * 2]);
        }
    }

    // Rails per bay
    for (i = [0 : num_bays - 1]) {
        translate([0, 0, wall_thickness + i * (tray_h + clearance)]) {
            translate([wall_thickness, 0, tray_h / 2 - rail_h / 2])
                cube([rail_w, rack_l - wall_thickness, rail_h]);
            translate([wall_thickness + inner_w - rail_w, 0, tray_h / 2 - rail_h / 2])
                cube([rail_w, rack_l - wall_thickness, rail_h]);
        }
    }
}

// =========================================================================
// SLIDER (los printbaar) — T-profiel: gevangen flens + hals + greep + grendel
// Getekend in tray-lokale coördinaten; 'offset' = schuifslag in +X.
// =========================================================================
module slider(offset = 0) {
    sx = offset;
    union() {
        // Flens (breed in Z, wordt gevangen in de T-kamer)
        translate([flange_x0_home + sx, fl_y0, lock_z - flange_h/2])
            cube([sl_len, bolt_t, flange_h]);
        // Hals (smal in Z, steekt door de voorgleuf van het geleidingsblok)
        translate([flange_x0_home + sx, neck_y0, lock_z - neck_h/2])
            cube([sl_len, fl_y0 - neck_y0, neck_h]);
        // Duim-greep aan de voorzijde
        translate([flange_x0_home + sx, handle_y0, lock_z - flange_h/2])
            cube([handle_w, neck_y0 - handle_y0, flange_h]);
        // Duim-ribbels op de greep
        for (gz = [-3, 0, 3])
            translate([flange_x0_home + sx, handle_y0 + 0.2, lock_z + gz - 0.5])
                cube([handle_w, 0.8, 1]);
        // Grendel (dead-bolt): vanaf het rechter eind van de flens naar +X
        translate([flange_x0_home + sl_len + sx, fl_y0, lock_z - bolt_h/2])
            cube([bolt_retract_tip - (flange_x0_home + sl_len) , bolt_t, bolt_h]);
    }
}

// =========================================================================
// UNIVERSELE TRAY (met captive T-geleiding op het front)
// =========================================================================
module universal_tray() {
    difference() {
        union() {
            // Basisplaat
            cube([tray_w, hdd_l, wall_thickness + 2]);
            // Zijwanden
            translate([tray_w - wall_thickness, 0, 0])
                cube([wall_thickness, hdd_l, tray_h - clearance]);
            cube([wall_thickness, hdd_l, tray_h - clearance]);
            // Frontpaneel (blijft massief; geleiding zit ervóór)
            translate([0, -wall_thickness, 0])
                cube([tray_w, wall_thickness, tray_h - clearance]);

            // --- GELEIDINGSBLOK (boss) vóór het front; T-kanaal eruit gesneden ---
            translate([boss_x0, boss_yf, lock_z - boss_h/2])
                cube([boss_x1 - boss_x0, boss_y - boss_yf, boss_h]);
        }

        // --- T-KAMER: brede gleuf (Z) die de flens vangt; door in X ---
        translate([boss_x0 - 1, fl_y0 - sl_clear, lock_z - flange_h/2 - sl_clear])
            cube([boss_x1 - boss_x0 + 2,
                  (fl_y1 - fl_y0) + sl_clear + 1,           // tot tegen het paneel
                  flange_h + sl_clear * 2]);

        // --- VOORGLEUF: smalle hals-sleuf (Z) door de voorwand van het blok ---
        translate([boss_x0 - 1, boss_yf - 1, lock_z - neck_h/2 - sl_clear])
            cube([boss_x1 - boss_x0 + 2,
                  (fl_y0 - boss_yf) + 1,
                  neck_h + sl_clear * 2]);

        // --- Doorgang aan +X voor de grendel (op flens-hoogte) ---
        translate([boss_x1 - 0.01, fl_y0 - sl_clear, lock_z - bolt_h/2 - sl_clear])
            cube([10, bolt_t + sl_clear * 2, bolt_h + sl_clear * 2]);

        // Rail-uitsparingen
        translate([-0.1, -5, tray_h / 2 - (rail_h + clearance) / 2])
            cube([rail_w + clearance + 0.1, hdd_l + 10, rail_h + clearance]);
        translate([tray_w - rail_w - clearance, -5, tray_h / 2 - (rail_h + clearance) / 2])
            cube([rail_w + clearance + 0.1, hdd_l + 10, rail_h + clearance]);

        // SSD-verdieping
        translate([(tray_w - ssd_w)/2, (hdd_l - ssd_l)/2, wall_thickness])
            cube([ssd_w, ssd_l, 20]);

        // Ventilatiekanaal
        translate([tray_w/2 - 15, 20, -1])
            cube([30, hdd_l - 40, wall_thickness + 2]);
        translate([20, hdd_l/2 - 15, -1])
            cube([tray_w - 40, 30, wall_thickness + 2]);

        // Schroefgaten HDD & SSD
        for (y = [14.22, 57.15, 101.6]) {
            translate([-1, y, 6.35]) rotate([0, 90, 0]) cylinder(d=4.0, h=wall_thickness + 2);
            translate([wall_thickness - 1.2, y, 6.35]) rotate([0, 90, 0]) cylinder(d=7.5, h=20);
            translate([tray_w - wall_thickness - 1, y, 6.35]) rotate([0, 90, 0]) cylinder(d=4.0, h=wall_thickness + 2);
            translate([tray_w - 20, y, 6.35]) rotate([0, 90, 0]) cylinder(d=7.5, h=20 - wall_thickness + 1.2);
        }
        for (x = [(tray_w - 61.72)/2, (tray_w + 61.72)/2]) {
            for (y = [(hdd_l - 76.6)/2, (hdd_l - 76.6)/2 + 76.6]) {
                translate([x, y, -1]) cylinder(d=3.4, h=wall_thickness + 5);
                translate([x, y, -1]) cylinder(d=6.5, h=wall_thickness - 1.2 + 1);
            }
        }
    }
}

// =========================================================================
// RENDEREN
// =========================================================================
module assembly() {
    drive_rack();
    translate([tray_ox, 0, wall_thickness])
        universal_tray();
    // Slider op de onderste tray, in de gekozen stand
    translate([tray_ox, 0, wall_thickness])
        slider(slide_offset);
}

if (render_mode == "all") {
    assembly();
} else if (render_mode == "rack") {
    drive_rack();
} else if (render_mode == "tray") {
    universal_tray();
} else if (render_mode == "slider") {
    slider(0);
} else if (render_mode == "lock_top_section") {
    // Horizontale doorsnede op grendel-hoogte: laat zien dat de grendel in de
    // pocket grijpt (locked) of vrij is (unlocked).
    zc = wall_thickness + lock_z;
    projection(cut = true)
        translate([0, 0, -zc]) assembly();
} else if (render_mode == "lock_side_section") {
    // Verticale doorsnede door de grendel/keeper (vlak X).
    xc = right_inner_x + col_w/2;
    projection(cut = true)
        rotate([0, -90, 0]) translate([-xc, 0, 0]) assembly();
}
