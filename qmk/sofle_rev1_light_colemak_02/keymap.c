#include QMK_KEYBOARD_H

enum sofle_layers {
    _BASE,
    _SYMBOLS,
    _NAVIGATION,
    _APP_CONTROL,
    _MODS_NUM_PAD,
};

/*

0. BASE
 ␛ q w f p b          j l u y ; [
 ⌫ a r s t g          m n e i o ⏎
 ⇥ z x c d v          k h , . / '
        ➃ ➂ ⇧       ␣ ➀ ➁

1. SYMBOLS
 £ - = > ? \          ^ { } . + *
 ⌫ _ ; : , !          ' ( ) " | ␣
 § @ < $ ` ~          % [ ] / # &
        ␀ ␀ ␀        ␀ ␀ ␀

2. NAVIGATION
 ␀ ↞ ↡ ↟ ↠ ␀          ␀ ↥ ↧ ⇞ ⇟ ␀
 ␀ ⇠ ⇣ ⇡ ⇢ ␀          ␀ ⬅ ⬇ ⬆ ➡ ␀
 ␀ ⇺ ⇷ ⇸ ⇻ ␀          ␀ ⇱ ⇲ ⍉ ⏏ ␀
        ␀ ␀ ⇧        ␀ ␀ ␀

3. APP_CONTROL
 ⟲ ⅰ ⅱ ⅲ ⅳ ⤭          ␀ ␀ ␀ ␀ ␀ ␀
 ☓ ⤎  ⤏ ⤌  ⤍ ⤢          ␀ ␀ ␀ ␀ ␀ ␀
 ⟳ ⤎  ⤏   ↜  ↝    ↯          ␀ ␀ ␀ ␀ ␀ ␀
        ␀ ␀ ␀        ␀ ␀ ␀

4. MODS_NUM_PAD
 ␀ ␀ ␀ ␀ ␀ ␀          / 7 8 9 - ␀
 ␀ ⇧   ⌃   ⌥   ⌘ ⌁          * 4 5 6 + ␀
 ␀ ␀ ␀ ␀ ␀ ␀          = 1 2 3 ⇥ ␀
        ␀ ␀ ␀        ␣ 0 .

*/

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_BASE] = LAYOUT(
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        KC_ESC, KC_Q, KC_W, KC_F, KC_P, KC_B, KC_J, KC_L, KC_U, KC_Y, KC_SCLN, KC_LBRC,
        KC_BSPC, KC_A, KC_R, KC_S, KC_T, KC_G, KC_M, KC_N, KC_E, KC_I, KC_O, KC_ENT,
        KC_TAB, KC_Z, KC_X, KC_C, KC_D, KC_V, LGUI(LCTL(KC_Q)), KC_F10, KC_K, KC_H, KC_COMM, KC_DOT, KC_SLSH, KC_QUOT,
        KC_NO, KC_NO, MO(4), MO(3), KC_LSFT, KC_SPC, MO(1), MO(2), KC_NO, KC_NO
    ),
    [_SYMBOLS] = LAYOUT(
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        RSFT(KC_HASH), KC_MINS, KC_EQL, RSFT(KC_GT), RSFT(KC_QUES), KC_BSLS, RSFT(KC_CIRC), RSFT(KC_LCBR), RSFT(KC_RCBR), KC_DOT, RSFT(KC_PLUS), RSFT(KC_ASTR),
        KC_BSPC, RSFT(KC_UNDS), KC_SCLN, RSFT(KC_COLN), KC_COMM, RSFT(KC_EXLM), KC_QUOT, RSFT(KC_LPRN), RSFT(KC_RPRN), RSFT(KC_DQUO), RSFT(KC_PIPE), KC_ENT,
        KC_NUBS, RSFT(KC_AT), RSFT(KC_LT), RSFT(KC_DLR), KC_GRV, RSFT(KC_TILD), KC_NO, KC_NO, RSFT(KC_PERC), KC_LBRC, KC_RBRC, KC_SLSH, RALT(KC_3), RSFT(KC_AMPR),
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO
    ),
    [_NAVIGATION] = LAYOUT(
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        KC_NO, RGUI(KC_LEFT), RGUI(KC_DOWN), RGUI(KC_UP), RGUI(KC_RGHT), KC_NO, KC_NO, KC_F1, KC_F2, KC_F11, KC_F12, KC_NO,
        KC_NO, RALT(KC_LEFT), RALT(KC_DOWN), RALT(KC_UP), RALT(KC_RGHT), KC_NO, KC_NO, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, KC_NO,
        KC_NO, LGUI(KC_BSPC), LALT(KC_BSPC), LALT(KC_DEL), LCTL(KC_K), KC_NO, KC_NO, KC_NO, KC_NO, RGUI(KC_MINS), RGUI(KC_EQL), RGUI(KC_0), KC_F10, KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_LSFT, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO
    ),
    [_APP_CONTROL] = LAYOUT(
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        LGUI(KC_Z), HYPR(KC_1), HYPR(KC_2), HYPR(KC_3), HYPR(KC_4), LGUI(KC_ENT), KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        LCTL(KC_C), MEH(KC_GRV), MEH(KC_Z), LCAG(KC_X), LCAG(KC_C), LCAG(KC_SPC), KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        LGUI(LSFT(KC_Z)), HYPR(KC_GRV), HYPR(KC_Z), LCA(KC_X), LCA(KC_C), LAG(KC_TAB), KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, LGUI(KC_SPC), KC_NO, KC_NO, KC_NO, KC_NO, KC_NO
    ),
    [_MODS_NUM_PAD] = LAYOUT(
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_PSLS, KC_P7, KC_P8, KC_P9, KC_PMNS, KC_NO,
        KC_BSPC, OSM(MOD_LSFT), OSM(MOD_LCTL), OSM(MOD_LALT), OSM(MOD_LGUI), OSM(MOD_HYPR), KC_PAST, KC_P4, KC_P5, KC_P6, KC_PPLS, KC_NO,
        KC_NO,  KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_PEQL, KC_P1, KC_P2, KC_P3, KC_TAB, KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_SPACE, KC_P0, KC_PDOT, KC_NO, KC_NO
    )
};

