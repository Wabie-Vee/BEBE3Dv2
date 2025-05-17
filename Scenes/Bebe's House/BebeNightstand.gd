extends Interactable

@onready var drawer_animator: AnimationPlayer = $DrawerAnimator
@onready var open_anim: String = "DrawerOpen"
@onready var close_anim: String = "DrawerClose"

var drawer_open := false
var anim_speed := 1.0

func interact():
	if drawer_animator.is_playing():
		# Reverse the animation
		drawer_animator.speed_scale *= -1
	else:
		if drawer_open:
			drawer_animator.play(close_anim)
			drawer_animator.speed_scale = 1.0
		else:
			drawer_animator.play(open_anim)
			drawer_animator.speed_scale = 1.0

	drawer_open = !drawer_open
