/// Picks a tilt step that is stable for a given item id (FNV-1a hash).
///
/// Unlike [String.hashCode], the result is identical across runs/platforms.
int stableTiltDegrees(String id, List<int> steps) {
  var hash = 0x811c9dc5;
  for (final unit in id.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return steps[hash % steps.length];
}
