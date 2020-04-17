extends HBoxContainer

var username := "creikey" setget set_username
var score := 0 setget set_score

func set_username(new_username):
	username = new_username
	if has_node("UsernameLabel"):
		$UsernameLabel.text = username

func set_score(new_score):
	score = new_score
	if has_node("ScoreLabel"):
		$ScoreLabel.text = str(score)
