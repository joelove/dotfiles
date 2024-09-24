#
# Source from .zshenv
#

size_to_display() {
  yabai -m window --grid 1:1:0:0:1:1
}

size_to_left_half() {
  yabai -m window --grid 1:2:0:0:1:1
}

size_to_right_half() {
  yabai -m window --grid 1:2:1:0:1:1
}

size_to_center_half() {
  yabai -m window --grid 1:5:1:0:3:1
}

size_to_left_third() {
  yabai -m window --grid 1:3:0:0:1:1
}

size_to_right_third() {
  yabai -m window --grid 1:3:2:0:1:1
}

size_to_left_two_thirds() {
  yabai -m window --grid 1:3:0:0:2:1
}

size_to_right_two_thirds() {
  yabai -m window --grid 1:3:1:0:2:1
}

size_to_middle() {
   yabai -m window --grid 3:3:1:1:1:1
}

move_to_previous_display() {
  yabai -m window --display prev
}

move_to_next_display() {
  yabai -m window --display next
}

focus_previous_display() {
  yabai -m display --focus prev
}

focus_next_display() {
  yabai -m display --focus next
}

focus_display_with_mouse() {
  yabai -m display --focus mouse
}

get_primary_space_index_on_focused_display() {
  yabai -m query --displays --display | jq -er '.spaces[0]'
}

get_primary_space_index_on_previous_display() {
  yabai -m query --displays --display prev | jq -er '.spaces[0]'
}

get_primary_space_index_on_next_display() {
  yabai -m query --displays --display next | jq -er '.spaces[0]'
}

get_background_space_index_on_focused_display() {
  yabai -m query --displays --display | jq -er '.spaces[1]'
}

get_background_space_index_on_previous_display() {
  yabai -m query --displays --display prev | jq -er '.spaces[1]'
}

get_background_space_index_on_next_display() {
  yabai -m query --displays --display next | jq -er '.spaces[1]'
}

activate_primary_space_on_focused_display() {
  yabai -m space --focus "$(get_primary_space_index_on_focused_display)"
}

activate_primary_space_on_previous_display() {
  yabai -m space --focus "$(get_primary_space_index_on_previous_display)"
}

activate_primary_space_on_next_display() {
  yabai -m space --focus "$(get_primary_space_index_on_next_display)"
}

activate_background_space_on_focused_display() {
  yabai -m space --focus "$(get_background_space_index_on_focused_display)"
}

activate_background_space_on_previous_display() {
  yabai -m space --focus "$(get_background_space_index_on_previous_display)"
}

activate_background_space_on_next_display() {
  yabai -m space --focus "$(get_background_space_index_on_next_display)"
}

swap_active_space_on_focused_display() {
  activate_primary_space_on_focused_display || activate_background_space_on_focused_display
}
