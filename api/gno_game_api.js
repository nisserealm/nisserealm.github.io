import {
  MAP_ROWS,
  terrainName,
  fallbackImageForTerrain,
  canNameTile,
  movementCost
} from "./map_data.js";

const LOCAL_PKG_PATH = "gno.land/r/g1sqlsr3e2efk349w0753j7jhqrpz5x0uqmps6lf/nisse";
const HOSTED_PKG_PATH = "gno.land/r/g1sqlsr3e2efk349w0753j7jhqrpz5x0uqmps6lf/nisse01";
const PLAYER_NAME_STORAGE_KEY = "nisse.playerName";
const KEY_NAME_STORAGE_KEY = "nisse.keyName";
const ATTITUDE_STORAGE_KEY = "nisse.attitude";
const PROXY_URL_STORAGE_KEY = "nisse.proxyUrl";
const DEFAULT_GAS_FEE = "8000000ugnot";
const DEFAULT_GAS_WANTED = "120000000";
const SPECIAL_TILE_STORIES = {
  "15,4": {
    id: "reindeer",
    title: "Reindeer",
    theme: "hills",
    path: "../stories/reindeer/story.json"
  }
};

function appUrl(path) {
  return new URL(String(path || "./"), import.meta.url).href;
}

function inferPkgPath() {
  if (typeof window === "undefined") {
    return HOSTED_PKG_PATH;
  }
  const host = String(window.location?.hostname || "").toLowerCase();
  if (!host || host === "localhost" || host === "127.0.0.1" || host === "::1") {
    return LOCAL_PKG_PATH;
  }
  return HOSTED_PKG_PATH;
}

const PKG_PATH = inferPkgPath();

function defaultProxyUrl() {
  return new URL("../proxy", window.location.href).href;
}

