// =========================================================================
// HDD/SSD RACK – MET SCHUIF-LOCK (SLIDER) AAN DE VOORZIJDE
// v2: front-venster, richel boven tray-profiel, holle T-geleiding
// =========================================================================

/* [Render Options] */
render_mode = "all"; // [all, rack, tray, slider, tray_front_section]

/* [Global Dimensions] */
$fn = 60;
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
sl_plate_w   = 26.0;
sl_plate_h   = 9.0;
sl_plate_t   = 2.5;
sl_neck_w    = 14.0;
sl_neck_h    = 5.0;
sl_travel    = 12.0;
sl_clear     = 0.45;
sl_nose_y    = 4.0;
cz_ledge_y   = 3.0;
cz_ledge_h   = 4.0;
cz_ledge_w   = 14.0;

inner_w = hdd_w + (wall_thickness * 2) + (clearance * 2);
rack_h = (tray_h + clearance) * num_bays + wall_thickness;
tray_w = hdd_w + (wall_thickness * 2);
rack_l = hdd_l + wall_thickness + 2;

guide_cx    = 30.0;
slot_z0     = 6.0;
slot_h      = sl_neck_h + sl_clear*2;
guide_blk_h = slot_h + 6;
guide_blk_w = sl_plate_w + sl_travel + 6;
guide_blk_t = sl_plate_t + sl_clear + 2;

module drive_rack() {
    difference() {
        cube([inner_w + (wall_thickness * 2), rack_l, rack_h]);
        for (i = [0 : num_bays - 1]) {
            z_pos = wall_thickness + i * (tray_h + clearance);
            translate([wall_thickness, -1, z_pos])
                cube([inner_w, rack_l - wall_thickness + 1, tray_h]);
            translate([inner_w - 55, rack_l - wall_thickness - 1, z_pos + 3])
                cube([50, wall_thickness + 2, 14]);
        }
        translate([-1, 25, 12])
            cube([inner_w + wall_thickness * 5, rack_l - 60, rack_h - 24]);
    }
    for (i = [0 : num_bays - 1]) {
        translate([0, 0, wall_thickness + i * (tray_h + clearance)]) {
            translate([wall_thickness, 0, tray_h / 2 - rail_h / 2])
                cube([rail_w, rack_l - wall_thickness, rail_h]);
            translate([wall_thickness + inner_w - rail_w, 0, tray_h / 2 - rail_h / 2])
                cube([rail_w, rack_l - wall_thickness, rail_h]);
        }
    }
    for (i = [0 : num_bays - 1]) {
        z_pos = wall_thickness + i * (tray_h + clearance);
        translate([wall_thickness + clearance + guide_cx - cz_ledge_w/2,
                   -cz_ledge_y,
                   z_pos + tray_h - cz_ledge_h])
            cube([cz_ledge_w, cz_ledge_y, cz_ledge_h]);
    }
}

module slider() {
    union() {
        translate([-sl_plate_w/2, 0, -(sl_plate_h - sl_neck_h)/2])
            cube([sl_plate_w, sl_plate_t, sl_plate_h]);
        translate([-sl_neck_w/2, -8, 0])
            cube([sl_neck_w, sl_plate_t + 8, sl_neck_h]);
        translate([-sl_neck_w/2, -8 - sl_nose_y, 0])
            cube([sl_neck_w, sl_nose_y, sl_neck_h]);
        for (gx = [-6, -3, 0, 3, 6])
            translate([gx-0.5, -1, -(sl_plate_h - sl_neck_h)/2])
                cube([1, 1.2, sl_plate_h]);
    }
}

module universal_tray() {
    difference() {
        union() {
            cube([tray_w, hdd_l, wall_thickness + 2]);
            translate([tray_w - wall_thickness, 0, 0])
                cube([wall_thickness, hdd_l, tray_h - clearance]);
            cube([wall_thickness, hdd_l, tray_h - clearance]);
            translate([0, -wall_thickness, 0])
                cube([tray_w, wall_thickness, tray_h - clearance]);
            translate([guide_cx - guide_blk_w/2,
                       -wall_thickness - guide_blk_t,
                       slot_z0 - 3])
                cube([guide_blk_w, guide_blk_t, guide_blk_h]);
        }
        translate([guide_cx - (sl_neck_w + sl_travel + sl_clear*2)/2,
                   -wall_thickness - guide_blk_t - 1,
                   slot_z0])
            cube([sl_neck_w + sl_travel + sl_clear*2,
                  wall_thickness + guide_blk_t + 2,
                  slot_h]);
        translate([guide_cx - (sl_plate_w + sl_travel + sl_clear*2)/2,
                   -wall_thickness - guide_blk_t - 0.1,
                   slot_z0 - (sl_plate_h - sl_neck_h)/2 - sl_clear])
            cube([sl_plate_w + sl_travel + sl_clear*2,
                  guide_blk_t - 1.2,
                  sl_plate_h + sl_clear*2]);
        translate([-0.1, -5, tray_h / 2 - (rail_h + clearance) / 2])
            cube([rail_w + clearance + 0.1, hdd_l + 10, rail_h + clearance]);
        translate([tray_w - rail_w - clearance, -5, tray_h / 2 - (rail_h + clearance) / 2])
            cube([rail_w + clearance + 0.1, hdd_l + 10, rail_h + clearance]);
        translate([(tray_w - ssd_w)/2, (hdd_l - ssd_l)/2, wall_thickness])
            cube([ssd_w, ssd_l, 20]);
        translate([tray_w/2 - 15, 20, -1])
            cube([30, hdd_l - 40, wall_thickness + 2]);
        translate([20, hdd_l/2 - 15, -1])
            cube([tray_w - 40, 30, wall_thickness + 2]);
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

module assembly() {
    drive_rack();
    translate([wall_thickness + clearance, 0, wall_thickness])
        universal_tray();
    translate([wall_thickness + clearance + guide_cx - sl_travel/2,
               -wall_thickness - sl_clear,
               wall_thickness + slot_z0])
        slider();
}

if (render_mode == "all") {
    assembly();
} else if (render_mode == "rack") {
    drive_rack();
} else if (render_mode == "tray") {
    universal_tray();
} else if (render_mode == "slider") {
    slider();
} else if (render_mode == "tray_front_section") {
    z_cut = wall_thickness + slot_z0 + sl_neck_h/2;
    projection(cut = true)
        translate([0, 0, -z_cut])
            assembly();
}
