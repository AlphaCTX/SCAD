# HDD/SSD Rack met schuif-lock

Een parametrisch OpenSCAD-ontwerp voor een 3.5"/2.5" drive-rack met meerdere
bays en een **werkende schuif-lock (slider)** aan de voorzijde die elke tray
vergrendelt.

## Bestand

- `drive_rack.scad` – het volledige, parametrische ontwerp (rack, tray en slider).

## Onderdelen

- **Rack (behuizing)** – stapelbare bays met geleiderails, ventilatie-uitsparing,
  SATA-doorvoer en een keeper-kolom aan de rechterzijde met per bay een
  grendel-pocket.
- **Universele tray** – montagegaten voor zowel 3.5" HDD als 2.5" SSD,
  ventilatiekanalen en een captive T-geleiding op het front voor de slider.
- **Slider** – los printbaar T-profiel met duim-greep en een dead-bolt.

## Werking van de lock

1. De slider zit gevangen in een holle T-geleiding op het tray-front en kan
   alleen zijwaarts (X) schuiven; hij kan niet losvallen.
2. In de **vergrendelde** stand steekt de dead-bolt in de pocket van de
   keeper-kolom op het rack. De voorwand van die pocket blokkeert de tray,
   zodat deze niet naar voren kan worden getrokken.
3. Schuif de slider naar binnen (**ontgrendeld**) en de bolt trekt terug binnen
   de tray-omtrek, waarna de tray vrij naar buiten glijdt.

## Renderen

Open `drive_rack.scad` in OpenSCAD en kies een onderdeel via de
`render_mode`-parameter (Customizer of `-D`):

| `render_mode`        | Resultaat                                             |
|----------------------|-------------------------------------------------------|
| `all`                | Volledige assemblage (rack + tray + slider)           |
| `rack`               | Alleen de behuizing                                   |
| `tray`               | Alleen de tray                                         |
| `slider`             | Alleen de slider (printklaar)                          |
| `lock_top_section`   | Horizontale doorsnede door de grendel                 |
| `lock_side_section`  | Verticale doorsnede door grendel/keeper               |

Met `lock_state` (`locked` / `unlocked`) toon je de slider vergrendeld of
ontgrendeld.

Voorbeeld – exporteer de slider naar STL:

```sh
openscad -o slider.stl -D 'render_mode="slider"' drive_rack.scad
```

## Belangrijkste parameters

De maten staan bovenin het bestand, gegroepeerd per sectie:

- **Drive Dimensions** – HDD/SSD breedte en lengte.
- **Tray & Bay Dimensions** – tray-hoogte, aantal bays en railmaten.
- **Slider Lock Parameters** – grendelmaat, schuifslag en speling.
- **Lock Keeper Column** – breedte en diepte van de keeper-kolom.

Pas `clearance` en `sl_clear` aan op de toleranties van je eigen printer.