function cleanInput(value) {
  return String(value || "").trim();
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function normalizeRealmText(value) {
  const raw = String(value ?? "");
  const trimmed = raw.trim();

  const tupleWrapped = trimmed.match(/^\("([\s\S]*)"\s+string\)$/);
  if (tupleWrapped) {
    return tupleWrapped[1]
      .replace(/\\n/g, "\n")
      .replace(/\\"/g, '"')
      .replace(/\\\\/g, "\\");
  }

  if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
    try {
      return JSON.parse(trimmed);
    } catch (err) {
      // Fall through to lighter cleanup below.
    }
  }

  return raw
    .replace(/^"/, "")
    .replace(/"\s*string\)?\s*$/, "")
    .replace(/\\n/g, "\n")
    .replace(/\\"/g, '"');
}

function decodeProxyResult(json) {
  const response = json?.result?.response?.ResponseBase;

  if (!response) {
    return JSON.stringify(json, null, 2);
  }

  if (response.Error) {
    throw new Error(response.Error);
  }

  if (response.Data) {
    return atob(response.Data);
  }

  if (response.Log) {
    return response.Log;
  }

  return JSON.stringify(json, null, 2);
}

async function runQeval(expr) {
  const trimmed = cleanInput(expr);
  if (!trimmed) {
    throw new Error("Missing qeval expression.");
  }

  const response = await fetch(proxyUrlFromStorage(), {
    method: "POST",
    headers: { "Content-Type": "text/plain" },
    body: trimmed
  });

  if (!response.ok) {
    throw new Error("Proxy returned " + response.status);
  }

  const json = await response.json();
  return decodeProxyResult(json);
}

function playerNameFromStorage() {
  try {
    return cleanInput(localStorage.getItem(PLAYER_NAME_STORAGE_KEY) || "") || "Nisse";
  } catch (err) {
    return "Nisse";
  }
}

function keyNameFromStorage() {
  try {
    return cleanInput(localStorage.getItem(KEY_NAME_STORAGE_KEY) || "") || "mykey";
  } catch (err) {
    return "mykey";
  }
}

function proxyUrlFromStorage() {
  try {
    const queryValue = new URLSearchParams(window.location.search).get("proxy");
    const chosen = cleanInput(queryValue || localStorage.getItem(PROXY_URL_STORAGE_KEY) || "");
    return chosen || defaultProxyUrl();
  } catch (err) {
    return defaultProxyUrl();
  }
}

function persistProxyUrl(value) {
  const nextProxyUrl = cleanInput(value);
  try {
    if (nextProxyUrl) {
      localStorage.setItem(PROXY_URL_STORAGE_KEY, nextProxyUrl);
    } else {
      localStorage.removeItem(PROXY_URL_STORAGE_KEY);
    }
  } catch (err) {
    // Ignore storage failures.
  }
  return nextProxyUrl || defaultProxyUrl();
}

function normalizeAttitude(value) {
  const normalized = cleanInput(value).toLowerCase();
  if (normalized === "kind" || normalized === "bold") {
    return normalized;
  }
  return "cautious";
}

function attitudeFromStorage() {
  try {
    return normalizeAttitude(localStorage.getItem(ATTITUDE_STORAGE_KEY) || "cautious");
  } catch (err) {
    return "cautious";
  }
}

function persistAttitude(attitude) {
  const nextAttitude = normalizeAttitude(attitude);
  try {
    localStorage.setItem(ATTITUDE_STORAGE_KEY, nextAttitude);
  } catch (err) {
    // Ignore storage failures.
  }
  return nextAttitude;
}

function persistIdentity(playerName, keyName) {
  const nextPlayerName = cleanInput(playerName) || "Nisse";
  const nextKeyName = cleanInput(keyName) || "mykey";
  try {
    localStorage.setItem(PLAYER_NAME_STORAGE_KEY, nextPlayerName);
    localStorage.setItem(KEY_NAME_STORAGE_KEY, nextKeyName);
  } catch (err) {
    // Ignore storage failures and keep the in-memory flow working.
  }
  return {
    playerName: nextPlayerName,
    keyName: nextKeyName
  };
}

function shellQuote(value) {
  return "'" + String(value).replace(/'/g, "'\\''") + "'";
}

function buildTravelPlayerCommand(playerName, x, y, attitude = attitudeFromStorage()) {
  return [
    "gnokey maketx call",
    keyNameFromStorage(),
    "--broadcast",
    "--chainid dev",
    "--gas-fee", shellQuote(DEFAULT_GAS_FEE),
    "--gas-wanted", shellQuote(DEFAULT_GAS_WANTED),
    "--pkgpath", shellQuote(PKG_PATH),
    "--func", shellQuote("TravelPlayer"),
    "--args", shellQuote(cleanInput(playerName).toLowerCase() || "nisse"),
    "--args", shellQuote(String(x)),
    "--args", shellQuote(String(y)),
    "--args", shellQuote(normalizeAttitude(attitude))
  ].join(" ");
}

function buildNameTileCommand(playerName, placeName) {
  return [
    "gnokey maketx call",
    keyNameFromStorage(),
    "--broadcast",
    "--chainid dev",
    "--gas-fee", shellQuote(DEFAULT_GAS_FEE),
    "--gas-wanted", shellQuote(DEFAULT_GAS_WANTED),
    "--pkgpath", shellQuote(PKG_PATH),
    "--func", shellQuote("NameTile"),
    "--args", shellQuote(cleanInput(playerName).toLowerCase() || "nisse"),
    "--args", shellQuote(cleanInput(placeName) || "Unnamed Place")
  ].join(" ");
}

function buildMintPlayerCommand(playerName, keyName) {
  return [
    "gnokey maketx call",
    cleanInput(keyName) || "mykey",
    "--broadcast",
    "--chainid dev",
    "--gas-fee", shellQuote(DEFAULT_GAS_FEE),
    "--gas-wanted", shellQuote(DEFAULT_GAS_WANTED),
    "--pkgpath", shellQuote(PKG_PATH),
    "--func", shellQuote("MintPlayer"),
    "--args", shellQuote(cleanInput(playerName) || "Nisse")
  ].join(" ");
}

function buildMintEarnedCompanionCommand(playerName, keyName, claimID, displayName = "") {
  return [
    "gnokey maketx call",
    cleanInput(keyName) || "mykey",
    "--broadcast",
    "--chainid dev",
    "--gas-fee", shellQuote(DEFAULT_GAS_FEE),
    "--gas-wanted", shellQuote(DEFAULT_GAS_WANTED),
    "--pkgpath", shellQuote(PKG_PATH),
    "--func", shellQuote("MintEarnedCompanion"),
    "--args", shellQuote(cleanInput(playerName) || "Nisse"),
    "--args", shellQuote(cleanInput(claimID)),
    "--args", shellQuote(cleanInput(displayName))
  ].join(" ");
}

function buildBuyBoatCommand(playerName, keyName) {
  return [
    "gnokey maketx call",
    cleanInput(keyName) || "mykey",
    "--broadcast",
    "--chainid dev",
    "--gas-fee", shellQuote(DEFAULT_GAS_FEE),
    "--gas-wanted", shellQuote(DEFAULT_GAS_WANTED),
    "--pkgpath", shellQuote(PKG_PATH),
    "--func", shellQuote("BuyBoat"),
    "--args", shellQuote(cleanInput(playerName).toLowerCase() || "nisse")
  ].join(" ");
}

function buildSetPlayerAppearanceCommand(playerName, keyName, appearance16) {
  return [
    "gnokey maketx call",
    cleanInput(keyName) || "mykey",
    "--broadcast",
    "--chainid dev",
    "--gas-fee", shellQuote(DEFAULT_GAS_FEE),
    "--gas-wanted", shellQuote(DEFAULT_GAS_WANTED),
    "--pkgpath", shellQuote(PKG_PATH),
    "--func", shellQuote("SetPlayerAppearance"),
    "--args", shellQuote(cleanInput(playerName).toLowerCase() || "nisse"),
    "--args", shellQuote(cleanInput(appearance16).toLowerCase() || "none")
  ].join(" ");
}

function buildWriteToFriendCommand(playerName, keyName, toPlayerName, body) {
  return [
    "gnokey maketx call",
    cleanInput(keyName) || "mykey",
    "--broadcast",
    "--chainid dev",
    "--gas-fee", shellQuote(DEFAULT_GAS_FEE),
    "--gas-wanted", shellQuote(DEFAULT_GAS_WANTED),
    "--pkgpath", shellQuote(PKG_PATH),
    "--func", shellQuote("WriteToFriend"),
    "--args", shellQuote(cleanInput(playerName).toLowerCase() || "nisse"),
    "--args", shellQuote(cleanInput(toPlayerName).toLowerCase()),
    "--args", shellQuote(cleanInput(body))
  ].join(" ");
}

function parsePlayer(text) {
  const normalized = normalizeRealmText(text);
  const nameMatch = normalized.match(/^\s*Player:\s*(.+)$/m);
  const pearlsMatch = normalized.match(/^\s*Pearls:\s*(\d+)/m);
  const levelMatch = normalized.match(/^\s*Level:\s*(\d+)$/m);
  const boldnessMatch = normalized.match(/^\s*Boldness:\s*(\d+)$/m);
  const cautionMatch = normalized.match(/^\s*Caution:\s*(\d+)$/m);
  const kindnessMatch = normalized.match(/^\s*Kindness:\s*(\d+)$/m);
  const soulMatch = normalized.match(/^\s*Soul:\s*(\d+)$/m);
  const turnsMatch = normalized.match(/^\s*Turns:\s*(\d+)$/m);
  const companionsMatch = normalized.match(/^\s*Companions:\s*(\d+)$/m);
  const travelBonusMatch = normalized.match(/^\s*TravelBonus:\s*\+?(\d+)$/m);
  const boatMatch = normalized.match(/^\s*Boat:\s*(.+)$/m);
  const boatLeftMatch = normalized.match(/^\s*Boat:\s*.+ left at \((\d+),\s*(\d+)\)\s*$/m);
  const appearanceMatch = normalized.match(/^\s*Appearance16:\s*(.+)$/m);
  const positionMatch = normalized.match(/^\s*Position:\s*\((\d+),\s*(\d+)\)$/m);

  if (!positionMatch) {
    throw new Error("Could not parse player position.");
  }

  return {
    name: cleanInput(nameMatch ? nameMatch[1] : "") || playerNameFromStorage(),
    position: {
      x: Number(positionMatch[1]),
      y: Number(positionMatch[2])
    },
    pearls: Number(pearlsMatch ? pearlsMatch[1] : 0),
    level: Number(levelMatch ? levelMatch[1] : 0),
    boldness: Number(boldnessMatch ? boldnessMatch[1] : 0),
    caution: Number(cautionMatch ? cautionMatch[1] : 0),
    kindness: Number(kindnessMatch ? kindnessMatch[1] : 0),
    soul: Number(soulMatch ? soulMatch[1] : 0),
    turns: Number(turnsMatch ? turnsMatch[1] : 0),
    companions: Number(companionsMatch ? companionsMatch[1] : 0),
    travelBonus: Number(travelBonusMatch ? travelBonusMatch[1] : 0),
    boatStatus: cleanInput(boatMatch ? boatMatch[1] : ""),
    ownsBoat: cleanInput(boatMatch ? boatMatch[1] : "").toLowerCase() !== "none",
    carriesBoat: cleanInput(boatMatch ? boatMatch[1] : "").toLowerCase().includes("(carried)"),
    hasBoat: cleanInput(boatMatch ? boatMatch[1] : "").toLowerCase().includes("(carried)"),
    boatLeftPosition: boatLeftMatch
      ? { x: Number(boatLeftMatch[1]), y: Number(boatLeftMatch[2]) }
      : null,
    appearance16: (() => {
      const value = cleanInput(appearanceMatch ? appearanceMatch[1] : "");
      return value.toLowerCase() === "none" ? "" : value.toLowerCase();
    })()
  };
}

function parsePlayerCoreData(text) {
  const normalized = normalizeRealmText(text);
  const nameMatch = normalized.match(/^\s*Name:\s*(.+)$/m);
  const appearanceMatch = normalized.match(/^\s*Appearance16:\s*(.+)$/m);
  return {
    name: cleanInput(nameMatch ? nameMatch[1] : "") || playerNameFromStorage(),
    appearance16: (() => {
      const value = cleanInput(appearanceMatch ? appearanceMatch[1] : "");
      return value.toLowerCase() === "none" ? "" : value.toLowerCase();
    })()
  };
}

function parsePlayerStatsData(text) {
  const normalized = normalizeRealmText(text);
  const levelMatch = normalized.match(/^\s*Level:\s*(\d+)$/m);
  const boldnessMatch = normalized.match(/^\s*Boldness:\s*(\d+)$/m);
  const cautionMatch = normalized.match(/^\s*Caution:\s*(\d+)$/m);
  const kindnessMatch = normalized.match(/^\s*Kindness:\s*(\d+)$/m);
  const soulMatch = normalized.match(/^\s*Soul:\s*(\d+)$/m);
  return {
    level: Number(levelMatch ? levelMatch[1] : 0),
    boldness: Number(boldnessMatch ? boldnessMatch[1] : 0),
    caution: Number(cautionMatch ? cautionMatch[1] : 0),
    kindness: Number(kindnessMatch ? kindnessMatch[1] : 0),
    soul: Number(soulMatch ? soulMatch[1] : 0)
  };
}

function parsePlayerTravelData(text) {
  const normalized = normalizeRealmText(text);
  const positionMatch = normalized.match(/^\s*Position:\s*\((\d+),\s*(\d+)\)$/m);
  const turnsMatch = normalized.match(/^\s*Turns:\s*(\d+)$/m);
  const monthIndexMatch = normalized.match(/^\s*MonthIndex:\s*(\d+)$/m);
  const seasonMatch = normalized.match(/^\s*Season:\s*(.+)$/m);
  const seasonMonthMatch = normalized.match(/^\s*SeasonMonth:\s*(\d+)$/m);
  const travelBonusMatch = normalized.match(/^\s*TravelBonus:\s*\+?(\d+)$/m);
  const boatMatch = normalized.match(/^\s*Boat:\s*(.+)$/m);
  const boatLeftMatch = normalized.match(/^\s*Boat:\s*.+ left at \((\d+),\s*(\d+)\)\s*$/m);

  if (!positionMatch) {
    throw new Error("Could not parse player position.");
  }

  const boatStatus = cleanInput(boatMatch ? boatMatch[1] : "");
  const position = {
    x: Number(positionMatch[1]),
    y: Number(positionMatch[2])
  };
  const boatLeftPosition = boatLeftMatch
    ? { x: Number(boatLeftMatch[1]), y: Number(boatLeftMatch[2]) }
    : null;
  const boatAtPlayerTile = !!boatLeftPosition
    && boatLeftPosition.x === position.x
    && boatLeftPosition.y === position.y;
  return {
    position,
    turns: Number(turnsMatch ? turnsMatch[1] : 0),
    monthIndex: Number(monthIndexMatch ? monthIndexMatch[1] : 0),
    season: cleanInput(seasonMatch ? seasonMatch[1] : "").toLowerCase(),
    seasonMonth: Number(seasonMonthMatch ? seasonMonthMatch[1] : 0),
    travelBonus: Number(travelBonusMatch ? travelBonusMatch[1] : 0),
    boatStatus,
    ownsBoat: boatStatus.toLowerCase() !== "none",
    carriesBoat: boatStatus.toLowerCase().includes("(carried)") || boatAtPlayerTile,
    hasBoat: boatStatus.toLowerCase().includes("(carried)") || boatAtPlayerTile,
    boatLeftPosition
  };
}

function parsePlayerWealthData(text) {
  const normalized = normalizeRealmText(text);
  const pearlsMatch = normalized.match(/^\s*Pearls:\s*(\d+)$/m);
  const ugnotMatch = normalized.match(/^\s*UGNOT:\s*(-?\d+)$/m);
  return {
    pearls: Number(pearlsMatch ? pearlsMatch[1] : 0),
    ugnot: Number(ugnotMatch ? ugnotMatch[1] : 0)
  };
}

async function loadPlayerData(playerName) {
  const [coreText, statsText, travelText, wealthText, companionText] = await Promise.all([
    runQeval(`${PKG_PATH}.GetPlayerCoreData(${JSON.stringify(playerName)})`),
    runQeval(`${PKG_PATH}.GetPlayerStatsData(${JSON.stringify(playerName)})`),
    runQeval(`${PKG_PATH}.GetPlayerTravelData(${JSON.stringify(playerName)})`),
    runQeval(`${PKG_PATH}.GetPlayerWealthData(${JSON.stringify(playerName)})`),
    (async () => {
      try {
        return await runQeval(`${PKG_PATH}.DescribeCompanion(${JSON.stringify(playerName)})`);
      } catch (err) {
        return "No companions.";
      }
    })()
  ]);

  const core = parsePlayerCoreData(coreText);
  const stats = parsePlayerStatsData(statsText);
  const travel = parsePlayerTravelData(travelText);
  const wealth = parsePlayerWealthData(wealthText);
  const companionList = parseCompanionSummary(companionText);

  return {
    player: {
      name: core.name,
      position: travel.position,
      pearls: wealth.pearls,
      ugnot: wealth.ugnot,
      level: stats.level,
      boldness: stats.boldness,
      caution: stats.caution,
      kindness: stats.kindness,
      soul: stats.soul,
      turns: travel.turns,
      companions: companionList.length,
      travelBonus: travel.travelBonus,
      boatStatus: travel.boatStatus,
      ownsBoat: travel.ownsBoat,
      carriesBoat: travel.carriesBoat,
      hasBoat: travel.hasBoat,
      boatLeftPosition: travel.boatLeftPosition,
      appearance16: core.appearance16
    },
    companionList
  };
}

function parsePlayerPositions(text) {
  const normalized = normalizeRealmText(text);
  if (!normalized || /^No players\./i.test(normalized)) {
    return [];
  }
  return normalized
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.startsWith("- "))
    .map((line) => {
      const match = line.match(/^- (.+) @ \((\d+),\s*(\d+)\)$/);
      if (!match) {
        return null;
      }
      return {
        name: cleanInput(match[1]),
        position: {
          x: Number(match[2]),
          y: Number(match[3])
        }
      };
    })
    .filter(Boolean);
}

function parseCompanionSummary(text) {
  const normalized = normalizeRealmText(text);
  if (!normalized || /^No companions\./i.test(normalized)) {
    return [];
  }
  const lines = normalized.split("\n");
  const companions = [];
  let current = null;
  for (const rawLine of lines) {
    const line = rawLine.trim();
    const header = line.match(/^- #(\d+)\s+(.+?)(\s+\[active\])?$/);
    if (header) {
      current = {
        id: Number(header[1]),
        species: cleanInput(header[2]),
        active: !!header[3],
        name: "",
        assetCode: ""
      };
      companions.push(current);
      continue;
    }
    if (!current) {
      continue;
    }
    const assetMatch = line.match(/^Asset:\s*(.+)$/);
    if (assetMatch) {
      current.assetCode = cleanInput(assetMatch[1]);
      continue;
    }
    const nameMatch = line.match(/^Name:\s*(.+)$/);
    if (nameMatch) {
      current.name = cleanInput(nameMatch[1]);
    }
  }
  return companions;
}

function parseFriendQuery(input) {
  const raw = String(input || "").trim();
  if (!raw) {
    return [];
  }
  const words = raw
    .split(/[\s,]+/)
    .map((part) => cleanInput(part))
    .filter(Boolean);
  const seen = new Set();
  const out = [];
  for (const name of words) {
    const key = name.toLowerCase();
    if (seen.has(key)) {
      continue;
    }
    seen.add(key);
    out.push(name);
  }
  return out;
}

function parseDiaryEntry(text) {
  const normalized = normalizeRealmText(text);
  const idMatch = normalized.match(/^\s*Diary Entry #(\d+)$/m);
  if (!idMatch) {
    return null;
  }

  const turnMatch = normalized.match(/^\s*Turn:\s*(\d+)$/m);
  const actionMatch = normalized.match(/^\s*Action:\s*(.+)$/m);
  const placeMatch = normalized.match(/^\s*Place:\s*(.+)$/m);
  const timeMatch = normalized.match(/^\s*Time:\s*(.+)$/m);
  const titleMatch = normalized.match(/^\s*Title:\s*(.+)$/m);
  const bodyMatch = normalized.match(/^\s*Body:\s*([\s\S]*)$/m);

  return {
    id: Number(idMatch[1]),
    turn: Number(turnMatch ? turnMatch[1] : 0),
    action: cleanInput(actionMatch ? actionMatch[1] : ""),
    place: cleanInput(placeMatch ? placeMatch[1] : ""),
    timeOfDay: cleanInput(timeMatch ? timeMatch[1] : ""),
    title: cleanInput(titleMatch ? titleMatch[1] : ""),
    body: String(bodyMatch ? bodyMatch[1] : "").trim()
  };
}

function parseStoryResult(text) {
  const normalized = normalizeRealmText(text);
  const storyIdMatch = normalized.match(/^\s*StoryID:\s*(.+)$/m);
  if (!storyIdMatch) {
    return null;
  }

  const storyTitleMatch = normalized.match(/^\s*StoryTitle:\s*(.+)$/m);
  const pathCodeMatch = normalized.match(/^\s*PathCode:\s*(.+)$/m);
  const outcomeTierMatch = normalized.match(/^\s*OutcomeTier:\s*(\d+)$/m);
  const levelGainMatch = normalized.match(/^\s*LevelGain:\s*(\d+)$/m);
  const grantedReindeerMatch = normalized.match(/^\s*GrantedReindeer:\s*(.+)$/m);
  const grantedCompanionMatch = normalized.match(/^\s*GrantedCompanion:\s*([^\n]*)$/m);
  const placeMatch = normalized.match(/^\s*Place:\s*(.+)$/m);
  const turnMatch = normalized.match(/^\s*Turn:\s*(\d+)$/m);
  const patternMatchesMatch = normalized.match(/^\s*PatternMatches:\s*(\d+)$/m);
  const bonusPercentMatch = normalized.match(/^\s*BonusPercent:\s*(\d+)$/m);
  const successChanceMatch = normalized.match(/^\s*SuccessChance:\s*(\d+)$/m);
  const rollMatch = normalized.match(/^\s*Roll:\s*(\d+)$/m);
  const titleMatch = normalized.match(/^\s*Title:\s*(.+)$/m);
  const bodyMatch = normalized.match(/^\s*Body:\s*([\s\S]*)$/m);

  return {
    storyId: cleanInput(storyIdMatch[1]).toLowerCase(),
    storyTitle: cleanInput(storyTitleMatch ? storyTitleMatch[1] : ""),
    pathCode: cleanInput(pathCodeMatch ? pathCodeMatch[1] : ""),
    outcomeTier: Number(outcomeTierMatch ? outcomeTierMatch[1] : 0),
    levelGain: Number(levelGainMatch ? levelGainMatch[1] : 0),
    grantedReindeer: cleanInput(grantedReindeerMatch ? grantedReindeerMatch[1] : "").toLowerCase() === "yes",
    grantedCompanion: cleanInput(grantedCompanionMatch ? grantedCompanionMatch[1] : ""),
    place: cleanInput(placeMatch ? placeMatch[1] : ""),
    turn: Number(turnMatch ? turnMatch[1] : 0),
    patternMatches: Number(patternMatchesMatch ? patternMatchesMatch[1] : 0),
    bonusPercent: Number(bonusPercentMatch ? bonusPercentMatch[1] : 0),
    successChance: Number(successChanceMatch ? successChanceMatch[1] : 0),
    roll: Number(rollMatch ? rollMatch[1] : 0),
    title: cleanInput(titleMatch ? titleMatch[1] : ""),
    body: String(bodyMatch ? bodyMatch[1] : "").trim()
  };
}

function parseMonsterMarks(text) {
  const normalized = normalizeRealmText(text);
  if (!normalized) {
    return [];
  }
  return normalized
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.startsWith("- "))
    .map((line) => {
      const match = line.match(/^- ([^:]+):\s*(.+)$/);
      if (!match) {
        return null;
      }
      return {
        kind: cleanInput(match[1]).toLowerCase(),
        state: cleanInput(match[2]).toLowerCase()
      };
    })
    .filter(Boolean);
}

function parseCompanionClaimsCount(text) {
  const normalized = normalizeRealmText(text).trim();
  if (!normalized || /no companion claims/i.test(normalized) || /^none\.?$/i.test(normalized)) {
    return 0;
  }
  return normalized
    .split(/\n+/)
    .map((line) => line.trim())
    .filter((line) => line && !/companion claims/i.test(line))
    .length;
}

function parseCompanionClaims(text) {
  const normalized = normalizeRealmText(text).trim();
  if (!normalized || /no companion claims/i.test(normalized) || /^none\.?$/i.test(normalized)) {
    return [];
  }
  return normalized
    .split(/\n+/)
    .map((line) => line.trim())
    .map((line) => {
      const match = line.match(/^- ([^:]+):\s*([a-z0-9_ -]+)\s+x(\d+)$/i);
      if (!match) {
        return null;
      }
      return {
        claimID: cleanInput(match[1]).toLowerCase(),
        type: cleanInput(match[2]).toLowerCase(),
        count: Number(match[3] || 0)
      };
    })
    .filter(Boolean);
}

function parseTileSceneMeta(text) {
  const normalized = normalizeRealmText(text);
  const idMatch = normalized.match(/^\s*TileSceneID:\s*(.+)$/m);
  const id = cleanInput(idMatch ? idMatch[1] : "").toLowerCase();
  if (!id || id === "none") {
    return null;
  }

  const titleMatch = normalized.match(/^\s*TileSceneTitle:\s*(.+)$/m);
  const placeNameMatch = normalized.match(/^\s*TileScenePlaceName:\s*(.+)$/m);
  const terrainMatch = normalized.match(/^\s*TileSceneTerrain:\s*(.+)$/m);
  const resourcesMatch = normalized.match(/^\s*TileSceneResources:\s*(.+)$/m);
  const canNameMatch = normalized.match(/^\s*TileSceneCanName:\s*(.+)$/m);
  const themeMatch = normalized.match(/^\s*TileSceneTheme:\s*(.+)$/m);
  const imageMatch = normalized.match(/^\s*TileSceneImage:\s*(.+)$/m);
  const fallbackMatch = normalized.match(/^\s*TileSceneFallbackImage:\s*(.+)$/m);
  const keywordsMatch = normalized.match(/^\s*TileSceneKeywords:\s*(.+)$/m);
  const textMatch = normalized.match(/^\s*TileSceneText:\s*(.+)$/m);
  const promptMatch = normalized.match(/^\s*TileScenePrompt:\s*(.+)$/m);
  const coordsMatch = id.match(/^tile-(\d+)-(\d+)$/);

  return {
    id,
    title: cleanInput(titleMatch ? titleMatch[1] : ""),
    placeName: cleanInput(placeNameMatch ? placeNameMatch[1] : ""),
    terrain: cleanInput(terrainMatch ? terrainMatch[1] : "").toLowerCase(),
    resources: cleanInput(resourcesMatch ? resourcesMatch[1] : "")
      .split(",")
      .map((value) => cleanInput(value))
      .filter(Boolean),
    canName: cleanInput(canNameMatch ? canNameMatch[1] : "").toLowerCase() === "yes",
    theme: cleanInput(themeMatch ? themeMatch[1] : "").toLowerCase(),
    image: cleanInput(imageMatch ? imageMatch[1] : ""),
    fallbackImage: cleanInput(fallbackMatch ? fallbackMatch[1] : ""),
    keywords: cleanInput(keywordsMatch ? keywordsMatch[1] : ""),
    text: cleanInput(textMatch ? textMatch[1] : ""),
    prompt: cleanInput(promptMatch ? promptMatch[1] : ""),
    x: coordsMatch ? Number(coordsMatch[1]) : 0,
    y: coordsMatch ? Number(coordsMatch[2]) : 0
  };
}

function parseTileStoryBinding(text) {
  const normalized = normalizeRealmText(text);
  const idMatch = normalized.match(/^\s*StoryID:\s*(.+)$/m);
  const storyId = cleanInput(idMatch ? idMatch[1] : "").toLowerCase();
  if (!storyId || storyId === "none") {
    return null;
  }

  const titleMatch = normalized.match(/^\s*StoryTitle:\s*(.+)$/m);
  const themeMatch = normalized.match(/^\s*StoryTheme:\s*(.+)$/m);
  const pathMatch = normalized.match(/^\s*StoryPath:\s*(.+)$/m);
  return {
    id: storyId,
    title: cleanInput(titleMatch ? titleMatch[1] : ""),
    theme: cleanInput(themeMatch ? themeMatch[1] : "").toLowerCase(),
    path: cleanInput(pathMatch ? pathMatch[1] : "")
  };
}

function parseActiveStoryTiles(text) {
  const normalized = normalizeRealmText(text);
  if (!normalized || /No active story tiles\./i.test(normalized)) {
    return {};
  }
  const out = {};
  const lines = normalized.split("\n");
  for (const line of lines) {
    const match = line.match(/^\s*-\s*\((\d+),\s*(\d+)\)\s+([a-z0-9_-]+)\s+\|\s+(.+)\s*$/i);
    if (!match) {
      continue;
    }
    const x = Number(match[1]);
    const y = Number(match[2]);
    out[`${x},${y}`] = {
      id: cleanInput(match[3]).toLowerCase(),
      title: cleanInput(match[4])
    };
  }
  return out;
}

function pairSeed(from, to) {
  const source = `${String(from || "").trim().toLowerCase()}::${String(to || "").trim().toLowerCase()}`;
  let sum = 0;
  for (let i = 0; i < source.length; i += 1) {
    sum += source.charCodeAt(i) * (i + 1);
  }
  return (sum % 251) + 1;
}

function decodeHexMessage(from, to, hexBody) {
  const source = String(hexBody || "").trim().toLowerCase();
  if (!source || source.length % 2 !== 0 || /[^0-9a-f]/.test(source)) {
    return String(hexBody || "").trim();
  }
  const seed = pairSeed(from, to);
  let out = "";
  for (let i = 0; i < source.length; i += 2) {
    const encoded = parseInt(source.slice(i, i + 2), 16);
    const mask = (seed + ((i / 2) * 17)) % 256;
    out += String.fromCharCode(encoded ^ mask);
  }
  return out;
}

function parseMessages(text, recipientName) {
  const normalized = normalizeRealmText(text);
  if (!normalized || /^No messages\./i.test(normalized)) {
    return [];
  }
  const recipient = cleanInput(recipientName);
  return normalized
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.startsWith("- #"))
    .map((line) => {
      const match = line.match(/^- #(\d+) from (.+?):\s*(.+)$/);
      if (!match) {
        return null;
      }
      const from = cleanInput(match[2]);
      const bodyEncoded = cleanInput(match[3]);
      return {
        id: Number(match[1]),
        from,
        to: recipient,
        bodyEncoded,
        body: decodeHexMessage(from, recipient, bodyEncoded)
      };
    })
    .filter(Boolean);
}

function parseLatestIncomingMessage(text, recipientName) {
  const normalized = normalizeRealmText(text);
  if (!normalized || /^No messages\./i.test(normalized)) {
    return null;
  }
  const fromMatch = normalized.match(/^\s*From:\s*(.+)$/m);
  if (!fromMatch) {
    return null;
  }
  const turnMatch = normalized.match(/^\s*Turn:\s*(\d+)$/m);
  const bodyMatch = normalized.match(/^\s*Body:\s*(.+)$/m);
  const from = cleanInput(fromMatch[1]);
  const to = cleanInput(recipientName);
  const bodyEncoded = cleanInput(bodyMatch ? bodyMatch[1] : "");
  return {
    from,
    to,
    turn: Number(turnMatch ? turnMatch[1] : 0),
    bodyEncoded,
    body: decodeHexMessage(from, to, bodyEncoded)
  };
}

function normalizeCatalogStory(entryStory) {
  if (!entryStory) {
    return null;
  }
  const id = cleanInput(entryStory.id).toLowerCase();
  if (!id) {
    return null;
  }
  return {
    id,
    title: cleanInput(entryStory.title),
    theme: cleanInput(entryStory.theme).toLowerCase(),
    path: cleanInput(entryStory.path)
  };
}

function storyForTile(x, y) {
  const entry = SPECIAL_TILE_STORIES[`${Number(x)},${Number(y)}`];
  return entry ? { ...entry } : null;
}

let placeCatalogPromise = null;

async function loadPlaceCatalog() {
  if (!placeCatalogPromise) {
    placeCatalogPromise = fetch(appUrl("../story/places.json"), { cache: "no-store" })
      .then((response) => {
        if (!response.ok) {
          throw new Error("HTTP " + response.status);
        }
        return response.json();
      });
  }
  return placeCatalogPromise;
}

async function resolveTileSceneMeta(sceneMeta) {
  if (!sceneMeta || !sceneMeta.id) {
    return sceneMeta;
  }

  try {
    const catalog = await loadPlaceCatalog();
    const entry = catalog && catalog[sceneMeta.id];
    if (!entry) {
      return sceneMeta;
    }

    return {
      ...sceneMeta,
      title: cleanInput(sceneMeta.placeName) || cleanInput(entry.title) || sceneMeta.title,
      theme: cleanInput(entry.theme).toLowerCase() || sceneMeta.theme,
      image: cleanInput(entry.image) || sceneMeta.image,
      fallbackImage: cleanInput(entry.fallbackImage) || sceneMeta.fallbackImage,
      keywords: [sceneMeta.keywords, cleanInput(entry.keywords)].filter(Boolean).join(","),
      text: cleanInput(entry.description) || sceneMeta.text,
      prompt: sceneMeta.prompt,
      imagePrompt: cleanInput(entry.imagePrompt),
      placeName: sceneMeta.placeName,
      story: normalizeCatalogStory(entry.story) || sceneMeta.story || storyForTile(sceneMeta.x, sceneMeta.y) || null
    };
  } catch (err) {
    return {
      ...sceneMeta,
      story: sceneMeta.story || storyForTile(sceneMeta.x, sceneMeta.y) || null
    };
  }
}

function inBounds(x, y) {
  return y >= 0 && y < MAP_ROWS.length && x >= 0 && x < MAP_ROWS[y].length;
}

function tileCodeAt(x, y) {
  if (!inBounds(x, y)) {
    return 0;
  }
  return MAP_ROWS[y][x];
}

function waterTravelTile(code) {
  return [0, 1, 8, 11, 13, 14].includes(Number(code));
}

function oceanTravelTile(code) {
  return Number(code) === 0;
}

function adjacent(a, b) {
  const dx = Math.abs(a.x - b.x);
  const dy = Math.abs(a.y - b.y);
  return (dx <= 1 && dy <= 1) && !(dx === 0 && dy === 0);
}

function neighbors(pos) {
  const out = [];
  for (let dx = -1; dx <= 1; dx += 1) {
    for (let dy = -1; dy <= 1; dy += 1) {
      if (dx === 0 && dy === 0) {
        continue;
      }
      const next = { x: pos.x + dx, y: pos.y + dy };
      if (inBounds(next.x, next.y) && tileCodeAt(next.x, next.y) !== 0) {
        out.push(next);
      }
    }
  }
  return out;
}

function waterNeighbors(pos) {
  const out = [];
  for (let dx = -1; dx <= 1; dx += 1) {
    for (let dy = -1; dy <= 1; dy += 1) {
      if (dx === 0 && dy === 0) {
        continue;
      }
      const next = { x: pos.x + dx, y: pos.y + dy };
      if (inBounds(next.x, next.y) && waterTravelTile(tileCodeAt(next.x, next.y))) {
        out.push(next);
      }
    }
  }
  return out;
}

function landReachableCosts(origin, budget) {
  const costs = new Map();
  const queue = [{ x: origin.x, y: origin.y, cost: 0 }];
  costs.set(`${origin.x},${origin.y}`, 0);

  while (queue.length > 0) {
    queue.sort((a, b) => a.cost - b.cost);
    const current = queue.shift();
    const currentKey = `${current.x},${current.y}`;
    if (current.cost !== costs.get(currentKey)) {
      continue;
    }

    for (const next of neighbors(current)) {
      const nextCost = current.cost + movementCost(tileCodeAt(next.x, next.y));
      const nextKey = `${next.x},${next.y}`;
      if (nextCost > budget) {
        continue;
      }
      if (!costs.has(nextKey) || nextCost < costs.get(nextKey)) {
        costs.set(nextKey, nextCost);
        queue.push({ x: next.x, y: next.y, cost: nextCost });
      }
    }
  }

  return costs;
}

function boatReachableCosts(origin, budget) {
  const results = new Map();
  const startCode = tileCodeAt(origin.x, origin.y);
  if (!waterTravelTile(startCode)) {
    return results;
  }

  const visited = new Map();
  const queue = [{ x: origin.x, y: origin.y, cost: 0 }];
  visited.set(`${origin.x},${origin.y}`, 0);

  while (queue.length > 0) {
    queue.sort((a, b) => a.cost - b.cost);
    const current = queue.shift();
    const visitKey = `${current.x},${current.y}`;
    if (current.cost !== visited.get(visitKey)) {
      continue;
    }

    const key = `${current.x},${current.y}`;
    const existing = results.get(key);
    if (existing === undefined || current.cost < existing) {
      results.set(key, current.cost);
    }

    for (const next of waterNeighbors(current)) {
      const nextCost = current.cost + 1;
      if (nextCost > budget) {
        continue;
      }
      const nextVisitKey = `${next.x},${next.y}`;
      if (!visited.has(nextVisitKey) || nextCost < visited.get(nextVisitKey)) {
        visited.set(nextVisitKey, nextCost);
        queue.push({
          x: next.x,
          y: next.y,
          cost: nextCost
        });
      }
    }
  }

  return results;
}

function reachableCosts(origin, player) {
  const reach = new Map();
  const originCode = tileCodeAt(origin.x, origin.y);
  const landBudget = 3 + Number(player?.travelBonus || 0);

  if (originCode !== 0) {
    const land = landReachableCosts(origin, landBudget);
    for (const [key, cost] of land.entries()) {
      reach.set(key, { cost, budget: landBudget, mode: "land" });
    }
  }

  if (player?.carriesBoat && waterTravelTile(originCode)) {
    const boatBudget = 8;
    const boat = boatReachableCosts(origin, boatBudget);
    for (const [key, cost] of boat.entries()) {
      const existing = reach.get(key);
      if (!existing || cost < existing.cost || (existing.mode === "boat" && cost < existing.cost)) {
        reach.set(key, { cost, budget: boatBudget, mode: "boat" });
      }
    }
  }

  return reach;
}

function currentViewPosition(state) {
  if (state.travel.active && state.travel.cursor) {
    return state.travel.cursor;
  }
  return state.player.position;
}

function mapModel(state) {
  const playerPos = state.player.position;
  const cursor = state.travel.active ? state.travel.cursor : null;
  const reachable = state.travel.active && state.travel.origin
    ? reachableCosts(state.travel.origin, state.player)
    : null;
  const activeStoryTiles = state.activeStoryTiles || {};
  return MAP_ROWS.map((row, y) =>
    row.map((code, x) => ({
      x,
      y,
      code,
      terrain: terrainName(code),
      isPlayer: playerPos.x === x && playerPos.y === y,
      isCursor: !!cursor && cursor.x === x && cursor.y === y,
      isAdjacent: !!cursor && adjacent(cursor, { x, y }),
      isReachable: !!reachable && reachable.has(`${x},${y}`),
      travelCost: reachable && reachable.has(`${x},${y}`) ? reachable.get(`${x},${y}`).cost : null,
      activeStory: activeStoryTiles[`${x},${y}`] || null
    }))
  );
}

function notReadyState(message = "Gno adapter loading.") {
  return {
    player: {
      name: playerNameFromStorage(),
      position: { x: 14, y: 6 },
      pearls: 0,
      level: 0,
      travelBonus: 0
    },
    mailbox: {
      messages: [],
      latest: null
    },
    map: [],
    activeStoryTiles: {},
    place: {
      title: "Loading live realm",
      placeName: "",
      theme: "city",
      text: message,
      image: appUrl("../stories/fallback/images/themes/city.svg"),
      fallbackImage: appUrl("../stories/fallback/images/themes/city.svg"),
      canName: false,
      terrain: "city",
      x: 14,
      y: 6
    },
    travel: {
      active: false,
      origin: null,
      cursor: null,
      movesLeft: 0,
      movesTotal: 0
    },
    log: [message]
  };
}

function inactiveTravelState() {
  return {
    active: false,
    origin: null,
    cursor: null,
    movesLeft: 0,
    movesTotal: 0
  };
}

function planningTravelState(player) {
  const origin = clone(player?.position || { x: 14, y: 6 });
  const total = player?.carriesBoat && waterTravelTile(tileCodeAt(origin.x, origin.y))
    ? 8
    : (3 + Number(player?.travelBonus || 0));
  return {
    active: true,
    origin,
    cursor: clone(origin),
    movesLeft: total,
    movesTotal: total
  };
}

export function createGnoGameApi() {
  let state = notReadyState();

  async function loadLivePlayerPositions() {
    const text = await runQeval(`${PKG_PATH}.ListPlayerPositions()`);
    return parsePlayerPositions(text);
  }

  async function hydrateOverlayState(nextState, baseState) {
    const previousLoads = baseState?.loads || { active: false, counts: {}, total: 0 };
    const previousFrens = baseState?.frens || { active: false, query: "", entries: [], missing: [] };
    let livePositions = null;
    const selfKey = String(nextState?.player?.name || "").trim().toLowerCase();

    if (previousLoads.active || previousFrens.active) {
      try {
        livePositions = await loadLivePlayerPositions();
      } catch (err) {
        livePositions = [];
      }
    }

    if (previousLoads.active) {
      const counts = {};
      let total = 0;
      for (const entry of livePositions || []) {
        if (String(entry?.name || "").trim().toLowerCase() === selfKey) {
          continue;
        }
        const key = `${entry.position.x},${entry.position.y}`;
        counts[key] = (counts[key] || 0) + 1;
        total += 1;
      }
      nextState.loads = {
        active: true,
        counts,
        total
      };
    } else {
      nextState.loads = { active: false, counts: {}, total: 0 };
    }

    if (previousFrens.active) {
      const requested = parseFriendQuery(previousFrens.query);
      const entries = [];
      const missing = [];
      const positionsByName = new Map(
        (livePositions || [])
          .filter((entry) => String(entry?.name || "").trim().toLowerCase() !== selfKey)
          .map((entry) => [entry.name.toLowerCase(), entry.position])
      );
      for (const requestedName of requested) {
        try {
          const { player: parsed } = await loadPlayerData(requestedName);
          if (String(parsed?.name || "").trim().toLowerCase() === selfKey) {
            continue;
          }
          entries.push({
            name: parsed.name,
            position: parsed.position,
            appearance16: parsed.appearance16 || "",
            online: positionsByName.has(parsed.name.toLowerCase())
          });
        } catch (err) {
          missing.push(requestedName);
        }
      }
      nextState.frens = {
        active: true,
        query: previousFrens.query,
        entries,
        missing
      };
    } else {
      nextState.frens = {
        active: false,
        query: "",
        entries: [],
        missing: []
      };
    }
  }

  async function loadSceneAt(x, y) {
    const playerName = playerNameFromStorage();
    const text = await runQeval(`${PKG_PATH}.DescribeTileSceneAt(${Number(x)}, ${Number(y)})`);
    const parsed = parseTileSceneMeta(text);
    const dynamicStory = await (async () => {
      try {
        const bindingText = await runQeval(`${PKG_PATH}.DescribeTileStoryBindingAt(${JSON.stringify(playerName)}, ${Number(x)}, ${Number(y)})`);
        return parseTileStoryBinding(bindingText);
      } catch (err) {
        return null;
      }
    })();
    if (!parsed) {
      const code = tileCodeAt(x, y);
      const specialStory = dynamicStory || storyForTile(x, y);
      return {
        id: `tile-${x}-${y}`,
        title: specialStory ? specialStory.title : "Unknown place",
        placeName: "",
        canName: !state.travel.active && canNameTile(code),
        theme: terrainName(code),
        image: appUrl(`../stories/fallback/images/tiles/${x}_${y}.svg`),
        fallbackImage: fallbackImageForTerrain(code),
        keywords: "",
        text: specialStory ? "This place responds to the attitude you bring into it on arrival." : "",
        prompt: "",
        story: specialStory,
        terrain: terrainName(code),
        x,
        y
      };
    }
    const resolved = await resolveTileSceneMeta(parsed);
    return {
      ...resolved,
      story: resolved?.story || dynamicStory || storyForTile(x, y) || null,
      terrain: terrainName(tileCodeAt(x, y)),
      x,
      y
    };
  }

  async function hydrateState(baseState, logMessage = "") {
    const playerName = playerNameFromStorage();
    const playerData = await loadPlayerData(playerName);
    const player = playerData.player;
    const storyBindingText = await runQeval(`${PKG_PATH}.DescribeTileStoryBinding(${JSON.stringify(playerName)})`);
    const boundStory = parseTileStoryBinding(storyBindingText);
    const latestStoryResult = await (async () => {
      try {
        const resultText = await runQeval(`${PKG_PATH}.DescribeLatestStoryResult(${JSON.stringify(playerName)})`);
        return parseStoryResult(resultText);
      } catch (err) {
        return null;
      }
    })();
    const companionList = playerData.companionList;
    const monsterMarks = await (async () => {
      try {
        const marksText = await runQeval(`${PKG_PATH}.DescribeMonsterMarks(${JSON.stringify(playerName)})`);
        return parseMonsterMarks(marksText);
      } catch (err) {
        return [];
      }
    })();
    const companionClaims = await (async () => {
      try {
        const claimsText = await runQeval(`${PKG_PATH}.DescribeCompanionClaims(${JSON.stringify(playerName)})`);
        return parseCompanionClaims(claimsText);
      } catch (err) {
        return [];
      }
    })();
    const activeStoryTiles = await (async () => {
      try {
        const storyTilesText = await runQeval(`${PKG_PATH}.ListActiveStoryTiles(${JSON.stringify(playerName)})`);
        return parseActiveStoryTiles(storyTilesText);
      } catch (err) {
        return {};
      }
    })();
    const mailbox = await (async () => {
      try {
        const [messagesText, latestText] = await Promise.all([
          runQeval(`${PKG_PATH}.GetMessages(${JSON.stringify(playerName)})`),
          runQeval(`${PKG_PATH}.DescribeLatestIncomingMessage(${JSON.stringify(playerName)})`)
        ]);
        return {
          messages: parseMessages(messagesText, playerName),
          latest: parseLatestIncomingMessage(latestText, playerName)
        };
      } catch (err) {
        return {
          messages: [],
          latest: null
        };
      }
    })();
    const travel = clone(baseState?.travel || inactiveTravelState());
    const nextState = {
      player,
      companionList,
      monsterMarks,
      companionClaims,
      companionClaimsCount: companionClaims.reduce((sum, claim) => sum + Number(claim.count || 0), 0),
      mailbox,
      travel,
      map: [],
      activeStoryTiles,
      place: null,
      storyResult: latestStoryResult,
      loads: baseState?.loads || { active: false, counts: {}, total: 0 },
      frens: baseState?.frens || { active: false, query: "", entries: [], missing: [] },
      log: logMessage
        ? [logMessage, ...(baseState?.log || [])].slice(0, 24)
        : [...(baseState?.log || [])]
    };
    const viewPos = currentViewPosition(nextState);
    nextState.place = await loadSceneAt(viewPos.x, viewPos.y);
    if (boundStory && viewPos.x === player.position.x && viewPos.y === player.position.y) {
      nextState.place = {
        ...nextState.place,
        story: boundStory
      };
    }
    nextState.map = mapModel(nextState);
    await hydrateOverlayState(nextState, baseState);
    if (!nextState.log.length) {
      nextState.log = ["Live readonly realm loaded."];
    }
    state = nextState;
    return nextState;
  }

  return {
    identity() {
      return {
        playerName: playerNameFromStorage(),
        keyName: keyNameFromStorage(),
        attitude: attitudeFromStorage()
      };
    },

    attitude() {
      return attitudeFromStorage();
    },

    setAttitude(attitude) {
      return persistAttitude(attitude);
    },

    async getState() {
      return hydrateState(state);
    },

    async refresh() {
      const nextBase = {
        ...state,
        travel: inactiveTravelState()
      };
      return hydrateState(nextBase, "Refreshed live readonly state.");
    },

    async describeCompanionRegistry(kind) {
      const query = cleanInput(kind);
      if (!query) {
        throw new Error("Companion kind is required.");
      }
      const text = await runQeval(`${PKG_PATH}.DescribeCompanionRegistry(${JSON.stringify(query)})`);
      return normalizeRealmText(text);
    },

    async beginTravel() {
      const nextBase = {
        ...state,
        travel: planningTravelState(state.player)
      };
      return hydrateState(nextBase, "Travel mode opened. Click any reachable tile to stage a TravelPlayer command.");
    },

    async cancelTravel() {
      const nextBase = {
        ...state,
        travel: inactiveTravelState()
      };
      return hydrateState(nextBase, "Travel mode closed.");
    },

    async moveTravelTo(x, y) {
      if (!state.travel.active || !state.travel.cursor) {
        return state;
      }
      if (!inBounds(x, y)) {
        return state;
      }
      const currentCursor = state.travel.cursor;
      const targetKey = `${x},${y}`;
      if (targetKey === `${currentCursor.x},${currentCursor.y}`) {
        return state;
      }
      const reachable = reachableCosts(state.travel.origin, state.player);
      if (!reachable.has(targetKey)) {
        return state;
      }
      const costInfo = reachable.get(targetKey);
      const cost = costInfo.cost;

      const nextBase = {
        ...state,
        travel: {
          ...state.travel,
          cursor: { x, y },
          movesTotal: costInfo.budget,
          movesLeft: costInfo.budget - cost
        }
      };
      const command = buildTravelPlayerCommand(state.player.name, x, y, attitudeFromStorage());
      return hydrateState(
        nextBase,
        `Travel staged for (${x}, ${y}) costing ${cost} ${costInfo.mode === "boat" ? "water " : ""}moves in ${attitudeFromStorage()} attitude. ${nextBase.travel.movesLeft} moves remain from a ${costInfo.mode === "boat" ? "boat" : "land"} budget of ${costInfo.budget}.\n${command}`
      );
    },

    async resetTravel() {
      const nextTravel = planningTravelState(state.player);
      const nextBase = {
        ...state,
        travel: nextTravel
      };
      return hydrateState(nextBase, "Travel route reset to your current position.");
    },

    async commitTravel() {
      if (!state.travel.active || !state.travel.cursor) {
        return hydrateState(state, "Open travel mode first.");
      }
      const command = buildTravelPlayerCommand(state.player.name, state.travel.cursor.x, state.travel.cursor.y, attitudeFromStorage());
      return hydrateState(state, `Travel command ready.\n${command}`);
    },

    async nameCurrentTile(placeName) {
      const clean = cleanInput(placeName);
      if (!clean) {
        return state;
      }
      const command = buildNameTileCommand(state.player.name, clean);
      return hydrateState(state, `NameTile command ready.\n${command}`);
    },

    async importIdentity(playerName, keyName) {
      const nextPlayerName = cleanInput(playerName);
      if (!nextPlayerName) {
        throw new Error("Enter the player name you want to import.");
      }
      const nextKeyName = cleanInput(keyName) || keyNameFromStorage();
      await loadPlayerData(nextPlayerName);
      persistIdentity(nextPlayerName, nextKeyName);
      return hydrateState({
        ...state,
        travel: inactiveTravelState()
      }, `Imported player ${nextPlayerName} into this browser session.`);
    },

    async stageMintIdentity(playerName, keyName) {
      const identity = persistIdentity(playerName, keyName);
      const command = buildMintPlayerCommand(identity.playerName, identity.keyName);
      const current = state || notReadyState();
      const nextState = {
        ...current,
        log: [`Mint command ready.\n${command}`, ...(current.log || [])].slice(0, 24)
      };
      state = nextState;
      return nextState;
    },

    async stageMintEarnedCompanion() {
      const identity = {
        playerName: playerNameFromStorage(),
        keyName: keyNameFromStorage()
      };
      const claims = Array.isArray(state?.companionClaims) ? state.companionClaims : [];
      const claim = claims.find((entry) => Number(entry?.count || 0) > 0);
      if (!claim?.claimID) {
        throw new Error("No mintable companion claims are ready.");
      }
      const command = buildMintEarnedCompanionCommand(identity.playerName, identity.keyName, claim.claimID, "");
      const current = state || notReadyState();
      const nextState = {
        ...current,
        log: [`Companion mint command ready for ${claim.type}.\n${command}`, ...(current.log || [])].slice(0, 24)
      };
      state = nextState;
      return nextState;
    },

    async stageBuyBoat() {
      const identity = {
        playerName: playerNameFromStorage(),
        keyName: keyNameFromStorage()
      };
      const command = buildBuyBoatCommand(identity.playerName, identity.keyName);
      const current = state || notReadyState();
      const nextState = {
        ...current,
        log: [`Buy boat command ready.\n${command}`, ...(current.log || [])].slice(0, 24)
      };
      state = nextState;
      return nextState;
    },

    async stageSetPlayerAppearance(appearance16) {
      const identity = {
        playerName: playerNameFromStorage(),
        keyName: keyNameFromStorage()
      };
      const command = buildSetPlayerAppearanceCommand(identity.playerName, identity.keyName, appearance16);
      const current = state || notReadyState();
      const nextState = {
        ...current,
        log: [`Appearance command ready.\n${command}`, ...(current.log || [])].slice(0, 24)
      };
      state = nextState;
      return nextState;
    },

    async stageWriteToFriend(toPlayerName, body) {
      const to = cleanInput(toPlayerName);
      const text = cleanInput(body);
      if (!to) {
        throw new Error("Choose who you want to write to.");
      }
      if (!text) {
        throw new Error("Write a short message first.");
      }
      const identity = {
        playerName: playerNameFromStorage(),
        keyName: keyNameFromStorage()
      };
      const command = buildWriteToFriendCommand(identity.playerName, identity.keyName, to, text);
      const current = state || notReadyState();
      const nextState = {
        ...current,
        log: [`Message command ready.\n${command}`, ...(current.log || [])].slice(0, 24)
      };
      state = nextState;
      return nextState;
    },

    async loadPlayerCounts() {
      const current = state || notReadyState();
      const nextState = {
        ...current,
        loads: {
          active: true,
          counts: current.loads?.counts || {},
          total: current.loads?.total || 0
        }
      };
      return hydrateState(nextState, "Loads refreshed. Hearts now show how many living players stand on each tile.");
    },

    async clearPlayerCounts() {
      const current = state || notReadyState();
      const nextState = {
        ...current,
        loads: {
          active: false,
          counts: {},
          total: 0
        }
      };
      state = nextState;
      return nextState;
    },

    async loadFrens(query) {
      const cleanedQuery = String(query || "").trim();
      if (!cleanedQuery) {
        throw new Error("Enter at least one fren name.");
      }
      const current = state || notReadyState();
      const nextState = {
        ...current,
        frens: {
          active: true,
          query: cleanedQuery,
          entries: current.frens?.entries || [],
          missing: current.frens?.missing || []
        }
      };
      return hydrateState(nextState, `Frens loaded for ${cleanedQuery}.`);
    },

    async clearFrens() {
      const current = state || notReadyState();
      const nextState = {
        ...current,
        frens: {
          active: false,
          query: "",
          entries: [],
          missing: []
        }
      };
      state = nextState;
      return nextState;
    },

    async latestStoryResult() {
      const playerName = playerNameFromStorage();
      try {
        const resultText = await runQeval(`${PKG_PATH}.DescribeLatestStoryResult(${JSON.stringify(playerName)})`);
        const result = parseStoryResult(resultText);
        if (!result) {
          return null;
        }
        return result;
      } catch (err) {
        const message = err?.message || String(err);
        if (message.includes("player has no story results")) {
          return null;
        }
        throw err;
      }
    },

    async latestStoryDiaryEntry() {
      const playerName = playerNameFromStorage();
      try {
        const entryText = await runQeval(`${PKG_PATH}.DescribeLatestStoryDiaryEntry(${JSON.stringify(playerName)})`);
        return parseDiaryEntry(entryText);
      } catch (err) {
        const message = err?.message || String(err);
        if (message.includes("player diary is empty") || message.includes("player has no story diary entries")) {
          return null;
        }
        throw err;
      }
    },

    async latestStoryDiagnostics() {
      const playerName = playerNameFromStorage();
      const out = {
        resultRaw: "",
        resultParsed: null,
        diaryRaw: "",
        diaryParsed: null,
        errors: []
      };

      try {
        out.resultRaw = await runQeval(`${PKG_PATH}.DescribeLatestStoryResult(${JSON.stringify(playerName)})`);
        out.resultParsed = parseStoryResult(out.resultRaw);
      } catch (err) {
        out.errors.push(`result: ${err?.message || String(err)}`);
      }

      try {
        out.diaryRaw = await runQeval(`${PKG_PATH}.DescribeLatestStoryDiaryEntry(${JSON.stringify(playerName)})`);
        out.diaryParsed = parseDiaryEntry(out.diaryRaw);
      } catch (err) {
        out.errors.push(`diary: ${err?.message || String(err)}`);
      }

      return out;
    }
  };
}
