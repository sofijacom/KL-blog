+++
date = '2025-03-29T22:33:00+01:00'
title = 'Keychron Q1 Max Customization'
slug = 'keychron-q1-max-customization'
author = 'schemar'
lastmod = '2025-03-29T21:44:50+01:00'
description = "When I wanted to customize my Q1 Max, I had difficulties finding the right information. So I decided to write it down."
+++

Documentation on Keychron customization can be hard to find.
Most information is spread across different sources, e.g. reddit, some of it is outdated, and some of it is wrong.

Therefore, I decided to document my findings here.

> ⚠️ I am by no means an expert on this topic. Proceed at your own risk.

## Using Keychron Launcher

You can achieve some advanced key mappings with the Keychron Launcher.
You don't always need [QMK](https://qmk.fm) or [Tap Dance](https://docs.qmk.fm/features/tap_dance).

### Mod Tap

With [Mod Tap](https://docs.qmk.fm/mod_tap) you can assign a key to act as a modifier while held and as a normal key when tapped.
A modifier is for example `shift` or `control`.

An example how I use Mod Tap: When I press the `semicolon` key, it acts as `semicolon`.
But when I hold down the `semicolon` key, it acts as `control` and I can comfortably press, for example, `control-a`.
Another example are [home row mods](https://precondition.github.io/home-row-mods).

You can also specify more than one modifier to hold down; for example, you could use this to build a hyper-key when holding `capslock`.
("hyper" means the combination of `control`, `option`, `command`, and `shift`.)

To use Mod Tap with the Keychron Launcher, do the following:

> 1. Select the key you want to use
> 2. In the bottom menu, select "custom", then "any"
> 3. Here, you can put in a QMK function, in this case `MT()`
>
> For my `semicolon` example, I would put in `MT(MOD_LCTL, KC_SCLN)`.

Read the [Mod Tap documentation](https://docs.qmk.fm/mod_tap) to find out more, for example how to combine modifiers (e.g. `MOD_LCTL | MOD_LSFT`).
Be sure to review the ["Caveats"](https://docs.qmk.fm/mod_tap#caveats) section.

> ⚠️ Currently, the `kc` argument of `MT()` is limited to the [basic keycode](https://docs.qmk.fm/keycodes_basic) set.

### Layer Tap

With [Layer Tap](https://docs.qmk.fm/feature_layers) you can assign a key to act as a layer switch while held and as a normal key when tapped.

An example how I use Layer Tap: When I press the `capslock` key, it acts as `escape`.
But when I hold the `capslock` key, it activates another layer where I have `hjkl` mapped to the arrow keys.

To use Layer Tap with the Keychron Launcher, do the following:

> 1. Select the key you want to use
> 2. In the bottom menu, select "custom", then "any"
> 3. Here, you can put in a QMK function, in this case `LT()`
>
> For my `capslock` example, I would put in `LT(2, KC_CAPS)`.

Read the [Layers documentation](https://docs.qmk.fm/feature_layers) to find out more about layers.
Be sure to review the ["Caveats"](https://docs.qmk.fm/feature_layers#caveats) section.

## Using QMK

To use [QMK](https://qmk.fm) with the Keychron Q1 Max, you need to fork [Keychron's fork of QMK](https://github.com/Keychron/qmk_firmware).
For example, my fork is located [here](https://github.com/schemar/qmk_firmware).

When you set up your QMK environment, you can run `qmk setup` with the `-H <path_to_repo>` flag to point to your local clone of your own QMK fork of Keychron's fork.
It will print a minor warning that upstream isn't set to the original QMK repo, but you can decide ignore that if your upstream is Keychron's fork.

Keychron's QMK repo includes custom branches for their keyboards.
For example, the Q1 Max is in the `wireless_playground` branch.
You find your keyboard under `keyboards/keychron/`.

Each keyboard has its own readme, which also explains how to build and flash the firmware.
For example, to flash the Q1 Max firmware, you can run the following command from the repository root:

```bash
make keychron/q1_max/ansi_encoder:default:flash
```

1. If you use an iso or jis layout, replace `ansi_encoder` with `iso_encoder` or `jis_encoder`
1. If you created your own keymap, replace `default` with your keymap's name

To put the Q1 Max into bootloader mode, hold the `esc` key while plugging in its cable.

### Adding A Layer

Within the `ansi_encoder` directory:

1. `keymaps/<keymap>/keymap.c`: add identifier to `enum layers`
2. `keymaps/<keymap>/keymap.c`: add layer to `keymaps` array
3. `keymaps/<keymap>/keymap.c`: add layer to `encoder_map` (at bottom)
4. `config.h`: Add or update the `#define DYNAMIC_KEYMAP_LAYER_COUNT 4` line to reflect the correct number of layers; you can add it below `#pragma once`, but make sure it exists only once

### Knob As Mouse Wheel

To use the knob as a mouse wheel, modify the `encoder_map` in `keymaps/<keymap>/keymap.c` as follows (for the Mac base layer):

```c
[MAC_BASE] = {ENCODER_CCW_CW(KC_MS_WH_UP, KC_MS_WH_DOWN)},
```

This way, turning the knob counter-clockwise scrolls up and turning it clockwise scrolls down.
