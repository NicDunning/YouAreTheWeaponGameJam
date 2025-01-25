extends Node2D

@export var shape: Array[String] = []
@export var offset = 128

var weapon_attachment = preload("res://Scenes/WeaponAttachment/WeaponAttachment.tscn")
var linked_attachment: Array[Dictionary] = []
var dragging = false

@onready var old_pos = position

func _ready():
	create_shape()
	pass

func _process(delta):
	pass

func create_shape():
	var x = 0
	var y = 0
	for char in shape:
		match char.to_upper():
			"X":
				var weapon_attachment_instance = weapon_attachment.instantiate()
				weapon_attachment_instance.position = Vector2(offset * x, offset * y)
				weapon_attachment_instance.linked_parent = self
				weapon_attachment_instance.Position = Vector2(x,y)
				$Sprite2D.add_child(weapon_attachment_instance)
				linked_attachment.append({"Attachment":weapon_attachment_instance, "Position":Vector2(x,y)})
				x += 1
				pass
			"|":
				x = 0
				y += 1
				pass
			_:
				x += 1
				pass
	pass

func begin_dragging(drag):
	dragging = drag
	for socket in linked_attachment:
		socket["Attachment"].dragging = drag

func can_snap_to_sockets() -> bool:
	for attachment in linked_attachment:
		if !(attachment["Attachment"].can_snap_to_socket()):
			return false
	return true

func try_snap(new_pos):
	socket_attachments()
	pass

func fail_snap(rubber_band_pos):
	for socket in linked_attachment:
		socket["Attachment"].new_snap = null
		socket["Attachment"].clicked = false
	position = old_pos
	pass

func socket_attachments():
	for socket in linked_attachment:
		if socket["Attachment"].current_snap:
			socket["Attachment"].current_snap.is_socketed = false
			socket["Attachment"].current_snap.socketed = null
		socket["Attachment"].new_snap.is_socketed = true
		socket["Attachment"].current_snap = socket["Attachment"].new_snap
		socket["Attachment"].current_snap.socketed = socket["Attachment"]
		if socket["Position"] == Vector2(0,0):
			position = socket["Attachment"].new_snap.position
			old_pos = position
		socket["Attachment"].new_snap = null
		socket["Attachment"].old_pos = socket["Attachment"].new_pos
		socket["Attachment"].new_pos = null
		socket["Attachment"].clicked = false
	pass
