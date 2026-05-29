$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

function Read-Text($relativePath) {
	$path = Join-Path $repoRoot $relativePath
	if (-not (Test-Path -LiteralPath $path)) {
		throw "Missing expected file: $relativePath"
	}
	return Get-Content -Raw -LiteralPath $path
}

function Assert-Contains($text, $needle, $message) {
	if (-not $text.Contains($needle)) {
		throw $message
	}
}

function Assert-NotContains($text, $needle, $message) {
	if ($text.Contains($needle)) {
		throw $message
	}
}

$hitBoxScene = Read-Text "GeneralNodes/HitBox/hit_box.tscn"
$hurtBoxScene = Read-Text "GeneralNodes/HurtBox/hurt_box.tscn"

# HitBox is the active damaging area. By default it should detect player HurtBoxes
# and remain monitorable=false so other HitBoxes do not treat it as a target.
Assert-Contains $hitBoxScene "collision_layer = 0" "HitBox should not be on a target collision layer by default."
Assert-Contains $hitBoxScene "collision_mask = 2" "HitBox should detect the player HurtBox layer by default."
Assert-Contains $hitBoxScene "monitorable = false" "HitBox should not be detectable as a damage target."
Assert-NotContains $hitBoxScene "monitoring = false" "HitBox should monitor by default; attack nodes can disable it per scene."

# HurtBox is the passive damage receiver. Enemy and prop HurtBoxes inherit layer 256;
# the player HurtBox overrides this to layer 2 in Player/player.tscn.
Assert-Contains $hurtBoxScene "collision_layer = 256" "HurtBox should be on the enemy/prop target layer by default."
Assert-Contains $hurtBoxScene "collision_mask = 0" "HurtBox should not actively scan for areas."
Assert-Contains $hurtBoxScene "monitoring = false" "HurtBox should be passive by default."
Assert-NotContains $hurtBoxScene "monitorable = false" "HurtBox must be monitorable so HitBoxes can detect it."

Write-Host "HitBox/HurtBox scene defaults are consistent."
