extends Resource
class_name MatchSettings

export(String) var name: String = ""
export(Vector2) var wave_strength: Vector2 = Vector2.ZERO
export(float) var friction_multiplier: float = 1.0
export(float) var bounce_multiplier: float = 1.0
export(float) var punt_multiplier: float = 1.0
export(float) var strike_multiplier: float = 1.0
export(bool) var slow_mo_on_strike: bool = false
export(float) var slow_mo_speed: float = 0.7
export(float) var match_length: float = 60.0 * 3 # seconds (-1 for no limit)
export(int) var goals_to_win: int = -1 # (-1 for no limit)
export(int) var goals_to_lose: int = -1 # (-1 for no limit)
export(int) var team_count: int = 2
export(int) var players_per_team: int = 1
