#pragma once

#define EE_HANDS

/* The way how "handedness" is decided (which half is which),
see https://docs.qmk.fm/#/feature_split_keyboard?id=setting-handedness
for more options.
*/

#undef TAPPING_TERM
#define TAPPING_TERM 200
#define RETRO_TAPPING

#undef ENCODER_RESOLUTION
#define ENCODER_RESOLUTION 4
#define ENCODER_DEFAULT_POS 0x3
#define ENCODER_DIRECTION_FLIP

#define WPM_LAUNCH_CONTROL

#define SPLIT_WPM_ENABLE
#define SPLIT_MODS_ENABLE
#define SPLIT_LAYER_STATE_ENABLE
