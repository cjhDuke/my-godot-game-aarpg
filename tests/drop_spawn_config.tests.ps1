$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$enemyDestroyPath = Join-Path $repoRoot "Enemies/Scripts/states/enemy_state_destroy.gd"

if (-not (Test-Path -LiteralPath $enemyDestroyPath)) {
	throw "Missing expected file: Enemies/Scripts/states/enemy_state_destroy.gd"
}

$enemyDestroy = Get-Content -Raw -LiteralPath $enemyDestroyPath

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

Assert-Contains $enemyDestroy "const WALL_COLLISION_MASK" "Drop spawning should query against the Walls collision layer."
Assert-Contains $enemyDestroy "func _get_drop_spawn_position" "Enemy drops should resolve a clear spawn position before being added."
Assert-Contains $enemyDestroy "PhysicsShapeQueryParameters2D.new()" "Drop spawn resolution should use a shape query matching the pickup body."
Assert-Contains $enemyDestroy "intersect_shape" "Drop spawn resolution should test candidate positions for wall overlap."
Assert-Contains $enemyDestroy "var spawn_position := _get_drop_spawn_position(drop, enemy.global_position)" "Drops should compute a safe spawn position from the enemy position."
Assert-Contains $enemyDestroy "drop.set_spawn_position(spawn_position)" "The pickup scatter center should use the resolved safe spawn position."
Assert-NotContains $enemyDestroy "drop.set_spawn_position(enemy.global_position)" "The enemy position should not be used directly as the pickup scatter center."

Write-Host "Enemy drop spawn uses a wall-safe position."
