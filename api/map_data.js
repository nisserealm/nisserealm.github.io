export const MAP_ROWS = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0],
  [0, 0, 0, 1, 13, 3, 3, 2, 2, 2, 11, 3, 3, 3, 1, 1, 0, 0],
  [0, 1, 1, 1, 3, 3, 3, 12, 3, 10, 3, 3, 7, 3, 2, 1, 1, 0],
  [0, 1, 11, 3, 3, 5, 5, 10, 3, 10, 15, 3, 3, 3, 10, 4, 1, 0],
  [0, 8, 5, 3, 15, 12, 10, 7, 10, 10, 3, 3, 3, 5, 5, 1, 1, 0],
  [0, 1, 3, 3, 3, 4, 10, 3, 10, 4, 11, 2, 2, 5, 14, 1, 0, 0],
  [0, 1, 1, 3, 11, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0],
  [0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
];

export function terrainName(code) {
  switch (code) {
    case 0: return "ocean";
    case 1: return "coastal";
    case 2: return "moor";
    case 3: return "forest";
    case 4: return "hills";
    case 5: return "farm";
    case 6: return "village";
    case 7: return "monastery";
    case 8: return "harbor";
    case 9: return "city";
    case 10: return "mountain";
    case 11: return "fishing_village";
    case 12: return "mountain_village";
    case 13: return "city_north";
    case 14: return "city_south";
    case 15: return "meadow";
    default: return "unknown";
  }
}

function themeForTerrain(code) {
  if (code === 11 || code === 12) {
    return "village";
  }
  if (code === 13 || code === 14) {
    return "city";
  }
  return terrainName(code);
}

export function fallbackImageForTerrain(code) {
  const theme = themeForTerrain(code);
  return `./stories/fallback/images/themes/${theme === "farm" ? "farmland" : theme}.svg`;
}

export function canNameTile(code) {
  return [1, 2, 3, 4, 10, 15].includes(code);
}

export function movementCost(code) {
  if (code === 3) return 2;
  if (code === 4) return 2;
  if (code === 10) return 3;
  return 1;
}
