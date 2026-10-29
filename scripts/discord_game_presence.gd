extends Node

## Discord uses this application to display the game's name and icon.
## The connection stays local to the Discord desktop client and is optional.
const APPLICATION_ID := "1565098232395337850"
const DISCORD_RPC := preload("res://addons/discord_rich_presence/discord_rich_presence.gd")

var _presence: Node


func _ready() -> void:
	if APPLICATION_ID.is_empty():
		return
	_presence = DISCORD_RPC.new()
	_presence.app_id = APPLICATION_ID
	if OS.is_debug_build():
		_presence.presence_connected.connect(func(_user: Dictionary) -> void:
			print("Discord Rich Presence connected"))
	add_child(_presence)
	_presence.set_activity({
		"details": "Leading a young republic",
		"state": "A political strategy game",
		"assets": {
			"large_image": "republic_icon",
			"large_text": "Heir to the Republic",
		},
		"timestamps": {"start": int(Time.get_unix_time_from_system())},
	})