#ifdef OLED_ENABLE

static const char PROGMEM doge_logo_1[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0x1c, 0x02, 0x05, 0x02, 0x24, 0x04, 0x04, 0x02, 0xa9, 0x1e, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
static const char PROGMEM doge_logo_2[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0x90, 0x08, 0x18, 0x60, 0x10, 0x08, 0x04, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x0e, 0x82, 0x7c, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
static const char PROGMEM doge_logo_3[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x04, 0x0c, 0x10, 0x10, 0x20, 0x20, 0x20, 0x28, 0x3e, 0x1c, 0x20, 0x20, 0x3e, 0x0f, 0x11, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static void print_doge_logo(void) {
    oled_set_cursor(0, 0);
    oled_write_raw_P(doge_logo_1, sizeof(doge_logo_1));
    oled_set_cursor(0, 1);
    oled_write_raw_P(doge_logo_2, sizeof(doge_logo_2));
    oled_set_cursor(0, 2);
    oled_write_raw_P(doge_logo_3, sizeof(doge_logo_3));
}

static void print_layer_name(void) {
    oled_set_cursor(6, 1);

    switch (get_highest_layer(layer_state)) {
        case _BASE:
            oled_write_P(PSTR("Base Layer"), false);
            break;
        case _SYMBOLS:
            oled_write_P(PSTR("Symbols"), false);
            break;
        case _NAVIGATION:
            oled_write_P(PSTR("Navigation"), false);
            break;
        case _APP_CONTROL:
            oled_write_P(PSTR("App Control"), false);
            break;
        case _MODS_NUM_PAD:
            oled_write_P(PSTR("Mods & Num Pad"), false);
            break;
        default:
            oled_write_P(PSTR("Unknown"), false);
            break;
    }
}

static void print_wpm(void) {
    uint8_t wpm = get_current_wpm();

    oled_write_P(PSTR("  "), false);
    oled_write_ln(get_u8_str(wpm, '0'), false);
    oled_write_P(PSTR("  "), false);
    oled_write_P(PSTR("WPM"), false);
}

static void print_mod_status(const char * label, bool on) {
    oled_write_P(PSTR("\n"), false);
    oled_write_P(PSTR("  "), false);
    oled_write_P(label, on);
}

static void print_mods(void) {
    uint8_t mods = get_mods();
    uint8_t oneshot_mods = get_oneshot_mods();

    oled_write_ln_P(PSTR("\n"), false);

    print_mod_status(PSTR("Sft"), mods & MOD_MASK_SHIFT || oneshot_mods & MOD_MASK_SHIFT);
    print_mod_status(PSTR("Ctl"), mods & MOD_MASK_CTRL || oneshot_mods & MOD_MASK_CTRL);
    print_mod_status(PSTR("Alt"), mods & MOD_MASK_ALT || oneshot_mods & MOD_MASK_ALT);
    print_mod_status(PSTR("Cmd"), mods & MOD_MASK_GUI || oneshot_mods & MOD_MASK_GUI);

    print_mod_status(PSTR(""), false);
    print_mod_status(PSTR(""), false);
}

static void print_divider(void) {
    for (uint8_t i = 10; i <= 32; ++i) {
        oled_write_pixel(i, 34, true);
    }
}

static void print_primary_oled(void) {
    oled_clear();
    print_wpm();
    print_mods();
    print_divider();
}

static void print_secondary_oled(void) {
    oled_clear();
    print_doge_logo();
    print_layer_name();
}

oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    if (is_keyboard_master()) {
        return OLED_ROTATION_270;
    }
    return OLED_ROTATION_180;
}

bool oled_task_user(void) {
    if (is_keyboard_master()) {
        print_primary_oled();
    } else {
        print_secondary_oled();
    }
    return false;
}

#endif

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (keycode == KC_ESC && record->event.pressed) {
        uint8_t oneshot_mods = get_oneshot_mods();

        if (oneshot_mods && !has_oneshot_mods_timed_out()) {
            clear_oneshot_mods();
            unregister_mods(oneshot_mods);
            return false;
        }

        uint8_t oneshot_locked_mods = get_oneshot_locked_mods();

        if (oneshot_locked_mods) {
            clear_oneshot_locked_mods();
            unregister_mods(oneshot_locked_mods);
            return false;
        }
    }

    return true;
}

#ifdef ENCODER_ENABLE

bool encoder_update_user(uint8_t index, bool clockwise) {
    if (index == 0) {
        if (clockwise) {
            tap_code(KC_F2);
        } else {
            tap_code(KC_F1);
        }

        return false;
    } 
    
    if (index == 1) {
        if (clockwise) {
            tap_code(KC_VOLU);
        } else {
            tap_code(KC_VOLD);
        }

        return false;
    }

    return true;
}

#endif
