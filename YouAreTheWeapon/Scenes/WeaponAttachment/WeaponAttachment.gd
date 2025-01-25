class_name Attachment extends Node2D

var linked_parent = null
var Position = Vector2(0,0)
var dragging: bool = false
var clicked: bool = false
var offset: Vector2 = Vector2(0,0)
var current_snap = null
var new_snap = null
var new_pos = null
@onready var old_pos = position

func _ready():
	pass

func _process(delta):
	if linked_parent:
		if dragging:
			# if dragging move attachement to mouse
			if clicked:
				linked_parent.position = get_global_mouse_position() - Vector2(Position.x * linked_parent.offset, Position.y * linked_parent.offset) - offset
		else:
			# if not dragging and has new snap point
			if new_snap and clicked:
				# try to snap
				if linked_parent.can_snap_to_sockets():
					linked_parent.try_snap(new_snap.position - Vector2(Position.x * linked_parent.offset, Position.y * linked_parent.offset) - offset)
				# if it cant rubber band back to original position and clear new_snap
				else:
					linked_parent.fail_snap(old_pos)
			pass
	else:
		if dragging:
			position = get_global_mouse_position() - offset
		elif new_pos and can_snap_to_socket():
			if current_snap:
				current_snap.is_socketed = false
			new_snap.is_socketed = true
			current_snap = new_snap
			new_snap = null
			position = new_pos
			old_pos = new_pos
			new_pos = null
		else:
			position = old_pos
		pass

func _on_click_detector_button_down():
	clicked = true
	dragging = true
	if linked_parent:
		linked_parent.begin_dragging(true);
	old_pos = position
	offset = get_global_mouse_position() - global_position
	pass

func _on_click_detector_button_up():
	dragging = false
	if linked_parent:
		linked_parent.begin_dragging(false)
	pass

func _on_area_2d_area_entered(area):
	if linked_parent:
		if linked_parent.dragging:
			new_snap = area.get_parent().get_parent()
	elif dragging:
		new_snap = area.get_parent().get_parent()
		if !(new_snap is Attachment):
			new_pos = new_snap.position
			new_pos += area.position * 2
	pass

func _on_area_2d_area_exited(area):
	new_snap = null


func can_snap_to_socket() -> bool:
	if new_snap and !(new_snap is Attachment):
		for socket in linked_parent.linked_attachment:
			if socket["Attachment"] == new_snap.socketed:
				return true
		return !(new_snap.is_socketed)
	else:
		return false
