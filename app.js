import { createGnoGameApi } from "./api/gno_game_api.js";
import { createStore } from "./state/store.js";
import { movementCost } from "./api/map_data.js";

const refreshButton = document.getElementById("refreshButton");
const seasonChip = document.getElementById("seasonChip");
const mapHomeButton = document.getElementById("mapHomeButton");
const openPlayerPanelButton = document.getElementById("openPlayerPanelButton");
const openPortraitPanelButton = document.getElementById("openPortraitPanelButton");
const openPlacePanelButton = document.getElementById("openPlacePanelButton");
const openMailPanelButton = document.getElementById("openMailPanelButton");
const mapCommandOverlay = document.getElementById("mapCommandOverlay");
const mapCommandText = document.getElementById("mapCommandText");
const copyMapCommandButton = document.getElementById("copyMapCommandButton");
const playerCommandOverlay = document.getElementById("playerCommandOverlay");
const playerCommandTitle = document.getElementById("playerCommandTitle");
const playerCommandText = document.getElementById("playerCommandText");
const copyPlayerCommandButton = document.getElementById("copyPlayerCommandButton");
const closePlayerCommandButton = document.getElementById("closePlayerCommandButton");
const mailCommandOverlay = document.getElementById("mailCommandOverlay");
const mailCommandTitle = document.getElementById("mailCommandTitle");
const mailCommandText = document.getElementById("mailCommandText");
const copyMailCommandButton = document.getElementById("copyMailCommandButton");
const closeMailCommandButton = document.getElementById("closeMailCommandButton");
const attitudeCautiousButton = document.getElementById("attitudeCautiousButton");
const attitudeKindButton = document.getElementById("attitudeKindButton");
const attitudeBoldButton = document.getElementById("attitudeBoldButton");
const tileLabelsButton = document.getElementById("tileLabelsButton");
const mapFullscreenButton = document.getElementById("mapFullscreenButton");
const mapPanel = document.getElementById("mapPanel");
const mapRoot = document.getElementById("mapRoot");
const playerPanel = document.getElementById("playerPanel");
const portraitPanel = document.getElementById("portraitPanel");
const placePanel = document.getElementById("placePanel");
const mailPanel = document.getElementById("mailPanel");
const placeTitle = document.getElementById("placeTitle");
const placeMeta = document.getElementById("placeMeta");
const placeVisual = document.getElementById("placeVisual");
const placeText = document.getElementById("placeText");
const placeActions = document.getElementById("placeActions");
const playerStageName = document.getElementById("playerStageName");
const playerStagePosition = document.getElementById("playerStagePosition");
const playerStageStats = document.getElementById("playerStageStats");
const playerStageWealth = document.getElementById("playerStageWealth");
const playerStageItems = document.getElementById("playerStageItems");
const playerStageCompanions = document.getElementById("playerStageCompanions");
const playerStageMonsters = document.getElementById("playerStageMonsters");
const playerStageClaims = document.getElementById("playerStageClaims");
const playerName = document.getElementById("playerName");
const playerPosition = document.getElementById("playerPosition");
const playerPearls = document.getElementById("playerPearls");
const playerLevel = document.getElementById("playerLevel");
const playerTravelBonus = document.getElementById("playerTravelBonus");
const playerItems = document.getElementById("playerItems");
const playerSpiritStats = document.getElementById("playerSpiritStats");
const playerCompanions = document.getElementById("playerCompanions");
const playerMonsters = document.getElementById("playerMonsters");
const stagePearls = document.getElementById("stagePearls");
const stageMoves = document.getElementById("stageMoves");
const stageBoat = document.getElementById("stageBoat");
const stageBoldness = document.getElementById("stageBoldness");
const stageCaution = document.getElementById("stageCaution");
const stageKindness = document.getElementById("stageKindness");
const stageSoul = document.getElementById("stageSoul");
const stageCompanions = document.getElementById("stageCompanions");
const stageMonsters = document.getElementById("stageMonsters");
const stageClaims = document.getElementById("stageClaims");
const mintCompanionButton = document.getElementById("mintCompanionButton");
const stageCompanionIcon = document.getElementById("stageCompanionIcon");
const stageMonsterIcon = document.getElementById("stageMonsterIcon");
const companionRegistryInput = document.getElementById("companionRegistryInput");
const companionRegistryButton = document.getElementById("companionRegistryButton");
const companionRegistryResult = document.getElementById("companionRegistryResult");
const loadPlayersButton = document.getElementById("loadPlayersButton");
const clearLoadsButton = document.getElementById("clearLoadsButton");
const frensInput = document.getElementById("frensInput");
const loadFrensButton = document.getElementById("loadFrensButton");
const clearFrensButton = document.getElementById("clearFrensButton");
const frensResult = document.getElementById("frensResult");
const messageToInput = document.getElementById("messageToInput");
const messageBodyInput = document.getElementById("messageBodyInput");
const messageSendButton = document.getElementById("messageSendButton");
const messageRefreshButton = document.getElementById("messageRefreshButton");
const messageInboxResult = document.getElementById("messageInboxResult");
const adenaConnectButton = document.getElementById("adenaConnectButton");
const adenaUploadPackageButton = document.getElementById("adenaUploadPackageButton");
const adenaDeployResult = document.getElementById("adenaDeployResult");
const eventLog = document.getElementById("eventLog");
const travelBadge = document.getElementById("travelBadge");
const travelNotice = document.getElementById("travelNotice");
const identityPlayerName = document.getElementById("identityPlayerName");
const identityKeyName = document.getElementById("identityKeyName");
const importIdentityButton = document.getElementById("importIdentityButton");
const stageMintButton = document.getElementById("stageMintButton");
const nameInput = document.getElementById("nameInput");
const nameButton = document.getElementById("nameButton");
const avatarPreview = document.getElementById("avatarPreview");
const avatarEditor = document.getElementById("avatarEditor");
const avatarPalette = document.getElementById("avatarPalette");
const avatarEraseButton = document.getElementById("avatarEraseButton");
const avatarClearButton = document.getElementById("avatarClearButton");
const avatarSaveButton = document.getElementById("avatarSaveButton");
const avatarBox = document.getElementById("avatarBox");

const TILE_LABELS_STORAGE_KEY = "nisse.uiClick.showTileLabels";
const AVATAR_STORAGE_KEY = "nisse.avatar16";
const FOG_REVEAL_STORAGE_KEY_PREFIX = "nisse.uiClick.revealedTiles";
const FOG_LAST_POSITION_STORAGE_KEY_PREFIX = "nisse.uiClick.lastPosition";
const FOG_DEBUG = true;
const MAP_TILE_ASSET_BASE = "/assets/map-tiles-web";
const PLACE_TILE_ASSET_BASE = "/assets/map-tiles";
const BENEVOLENT_MONASTERY_IMAGE = "/assets/map-tiles/benevolent.png";
const PLAYER_SPRITE_IMAGE = "/assets/nissesprite.png";
const LOCAL_REALM_PKG_PATH = "gno.land/r/g1sqlsr3e2efk349w0753j7jhqrpz5x0uqmps6lf/nisse";
const HOSTED_REALM_PKG_PATH = "gno.land/r/g1sqlsr3e2efk349w0753j7jhqrpz5x0uqmps6lf/nisse01";
const STAGING_DEPLOY_MANIFEST_PATH = "./deploy/nisse-package.staging-core.json";
const AVATAR_SIZE = 16;
const AVATAR_PALETTE = [
  "transparent",
  "#140f1d",
  "#2a1f3a",
  "#5b3f8c",
  "#a45bff",
  "#ff6db2",
  "#ff8a5b",
  "#ffd166",
  "#ffe7b8",
  "#f2c6a0",
  "#d89a73",
  "#8f5d43",
  "#4f3128",
  "#53e0d7",
  "#1fb6c9",
  "#5c8cff",
  "#d6f4ff",
  "#b7ff7a",
  "#5fdd6b",
  "#2d8f5b",
  "#1f4d45",
  "#f7f1e3"
];
const MAP_TERRAIN_IMAGES = {
  ocean: `${MAP_TILE_ASSET_BASE}/ocean.png`,
  coastal: `${MAP_TILE_ASSET_BASE}/coastal_seadown.png`,
  moor: `${MAP_TILE_ASSET_BASE}/moor.png`,
  meadow: `${MAP_TILE_ASSET_BASE}/meadow.png`,
  forest: `${MAP_TILE_ASSET_BASE}/forest.png`,
  hills: `${MAP_TILE_ASSET_BASE}/hills.png`,
  farm: `${MAP_TILE_ASSET_BASE}/farm.png`,
  village: `${MAP_TILE_ASSET_BASE}/village.png`,
  monastery: `${MAP_TILE_ASSET_BASE}/monastery.png`,
  harbor: `${MAP_TILE_ASSET_BASE}/harbor.png`,
  city: `${MAP_TILE_ASSET_BASE}/citynorth.png`,
  mountain: `${MAP_TILE_ASSET_BASE}/mountain.png`,
  fishing_village: `${MAP_TILE_ASSET_BASE}/fishingvillage.png`,
  mountain_village: `${MAP_TILE_ASSET_BASE}/mountainvillage.png`,
  city_north: `${MAP_TILE_ASSET_BASE}/citynorth.png`,
  city_south: `${MAP_TILE_ASSET_BASE}/citysouth.png`
};
const PLACE_TERRAIN_IMAGES = {
  ocean: `${PLACE_TILE_ASSET_BASE}/ocean.png`,
  coastal: `${PLACE_TILE_ASSET_BASE}/coastal_seadown.png`,
  moor: `${PLACE_TILE_ASSET_BASE}/moor.png`,
  meadow: `${PLACE_TILE_ASSET_BASE}/meadow.png`,
  forest: `${PLACE_TILE_ASSET_BASE}/forest.png`,
  hills: `${PLACE_TILE_ASSET_BASE}/hills.png`,
  farm: `${PLACE_TILE_ASSET_BASE}/farm.png`,
  village: `${PLACE_TILE_ASSET_BASE}/village.png`,
  monastery: `${PLACE_TILE_ASSET_BASE}/monastery.png`,
  harbor: `${PLACE_TILE_ASSET_BASE}/harbor.png`,
  city: `${PLACE_TILE_ASSET_BASE}/citynorth.png`,
  mountain: `${PLACE_TILE_ASSET_BASE}/mountain.png`,
  fishing_village: `${PLACE_TILE_ASSET_BASE}/fishingvillage.png`,
  mountain_village: `${PLACE_TILE_ASSET_BASE}/mountainvillage.png`,
  city_north: `${PLACE_TILE_ASSET_BASE}/citynorth.png`,
  city_south: `${PLACE_TILE_ASSET_BASE}/citysouth.png`
};
const TRAVEL_ANIMATION_STEP_MS = 170;
const STORY_RESULT_POLL_MS = 4000;
const STORY_RESULT_POLL_TIMEOUT_MS = 120000;
const APP_MODE = inferAppMode();

let api = createGnoGameApi();
const store = createStore(null);
let showTileLabels = loadTileLabelsPreference();
let markerAnimation = {
  active: false,
  tile: null
};
let travelAnimationLocked = false;
let placePanelMode = {
  key: "",
  view: "default"
};
let currentAttitude = api.attitude ? api.attitude() : "cautious";
let mainViewMode = "map";
let authoredNarrativeState = {
  key: "",
  loading: false,
  title: "",
  text: "",
  error: ""
};
let companionRegistryState = {
  query: "",
  loading: false,
  text: "Search a kind like reindeer to see names and owners.",
  error: ""
};
let avatarState = loadAvatarState();
let avatarPointerDown = false;
let currentPlayerSpriteUrl = PLAYER_SPRITE_IMAGE;
let avatarLoadedAppearance16 = "";
let avatarDirty = false;
let playerCommandState = {
  title: "Player Command",
  text: ""
};
let mailCommandState = {
  title: "Message Command",
  text: ""
};
let adenaState = {
  available: APP_MODE === "hosted" && typeof window !== "undefined" && !!window.adena,
  connecting: false,
  connected: false,
  uploading: false,
  address: "",
  nickname: "",
  error: "",
  lastTxHash: ""
};
let mailComposerState = {
  to: "",
  body: ""
};

function loadTileLabelsPreference() {
  try {
    const saved = localStorage.getItem(TILE_LABELS_STORAGE_KEY);
    return saved === null ? true : saved !== "false";
  } catch (err) {
    return true;
  }
}

function inferAppMode() {
  if (typeof window === "undefined") {
    return "hosted";
  }
  const host = String(window.location?.hostname || "").toLowerCase();
  if (!host || host === "localhost" || host === "127.0.0.1" || host === "::1") {
    return "local";
  }
  return "hosted";
}

const REALM_PKG_PATH = APP_MODE === "local" ? LOCAL_REALM_PKG_PATH : HOSTED_REALM_PKG_PATH;

function saveTileLabelsPreference(value) {
  try {
    localStorage.setItem(TILE_LABELS_STORAGE_KEY, value ? "true" : "false");
  } catch (err) {
    // Ignore storage failures and keep the in-memory value.
  }
}

function fogRevealStorageKey(playerName) {
  return `${FOG_REVEAL_STORAGE_KEY_PREFIX}:${String(playerName || "").trim().toLowerCase() || "nisse"}`;
}

function fogLastPositionStorageKey(playerName) {
  return `${FOG_LAST_POSITION_STORAGE_KEY_PREFIX}:${String(playerName || "").trim().toLowerCase() || "nisse"}`;
}

function loadRevealedTiles(playerName) {
  try {
    const raw = localStorage.getItem(fogRevealStorageKey(playerName));
    const parsed = raw ? JSON.parse(raw) : [];
    return new Set(Array.isArray(parsed) ? parsed.map((value) => String(value || "")) : []);
  } catch (err) {
    return new Set();
  }
}

function saveRevealedTiles(playerName, revealed) {
  try {
    localStorage.setItem(fogRevealStorageKey(playerName), JSON.stringify(Array.from(revealed)));
  } catch (err) {
    // Ignore storage failures and keep the in-memory map usable.
  }
}

function loadLastFogPosition(playerName) {
  try {
    const raw = localStorage.getItem(fogLastPositionStorageKey(playerName));
    const parsed = raw ? JSON.parse(raw) : null;
    if (!parsed || !Number.isFinite(parsed.x) || !Number.isFinite(parsed.y)) {
      return null;
    }
    return { x: Number(parsed.x), y: Number(parsed.y) };
  } catch (err) {
    return null;
  }
}

function saveLastFogPosition(playerName, pos) {
  if (!pos) {
    return;
  }
  try {
    localStorage.setItem(fogLastPositionStorageKey(playerName), JSON.stringify({
      x: Number(pos.x),
      y: Number(pos.y)
    }));
  } catch (err) {
    // Ignore storage failures and keep the in-memory map usable.
  }
}

function revealAroundPosition(revealed, map, pos) {
  if (!Array.isArray(map) || !pos) {
    return revealed;
  }

  const next = new Set(revealed);
  for (let dy = -1; dy <= 1; dy += 1) {
    for (let dx = -1; dx <= 1; dx += 1) {
      const x = Number(pos.x) + dx;
      const y = Number(pos.y) + dy;
      if (y < 0 || y >= map.length || x < 0 || x >= (map[y]?.length || 0)) {
        continue;
      }
      next.add(`${x},${y}`);
    }
  }
  return next;
}

function revealPathWithNeighbors(revealed, map, path) {
  let next = new Set(revealed);
  for (const step of path || []) {
    next = revealAroundPosition(next, map, step);
  }
  return next;
}

function applyFogOfWar(state) {
  if (!state || !Array.isArray(state.map) || !state.player?.position) {
    return state;
  }

  const playerName = state.player?.name || "nisse";
  const playerPos = state.player.position;
  const loaded = loadRevealedTiles(playerName);
  const lastPos = loadLastFogPosition(playerName);
  let revealed = new Set(loaded);

  if (lastPos && !sameTile(lastPos, playerPos)) {
    const previousTile = tileAt(state.map, lastPos.x, lastPos.y);
    const currentTile = tileAt(state.map, playerPos.x, playerPos.y);
    const useBoat = !!state.player?.ownsBoat
      && !!previousTile
      && !!currentTile
      && waterTravelTile(previousTile.code)
      && waterTravelTile(currentTile.code);
    const path = shortestTravelPath(state.map, lastPos, playerPos, { useBoat });
    revealed = revealPathWithNeighbors(revealed, state.map, path.length ? path : [lastPos, playerPos]);
  }

  revealed = revealAroundPosition(revealed, state.map, playerPos);

  if (revealed.size !== loaded.size) {
    saveRevealedTiles(playerName, revealed);
  }
  saveLastFogPosition(playerName, playerPos);

  const map = state.map.map((row) =>
    row.map((tile) => {
      const isVisible = revealed.has(`${tile.x},${tile.y}`);
      return {
        ...tile,
        isVisible,
        activeStory: isVisible ? tile.activeStory : null
      };
    })
  );

  if (FOG_DEBUG && typeof console !== "undefined") {
    const totalTiles = map.reduce((sum, row) => sum + row.length, 0);
    const visibleTiles = map.reduce(
      (sum, row) => sum + row.filter((tile) => tile.isVisible).length,
      0
    );
    console.log("[fog]", {
      playerName,
      storageKey: fogRevealStorageKey(playerName),
      position: playerPos,
      revealedCount: revealed.size,
      visibleTiles,
      totalTiles,
      sample: Array.from(revealed).slice(0, 20)
    });
    if (typeof window !== "undefined") {
      window.__nisseFogDebug = {
        playerName,
        storageKey: fogRevealStorageKey(playerName),
        position: playerPos,
        revealed: Array.from(revealed),
        visibleTiles,
        totalTiles
      };
    }
  }

  return {
    ...state,
    map
  };
}

function setUiState(nextState) {
  store.setState(applyFogOfWar(nextState));
}

function defaultAvatarPixels() {
  return new Array(AVATAR_SIZE * AVATAR_SIZE).fill(0);
}

function loadAvatarState() {
  try {
    const raw = localStorage.getItem(AVATAR_STORAGE_KEY);
    const parsed = raw ? JSON.parse(raw) : null;
    const pixels = Array.isArray(parsed?.pixels) ? parsed.pixels.slice(0, AVATAR_SIZE * AVATAR_SIZE) : defaultAvatarPixels();
    while (pixels.length < AVATAR_SIZE * AVATAR_SIZE) {
      pixels.push(0);
    }
    return {
      pixels: pixels.map((value) => {
        const numeric = Number(value);
        return Number.isInteger(numeric) && numeric >= 0 && numeric < AVATAR_PALETTE.length ? numeric : 0;
      }),
      selected: Number.isInteger(parsed?.selected) && parsed.selected >= 0 && parsed.selected < AVATAR_PALETTE.length
        ? parsed.selected
        : 1
    };
  } catch (err) {
    return { pixels: defaultAvatarPixels(), selected: 1 };
  }
}

function emojiForCompanionList(companionList) {
  const first = String(companionList?.[0]?.species || companionList?.[0]?.name || "").toLowerCase();
  if (first.includes("dog")) return "🐕";
  if (first.includes("donkey")) return "🫏";
  if (first.includes("reindeer")) return "🦌";
  if (first.includes("mule")) return "🐴";
  return "🦄";
}

function emojiForMonsterMarks(monsterMarks) {
  const first = String(monsterMarks?.[0]?.kind || "").toLowerCase();
  if (first.includes("goblin")) return "👺";
  if (first.includes("dragon") || first.includes("drake")) return "🐉";
  if (first.includes("troll")) return "👹";
  if (first.includes("elf")) return "🧝";
  return "👹";
}

function persistAvatarState() {
  try {
    localStorage.setItem(AVATAR_STORAGE_KEY, JSON.stringify(avatarState));
  } catch (err) {
    // Ignore storage failures.
  }
}

function encodeAvatarPixels(pixels = []) {
  return pixels
    .slice(0, AVATAR_SIZE * AVATAR_SIZE)
    .map((value) => {
      const numeric = Number(value);
      const safe = Number.isInteger(numeric) && numeric >= 0 && numeric < 36 ? numeric : 0;
      return safe.toString(36);
    })
    .join("");
}

function decodeAppearance16(appearance16) {
  const source = String(appearance16 || "").trim().toLowerCase();
  if (!source || source === "none" || source.length !== AVATAR_SIZE * AVATAR_SIZE) {
    return null;
  }
  const pixels = [];
  for (let i = 0; i < source.length; i += 1) {
    const value = parseInt(source[i], 36);
    if (!Number.isInteger(value) || value < 0) {
      return null;
    }
    pixels.push(value < AVATAR_PALETTE.length ? value : 0);
  }
  return pixels;
}

function updateAvatarDirtyState() {
  avatarDirty = encodeAvatarPixels(avatarState.pixels) !== avatarLoadedAppearance16;
}

function avatarPixelIndex(x, y) {
  return y * AVATAR_SIZE + x;
}

function drawAvatarCanvas(canvas, showGrid = false) {
  if (!canvas) {
    return;
  }
  const context = canvas.getContext("2d");
  if (!context) {
    return;
  }
  const width = canvas.width;
  const height = canvas.height;
  const pixelWidth = width / AVATAR_SIZE;
  const pixelHeight = height / AVATAR_SIZE;
  context.clearRect(0, 0, width, height);
  for (let y = 0; y < AVATAR_SIZE; y += 1) {
    for (let x = 0; x < AVATAR_SIZE; x += 1) {
      const colorIndex = avatarState.pixels[avatarPixelIndex(x, y)] || 0;
      if (!colorIndex) {
        continue;
      }
      context.fillStyle = AVATAR_PALETTE[colorIndex];
      context.fillRect(x * pixelWidth, y * pixelHeight, pixelWidth, pixelHeight);
    }
  }
  if (!showGrid) {
    return;
  }
  context.strokeStyle = "rgba(76, 64, 42, 0.12)";
  context.lineWidth = 1;
  for (let line = 1; line < AVATAR_SIZE; line += 1) {
    const px = line * pixelWidth;
    const py = line * pixelHeight;
    context.beginPath();
    context.moveTo(px, 0);
    context.lineTo(px, height);
    context.stroke();
    context.beginPath();
    context.moveTo(0, py);
    context.lineTo(width, py);
    context.stroke();
  }
}

function avatarDataUrl() {
  const canvas = document.createElement("canvas");
  canvas.width = AVATAR_SIZE;
  canvas.height = AVATAR_SIZE;
  drawAvatarCanvas(canvas, false);
  return canvas.toDataURL("image/png");
}

function avatarDataUrlFromPixels(pixels) {
  const canvas = document.createElement("canvas");
  canvas.width = AVATAR_SIZE;
  canvas.height = AVATAR_SIZE;
  const context = canvas.getContext("2d");
  if (!context) {
    return PLAYER_SPRITE_IMAGE;
  }
  for (let y = 0; y < AVATAR_SIZE; y += 1) {
    for (let x = 0; x < AVATAR_SIZE; x += 1) {
      const colorIndex = pixels[avatarPixelIndex(x, y)] || 0;
      if (!colorIndex || !AVATAR_PALETTE[colorIndex]) {
        continue;
      }
      context.fillStyle = AVATAR_PALETTE[colorIndex];
      context.fillRect(x, y, 1, 1);
    }
  }
  return canvas.toDataURL("image/png");
}

function applyAvatarSprite() {
  currentPlayerSpriteUrl = avatarState.pixels.some((value) => value !== 0)
    ? avatarDataUrl()
    : PLAYER_SPRITE_IMAGE;
  const marker = mapRoot.querySelector(".map-player-marker");
  if (marker) {
    marker.style.setProperty("--player-sprite-url", `url('${currentPlayerSpriteUrl}')`);
  }
}

function renderAvatarPalette() {
  if (!avatarPalette) {
    return;
  }
  avatarPalette.innerHTML = AVATAR_PALETTE.map((color, index) => {
    const classes = ["avatar-swatch"];
    if (index === avatarState.selected) {
      classes.push("is-active");
    }
    if (index === 0) {
      classes.push("avatar-swatch--transparent");
    }
    return `<button type="button" class="${classes.join(" ")}" data-avatar-color="${index}" aria-label="Avatar color ${index + 1}"${index === 0 ? "" : ` style="background:${color}"`}></button>`;
  }).join("");
}

function renderAvatarEditor() {
  drawAvatarCanvas(avatarPreview, false);
  drawAvatarCanvas(avatarEditor, true);
  renderAvatarPalette();
  applyAvatarSprite();
}

function avatarCoordsFromPointer(event) {
  if (!avatarEditor) {
    return null;
  }
  const box = avatarEditor.getBoundingClientRect();
  if (!box.width || !box.height) {
    return null;
  }
  return {
    x: Math.max(0, Math.min(AVATAR_SIZE - 1, Math.floor(((event.clientX - box.left) / box.width) * AVATAR_SIZE))),
    y: Math.max(0, Math.min(AVATAR_SIZE - 1, Math.floor(((event.clientY - box.top) / box.height) * AVATAR_SIZE)))
  };
}

function paintAvatarFromPointer(event) {
  const point = avatarCoordsFromPointer(event);
  if (!point) {
    return;
  }
  avatarState.pixels[avatarPixelIndex(point.x, point.y)] = avatarState.selected;
  updateAvatarDirtyState();
  renderAvatarEditor();
}

function syncAvatarFromChain(player) {
  const chainAppearance = String(player?.appearance16 || "").toLowerCase();
  const draftAppearance = avatarState.pixels.some((value) => value !== 0)
    ? encodeAvatarPixels(avatarState.pixels)
    : "";
  if (chainAppearance && chainAppearance === avatarLoadedAppearance16) {
    avatarDirty = false;
    return;
  }
  if (avatarDirty) {
    if (chainAppearance === draftAppearance) {
      avatarLoadedAppearance16 = chainAppearance;
      avatarDirty = false;
    }
    return;
  }
  const pixels = decodeAppearance16(chainAppearance);
  if (!pixels) {
    if (!chainAppearance) {
      avatarState.pixels = defaultAvatarPixels();
      avatarLoadedAppearance16 = "";
      avatarDirty = false;
      persistAvatarState();
      renderAvatarEditor();
    }
    return;
  }
  avatarState.pixels = pixels;
  avatarLoadedAppearance16 = chainAppearance;
  avatarDirty = false;
  persistAvatarState();
  renderAvatarEditor();
}

function spriteUrlFromAppearance16(appearance16) {
  const pixels = decodeAppearance16(appearance16);
  return pixels ? avatarDataUrlFromPixels(pixels) : PLAYER_SPRITE_IMAGE;
}

function errorState(message) {
  return {
    player: {
      name: "Unavailable",
      position: { x: 0, y: 0 },
      pearls: 0,
      level: 0,
      travelBonus: 0
    },
    map: [],
    place: {
      title: "Connection problem",
      placeName: "",
      theme: "city",
      text: message,
      image: "/stories/fallback/images/themes/city.svg",
      fallbackImage: "/stories/fallback/images/themes/city.svg",
      canName: false,
      terrain: "unknown",
      x: 0,
      y: 0
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

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function renderNarrativeText(text, extras = {}) {
  const source = String(text || "");
  const state = store.getState();
  const player = state?.player || {};
  const place = state?.place || {};
  const baseContext = {
    playerName: player.name || "",
    name: place.placeName || place.title || place.terrain || "",
    place: place.title || place.placeName || place.terrain || "",
    companionName: extras.companionName || "",
    attitude: currentAttitude || ""
  };
  if (window.NisseStoryRunner?.interpolateStoryText) {
    return window.NisseStoryRunner.interpolateStoryText(source, baseContext);
  }
  return source;
}

function narrativeHtmlFromText(text) {
  return escapeHtml(String(text || "")).replace(/\n/g, "<br>");
}

function setPlaceTextStory(title, body, aftermath = []) {
  const safeTitle = escapeHtml(String(title || "Story"));
  const safeBody = narrativeHtmlFromText(body || "");
  const safeAftermath = aftermath
    .filter(Boolean)
    .map((line) => `<div class="story-aftermath-line">${escapeHtml(String(line))}</div>`)
    .join("");

  placeText.innerHTML =
    `<div class="story-reading">` +
    `<div class="story-reading-title">${safeTitle}</div>` +
    `<div class="story-reading-body">${safeBody}</div>` +
    (safeAftermath
      ? `<div class="story-aftermath">${safeAftermath}</div>`
      : ``) +
    `</div>`;
}

function renderCompanionRegistryBox() {
  if (!companionRegistryResult) {
    return;
  }
  if (companionRegistryInput && document.activeElement !== companionRegistryInput) {
    companionRegistryInput.value = companionRegistryState.query || "";
  }
  if (companionRegistryButton) {
    companionRegistryButton.disabled = companionRegistryState.loading;
    companionRegistryButton.textContent = companionRegistryState.loading ? "Searching..." : "Search Companions";
  }
  companionRegistryResult.textContent = companionRegistryState.error || companionRegistryState.text;
}

function renderFrensBox(state) {
  if (!frensResult) {
    return;
  }
  const loads = state?.loads || { active: false, total: 0 };
  const frens = state?.frens || { active: false, query: "", entries: [], missing: [] };
  if (frensInput && document.activeElement !== frensInput) {
    frensInput.value = frens.query || "";
  }
  const lines = [];
  lines.push(loads.active ? `Loads active: ${Number(loads.total || 0)} living players seen.` : "Loads inactive.");
  if (frens.active) {
    lines.push(frens.entries.length ? `Frens active: ${frens.entries.length} found.` : "Frens active: none found.");
    for (const fren of frens.entries) {
      lines.push(`- ${fren.name} @ (${fren.position.x}, ${fren.position.y})`);
    }
    if (frens.missing?.length) {
      lines.push(`Missing: ${frens.missing.join(", ")}`);
    }
  } else {
    lines.push("Frens inactive.");
  }
  frensResult.textContent = lines.join("\n");
}

function adenaData(payload) {
  return payload?.data ?? payload ?? {};
}

function adenaAddress(payload) {
  const data = adenaData(payload);
  return String(
    data.address ||
    data.bech32Address ||
    data.accountAddress ||
    data.base?.address ||
    ""
  ).trim();
}

function adenaNickname(payload) {
  const data = adenaData(payload);
  return String(data.name || data.nickname || data.keyName || "").trim();
}

function shellQuote(value) {
  return "'" + String(value).replace(/'/g, "'\\''") + "'";
}

function stagingChainId() {
  const value = document.querySelector('meta[name="gnoconnect:chainid"]')?.getAttribute("content") || "";
  return String(value).trim() || "staging";
}

function stagingRpcHost() {
  const value = document.querySelector('meta[name="gnoconnect:rpc"]')?.getAttribute("content") || "";
  try {
    const parsed = new URL(String(value).trim());
    return parsed.host || "rpc.gno.land:443";
  } catch (err) {
    return String(value).replace(/^https?:\/\//, "").replace(/\/+$/, "") || "rpc.gno.land:443";
  }
}

async function loadNissePackageManifest(manifestPath = STAGING_DEPLOY_MANIFEST_PATH) {
  const response = await fetch(new URL(manifestPath, document.baseURI), { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`Package manifest HTTP ${response.status}`);
  }
  return {
    manifest: await response.json()
  };
}

async function buildHostedPackageCliCommand() {
  const { manifest } = await loadNissePackageManifest(STAGING_DEPLOY_MANIFEST_PATH);
  const keyName = String(identityKeyName?.value || adenaState.nickname || "mykey").trim() || "mykey";
  const pkgPath = String(manifest.path || HOSTED_REALM_PKG_PATH).trim();
  const pkgDir = `./${pkgPath}`;
  const gasFee = `${Number(manifest.gasFee || 8000000)}ugnot`;
  const gasWanted = `${Number(manifest.gasWanted || 120000000)}`;
  const maxDeposit = String(manifest.deposit || "1ugnot").trim() || "1ugnot";
  const command = [
    "gnokey maketx addpkg",
    shellQuote(keyName),
    "--broadcast",
    "--chainid", shellQuote(stagingChainId()),
    "--remote", shellQuote(stagingRpcHost()),
    "--gas-fee", shellQuote(gasFee),
    "--gas-wanted", shellQuote(gasWanted),
    "--max-deposit", shellQuote(maxDeposit),
    "--pkgdir", shellQuote(pkgDir),
    "--pkgpath", shellQuote(pkgPath)
  ].join(" ");
  return [
    "# Run from your local nisserealm checkout",
    "cd /path/to/local/nisserealm",
    command
  ].join("\n");
}

async function connectAdenaWallet() {
  if (!window.adena) {
    throw new Error("Adena extension was not found in this browser.");
  }
  adenaState = {
    ...adenaState,
    available: true,
    connecting: true,
    error: ""
  };
  render(store.getState());

  let established;
  try {
    established = await window.adena.AddEstablish("Nisse Realm");
  } catch (err) {
    established = null;
  }

  if (established && adenaAddress(established)) {
    adenaState = {
      ...adenaState,
      connecting: false,
      connected: true,
      address: adenaAddress(established),
      nickname: adenaNickname(established),
      error: ""
    };
    render(store.getState());
    return established;
  }

  const account = await window.adena.GetAccount();
  const address = adenaAddress(account);
  if (!address) {
    throw new Error("Adena connected but did not return an address.");
  }
  adenaState = {
    ...adenaState,
    connecting: false,
    connected: true,
    address,
    nickname: adenaNickname(account),
    error: ""
  };
  render(store.getState());
  return account;
}

async function sendWithAdena({ messages, gasWanted, gasFee, memo = "", address = "" }) {
  if (!window.adena) {
    throw new Error("Adena extension was not found in this browser.");
  }
  if (!Array.isArray(messages) || !messages.length) {
    throw new Error("Adena send requires at least one message.");
  }

  const sender = String(address || adenaState.address || "").trim();
  if (!sender) {
    throw new Error("No connected Adena address is available.");
  }

  const payload = {
    tx: {
      messages,
      memo: String(memo || "")
    },
    messages,
    gasFee: Number(gasFee),
    gasWanted: Number(gasWanted),
    memo: String(memo || ""),
    isNotification: true
  };

  return window.adena.DoContract(payload);
}

function canUseAdenaWrites() {
  return APP_MODE === "hosted" && typeof window !== "undefined" && !!window.adena;
}

async function ensureAdenaReady() {
  if (!window.adena) {
    throw new Error("Adena extension was not found in this browser.");
  }
  if (!adenaState.connected) {
    await connectAdenaWallet();
  }
  const address = String(adenaState.address || "").trim();
  if (!address) {
    throw new Error("No connected Adena address is available.");
  }
  return address;
}

async function callRealmWithAdena(func, args = [], { send = "", memo = "" } = {}) {
  const sender = await ensureAdenaReady();
  const response = await sendWithAdena({
    address: sender,
    messages: [
      {
        type: "/vm.m_call",
        value: {
          caller: sender,
          send: String(send || ""),
          pkg_path: REALM_PKG_PATH,
          func: String(func || ""),
          args: Array.isArray(args) ? args.map((value) => String(value)) : []
        }
      }
    ],
    gasWanted: Number(DEFAULT_GAS_WANTED),
    gasFee: DEFAULT_GAS_FEE,
    memo
  });
  const txHash = String(response?.data?.hash || response?.data?.txHash || response?.txHash || response?.hash || "").trim();
  pushLogMessage(`${func} sent with Adena.${txHash ? `\n${txHash}` : ""}`);
  try {
    const nextState = await api.refresh();
    setUiState(nextState);
  } catch (err) {
    pushLogMessage("Adena write succeeded, but readonly refresh is unavailable right now.");
  }
  return response;
}

async function handleRealmCallAction({ func, args = [], memo = "", send = "", fallback = null, overlay = null, switchView = "" }) {
  if (!canUseAdenaWrites()) {
    if (fallback) {
      await runAction(fallback);
      const command = latestCliCommand(store.getState());
      if (overlay === "player") {
        setPlayerCommandOverlay(func, command || "No command is available.");
      } else if (overlay === "mail") {
        setMailCommandOverlay(func, command || "No command is available.");
      }
    }
    if (switchView) {
      setMainViewMode(switchView);
    }
    return;
  }

  try {
    await callRealmWithAdena(func, args, { send, memo });
    if (overlay === "player") {
      clearPlayerCommandOverlay();
    } else if (overlay === "mail") {
      clearMailCommandOverlay();
    }
  } catch (err) {
    const message = err?.message || String(err);
    pushLogMessage(message);
    if (overlay === "player") {
      setPlayerCommandOverlay(func, message);
    } else if (overlay === "mail") {
      setMailCommandOverlay(func, message);
    }
  }
  if (switchView) {
    setMainViewMode(switchView);
  }
}

function renderAdenaDeployBox() {
  const adenaBox = adenaDeployResult?.closest(".companion-registry-box");
  if (APP_MODE !== "hosted") {
    adenaBox?.classList.add("hidden");
    return;
  }
  if (!adenaDeployResult) {
    return;
  }
  adenaBox?.classList.remove("hidden");
  const lines = [];
  if (!adenaState.available) {
    lines.push("Adena not detected in this browser.");
  } else if (adenaState.connected) {
    lines.push(`Connected: ${adenaState.nickname || "wallet"}`);
    lines.push(`Address: ${adenaState.address}`);
  } else {
    lines.push("Adena is available but not connected yet.");
  }
  lines.push("");
  lines.push("Package deploy uses a local CLI command now.");
  lines.push(`Path: ${HOSTED_REALM_PKG_PATH}`);
  lines.push(`RPC: ${stagingRpcHost()}`);
  if (adenaState.error) {
    lines.push("");
    lines.push(`Error: ${adenaState.error}`);
  }
  adenaDeployResult.textContent = lines.join("\n");
  if (adenaConnectButton) {
    adenaConnectButton.disabled = adenaState.connecting || adenaState.uploading;
    adenaConnectButton.textContent = adenaState.connecting ? "Connecting..." : "Connect Adena";
  }
  if (adenaUploadPackageButton) {
    adenaUploadPackageButton.disabled = adenaState.connecting;
    adenaUploadPackageButton.textContent = "Stage Upload CLI";
  }
}

function renderMailBox(state) {
  if (messageToInput && document.activeElement !== messageToInput) {
    messageToInput.value = mailComposerState.to || "";
  }
  if (messageBodyInput && document.activeElement !== messageBodyInput) {
    messageBodyInput.value = mailComposerState.body || "";
  }

  const mailbox = state?.mailbox || { messages: [], latest: null };

  if (messageInboxResult) {
    const lines = [];
    if (mailbox.latest) {
      lines.push(`Latest from ${mailbox.latest.from} at turn ${mailbox.latest.turn}:`);
      lines.push(mailbox.latest.body || "(empty)");
      lines.push("");
    }
    if (!mailbox.messages?.length) {
      lines.push("No messages yet.");
    } else {
      lines.push("Inbox:");
      for (const message of mailbox.messages.slice().reverse()) {
        lines.push(`#${message.id} from ${message.from}`);
        lines.push(message.body || "(empty)");
        lines.push("");
      }
    }
    messageInboxResult.textContent = lines.join("\n").trim() || "No messages yet.";
  }

}

function storyOutcomeKey(tier) {
  return Number(tier) > 0 ? "success" : "failure";
}

function authoredStoryAttitude(storyId, pathCode, fallbackAttitude = currentAttitude) {
  const normalizedStoryId = String(storyId || "").toLowerCase();
  const normalizedPath = window.NisseStoryRunner
    ? window.NisseStoryRunner.normalizeStoryPathCode(pathCode)
    : String(pathCode || "").replace(/\D+/g, "");
  if (normalizedStoryId === "reindeer") {
    if (normalizedPath === "121") {
      return "kind";
    }
    if (normalizedPath === "13") {
      return "bold";
    }
    if (normalizedPath === "12") {
      return "cautious";
    }
  }
  return String(fallbackAttitude || "cautious").toLowerCase();
}

function authoredStoryFilePath(storyId, resourcePath, attitude) {
  const normalizedStoryId = String(storyId || "").toLowerCase();
  const normalizedAttitude = String(attitude || "cautious").toLowerCase();
  if (resourcePath) {
    const normalizedResourcePath = resourcePath.startsWith("/") ? resourcePath : `/${resourcePath}`;
    const slashIndex = normalizedResourcePath.lastIndexOf("/");
    const base = slashIndex >= 0 ? normalizedResourcePath.slice(0, slashIndex + 1) : "/";
    return `${base}${normalizedAttitude}.story.md`;
  }
  return `/stories/${normalizedStoryId}/${normalizedAttitude}.story.md`;
}

function authoredNarrativeRequest(result, place, fallbackAttitude = currentAttitude) {
  if (!result || !window.NisseStoryRunner) {
    return null;
  }
  if (Number(result.outcomeTier || 0) <= 0) {
    return null;
  }
  const storyId = String(result.storyId || place?.story?.id || "").toLowerCase();
  if (!storyId) {
    return null;
  }
  const attitude = authoredStoryAttitude(storyId, result.pathCode, fallbackAttitude);
  const outcome = storyOutcomeKey(result.outcomeTier);
  const resourcePath = place?.story?.path || `/stories/${storyId}/story.json`;
  return {
    key: `${storyId}:${attitude}:${outcome}`,
    storyId,
    attitude,
    outcome,
    filePath: authoredStoryFilePath(storyId, resourcePath, attitude),
    companionName: result.grantedCompanion || ""
  };
}

function authoredNarrativeText(request) {
  if (!request || authoredNarrativeState.key !== request.key) {
    return "";
  }
  return authoredNarrativeState.text || "";
}

function authoredNarrativeTitle(request) {
  if (!request || authoredNarrativeState.key !== request.key) {
    return "";
  }
  return authoredNarrativeState.title || "";
}

function ensureAuthoredNarrative(request) {
  if (!request || !window.NisseStoryRunner?.loadTaggedStoryResource) {
    if (authoredNarrativeState.key) {
      authoredNarrativeState = {
        key: "",
        loading: false,
        title: "",
        text: "",
        error: ""
      };
    }
    return;
  }
  if (authoredNarrativeState.key === request.key && (authoredNarrativeState.loading || authoredNarrativeState.text || authoredNarrativeState.error)) {
    return;
  }

  authoredNarrativeState = {
    key: request.key,
    loading: true,
    title: "",
    text: "",
    error: ""
  };

  window.NisseStoryRunner.loadTaggedStoryResource(request.filePath)
    .then((record) => {
      if (authoredNarrativeState.key !== request.key) {
        return;
      }
      const sections = record?.sections || {};
      const text = sections.body || "";
      authoredNarrativeState = {
        key: request.key,
        loading: false,
        title: String(record?.meta?.title || "").trim(),
        text: String(text || "").trim(),
        error: ""
      };
      render(store.getState());
    })
    .catch((err) => {
      if (authoredNarrativeState.key !== request.key) {
        return;
      }
      authoredNarrativeState = {
        key: request.key,
        loading: false,
        title: "",
        text: "",
        error: err?.message || String(err)
      };
      render(store.getState());
    });
}

function placePanelKey(place) {
  if (!place) {
    return "";
  }
  return `${place.terrain}:${place.x},${place.y}`;
}

function syncPlacePanelMode(place) {
  const key = placePanelKey(place);
  if (placePanelMode.key !== key) {
    placePanelMode = {
      key,
      view: "default"
    };
  }
}

function isCityPlace(place) {
  return !!place && (place.terrain === "city_north" || place.terrain === "city_south");
}

function cityServiceEntries(place) {
  const south = place?.terrain === "city_south";
  return [
    {
      key: "scroll-seller",
      title: "Scrolls and Wisdom",
      summary: "Old books, copied sayings, brittle scrolls, and useful fragments of learning.",
      hint: "This will become the book and wisdom market paid in pearls."
    },
    {
      key: "boat-trips",
      title: "Boat Trips",
      summary: south
        ? "Harbor men and small captains offering passage, rumors, and coastal movement."
        : "Northern boatmen and lake-road sailors offering routes, passage, and local word.",
      hint: "This will guide sailing, routes, and hired movement later."
    }
  ];
}

function placeFeatureEntries(place, player) {
  if (!place) {
    return [];
  }

  const terrain = String(place.terrain || "");
  const entries = [];
  const addEntry = (key, title, summary, hint = "") => {
    entries.push({ key, title, summary, hint });
  };

  if (["moor", "meadow", "forest", "hills", "mountain", "farm", "coastal", "fishing_village", "mountain_village", "monastery"].includes(terrain)) {
    addEntry(
      "adventure",
      "Chance of Adventure",
      "Exploring here may surface a local encounter, a passing creature, or a place-specific event when the tile is not quiet.",
      "This is where future active adventures will surface first."
    );
  }
  if (terrain !== "ocean") {
    addEntry(
      "search",
      "Search the Place",
      "A closer look can turn up traces, rumors, loose coin, clues, or small signs that tell you more about the land.",
      "Search is still available underneath, even though the panel now enters through Explore."
    );
  }
  if (["forest", "moor", "meadow", "hills", "mountain", "farm", "monastery"].includes(terrain)) {
    addEntry(
      "companion",
      "Companion Signs",
      "Quiet places hold tracks, calls, and moments that connect to your companions and future companion growth.",
      "Best suited to calmer inland tiles."
    );
  }
  if (["coastal", "fishing_village"].includes(terrain) || player?.carriesBoat) {
    addEntry(
      "boat",
      "Boat Edge",
      terrain === "fishing_village" && !player?.ownsBoat
        ? "Fishing villages always keep a weathered skiff for sale. One boat costs 1 pearl and carries you for 8 paces of water travel."
        : "The shore can lead into boat travel, dropped boats, carried boats, and coastal passage.",
      terrain === "fishing_village" && !player?.ownsBoat
        ? "Buy once, then carry it until you head inland from a coastal tile."
        : "Useful on coast-facing places and whenever you already carry a boat."
    );
  }
  if (["fishing_village", "mountain_village"].includes(terrain)) {
    addEntry(
      "village-life",
      "Village Life",
      "These places may support nearby hints, gossip, and local practical help as the village systems deepen.",
      "A quieter service layer than the city."
    );
  }
  if (terrain === "monastery") {
    addEntry(
      "pages",
      "Pages and Entries",
      "Monastery spaces are suited to written memory, old sayings, and reflective entries that tie into books and diary systems.",
      "A natural home for wisdom and written fragments."
    );
  }
  if (place.canName) {
    addEntry(
      "name",
      "Naming the Place",
      "This frontier tile can still be given its first lasting name.",
      "Once named, it becomes part of the world’s shared memory."
    );
  }

  return entries;
}

function placeImageForDisplay(place) {
  if (!place) {
    return "";
  }
  const map = store.getState()?.map || [];
  const textureVariant = coastalTextureVariant(map, place.x, place.y);
  if (textureVariant === "coastal-sea-down") {
    return `${PLACE_TILE_ASSET_BASE}/coastal_seadown.png`;
  }
  if (textureVariant === "coastal-sea-up") {
    return `${PLACE_TILE_ASSET_BASE}/coastal_seaup.png`;
  }
  const tileLikeImage = tileTextureOverride({
    x: place.x,
    y: place.y,
    terrain: place.terrain,
    code: -1
  }, PLACE_TILE_ASSET_BASE) || PLACE_TERRAIN_IMAGES[place.terrain];
  return tileLikeImage || place.image || place.fallbackImage || "";
}

function placeImageFallback(place) {
  if (!place) {
    return "";
  }
  return PLACE_TERRAIN_IMAGES[place.terrain] || place.image || place.fallbackImage || "";
}

function storyOutcomeLabel(tier, result) {
  if (/knows you/i.test(String(result?.title || ""))) {
    return "Known";
  }
  const value = Number(tier) || 0;
  if (value >= 3) {
    return "Exceptional";
  }
  return value > 0 ? "Success" : "Failure";
}

function storyAftermathLines(result) {
  if (!result) {
    return [];
  }
  const lines = [];
  lines.push(`Outcome: ${storyOutcomeLabel(result.outcomeTier, result)}`);
  if (result.title) {
    lines.push(`Result: ${result.title}`);
  }
  if (Number(result.levelGain || 0) > 0) {
    lines.push(`Level gained: +${result.levelGain}`);
  }
  if (result.grantedCompanion) {
    lines.push(`Companion acquired: ${result.grantedCompanion}`);
  }
  return lines;
}

function storyMissedMessage(place) {
  const title = String(place?.story?.title || "This encounter").trim();
  return `${title} was active here, but you missed it.\n\nThe signs were there for a traveler in the right step of mind, but this time the path closed before it became yours.`;
}

function isArrivalStory(place) {
  return !!place?.story;
}

function currentArrivalResult(state, place) {
  const result = state?.storyResult;
  if (!place || !isArrivalStory(place) || !result) {
    return null;
  }
  if (String(result.storyId || "").toLowerCase() !== String(place.story.id || "").toLowerCase()) {
    return null;
  }
  if (Number(result.turn || 0) !== Number(state?.player?.turns || -1)) {
    return null;
  }
  return result;
}

function renderAttitudeButton() {
  const buttons = [
    ["cautious", attitudeCautiousButton],
    ["kind", attitudeKindButton],
    ["bold", attitudeBoldButton]
  ];
  for (const [attitude, button] of buttons) {
    if (!button) {
      continue;
    }
    const active = currentAttitude === attitude;
    button.setAttribute("aria-pressed", active ? "true" : "false");
    button.classList.toggle("attitude-button-active", active);
    button.classList.toggle(`attitude-button--${attitude}`, active);
  }
}

function pushLogMessage(message) {
  const current = store.getState();
  if (!current) {
    return;
  }
  store.setState({
    ...current,
    log: [message, ...(current.log || [])].slice(0, 24)
  });
}

function availableActionsForPlace(place, player) {
  if (!place) {
    return [];
  }

  const actions = ["explore"];
  const terrain = String(place.terrain || "");
  const cityLike = terrain === "city_north" || terrain === "city_south";
  const villageLike = terrain === "fishing_village" || terrain === "mountain_village" || terrain === "village";
  const monasteryLike = terrain === "monastery";
  const shoreLike = terrain === "coastal" || terrain === "fishing_village" || cityLike;
  const landLike = terrain !== "ocean";
  const wildLike = ["moor", "meadow", "forest", "hills", "mountain", "farm"].includes(terrain);

  if (cityLike) {
    return ["explore"];
  }
  if (landLike) {
    actions.push("search", "adventure");
  }
  if (shoreLike || player?.carriesBoat) {
    actions.push("boat");
  }
  if (cityLike || villageLike) {
    actions.push("services");
  }
  if (monasteryLike) {
    actions.push("pages", "entry");
  }
  if (cityLike) {
    actions.push("messages", "mail", "pearls", "ugnot", "players");
  }
  if (villageLike) {
    actions.push("nearby");
  }
  if (wildLike || monasteryLike) {
    actions.push("companion");
  }
  if (place.canName) {
    actions.push("nametile");
  }

  return [...new Set(actions)];
}

function renderPlaceActions(place, player) {
  if (!placeActions) {
    return;
  }
  const exploring = placePanelMode.view === "explore";
  const activeStory = place?.story;
  const arrivalResult = currentArrivalResult(store.getState(), place);
  if (isCityPlace(place)) {
    if (exploring) {
      const services = cityServiceEntries(place);
      placeActions.innerHTML =
        `<div class="place-actions-title">City Services</div>` +
        `<div class="place-actions-list place-actions-list--stack">` +
        `<button type="button" class="place-primary-button" data-place-action="place-back">Back to Place</button>` +
        services.map((service) =>
          `<button type="button" class="city-service-card" data-city-service="${escapeHtml(service.key)}">` +
          `<span class="city-service-title">${escapeHtml(service.title)}</span>` +
          `<span class="city-service-summary">${escapeHtml(service.summary)}</span>` +
          `<span class="city-service-hint">${escapeHtml(service.hint)}</span>` +
          `</button>`
        ).join("") +
        `</div>`;
      return;
    }

    placeActions.innerHTML =
      `<div class="place-actions-title">Available Here</div>` +
      `<div class="place-actions-list place-actions-list--stack">` +
      `<button type="button" class="place-primary-button" data-place-action="place-explore">Explore</button>` +
      `<div class="place-action-note">Explore checks for active city adventures first. If none are active, it opens the city view with its stalls, sellers, and services.</div>` +
      `<div class="place-action-note">From here the city can lead into: adventure, city view, scrolls and wisdom, and boat trips.</div>` +
      `</div>`;
    return;
  }
  if (!exploring) {
    if (isArrivalStory(place)) {
      placeActions.innerHTML =
        `<div class="place-actions-title">Active Here</div>` +
        `<div class="place-actions-list place-actions-list--stack">` +
        `<button type="button" class="place-primary-button" data-place-action="place-explore">Explore</button>` +
        `<div class="place-action-note">${escapeHtml(place.story?.title || "An arrival encounter")} is active on this tile right now.</div>` +
        `<div class="place-action-note">Open Explore to see the encounter panel. Then travel into the tile with Cautious, Kind, or Bold attitude to resolve it on arrival.</div>` +
        `</div>`;
      return;
    }
    placeActions.innerHTML =
      `<div class="place-actions-title">Available Here</div>` +
      `<div class="place-actions-list place-actions-list--stack">` +
      `<button type="button" class="place-primary-button" data-place-action="place-explore">Explore</button>` +
      `<div class="place-action-note">Explore checks whether this place is carrying an active adventure. If nothing is active, it opens the quiet place view and tells you what this tile is good for.</div>` +
      `</div>`;
    return;
  }

  if (isArrivalStory(place)) {
    const companionCount = Number(player?.companions || 0);
    placeActions.innerHTML =
      `<div class="place-actions-title">Arrival Encounter</div>` +
      `<div class="place-actions-list place-actions-list--stack">` +
      `<button type="button" class="place-primary-button" data-place-action="place-back">Back to Place</button>` +
      `<div class="place-action-note">This place resolves when you move into it. Your current travel attitude is ${escapeHtml(currentAttitude)}.</div>` +
      (companionCount >= 3
        ? `<div class="place-action-note">You already travel with ${escapeHtml(companionCount)} companions. Companion stories here will wait until you make room for another bond.</div>`
        : `<div class="place-action-note">These farm and highland companion encounters now use arrival resolution, not the old multi-choice story panel.</div>`) +
      (arrivalResult
        ? `<div class="story-preview-card">` +
          `<div><strong>${escapeHtml(arrivalResult.title || "Arrival result")}</strong></div>` +
          `<div>Outcome ${escapeHtml(storyOutcomeLabel(arrivalResult.outcomeTier))}</div>` +
          (Number(arrivalResult.levelGain || 0) > 0
            ? `<div>Level +${escapeHtml(arrivalResult.levelGain)}</div>`
            : ``) +
          (arrivalResult.grantedCompanion
            ? `<div>Companion gained: ${escapeHtml(arrivalResult.grantedCompanion)}</div>`
            : ``) +
          `</div>`
        : `<div class="place-action-note">Travel into this place with Cautious, Kind, or Bold attitude to resolve the encounter on arrival.</div>`) +
      `</div>`;
    return;
  }

  const features = placeFeatureEntries(place, player);
  const boatPurchase =
    place.terrain === "fishing_village"
      ? (player?.ownsBoat
        ? `<div class="place-action-note">You already own a boat. If you leave the coast for inland travel, it will be left behind on the last coastal tile until you return.</div>`
        : `<button type="button" class="place-primary-button" data-place-action="buy-boat">Buy Boat · 1 Pearl</button>` +
          `<div class="place-action-note">Fishing villages always have a skiff to sell. It becomes your boat, and it gives 8 paces of water travel.</div>`)
      : "";
  placeActions.innerHTML =
    `<div class="place-actions-title">Quiet Place View</div>` +
    `<div class="place-actions-list place-actions-list--stack">` +
    `<button type="button" class="place-primary-button" data-place-action="place-back">Back to Place</button>` +
    boatPurchase +
    `<div class="place-action-note">No active adventure is waiting on this tile right now. The place settles into its ordinary mood, and these are the threads it can lead into.</div>` +
    features.map((feature) =>
      `<div class="city-service-card city-service-card--static">` +
      `<span class="city-service-title">${escapeHtml(feature.title)}</span>` +
      `<span class="city-service-summary">${escapeHtml(feature.summary)}</span>` +
      (feature.hint ? `<span class="city-service-hint">${escapeHtml(feature.hint)}</span>` : "") +
      `</div>`
    ).join("") +
    `</div>`;
}

function tileLabel(tile, canShowOceanLabels) {
  if (tile.code === 0 && !canShowOceanLabels) {
    return "";
  }
  return `${tile.x},${tile.y}`;
}

function tileAt(map, x, y) {
  if (!Array.isArray(map) || y < 0 || y >= map.length || x < 0 || x >= map[y].length) {
    return null;
  }
  return map[y][x] || null;
}

function waterTravelTile(code) {
  return [0, 1, 8, 11, 13, 14].includes(Number(code));
}

function sameTile(a, b) {
  return !!a && !!b && a.x === b.x && a.y === b.y;
}

function oceanOrMapEdge(tile) {
  return !tile || tile.code === 0;
}

function coastalTextureVariant(map, x, y) {
  const tile = tileAt(map, x, y);
  if (!tile || tile.terrain !== "coastal") {
    return "";
  }

  const up = tileAt(map, x, y - 1);
  const down = tileAt(map, x, y + 1);
  const left = tileAt(map, x - 1, y);
  const right = tileAt(map, x + 1, y);

  const oceanUp = oceanOrMapEdge(up);
  const oceanDown = oceanOrMapEdge(down);
  const oceanLeft = oceanOrMapEdge(left);
  const oceanRight = oceanOrMapEdge(right);

  if (oceanUp && !oceanDown) {
    return "coastal-sea-up";
  }
  if (oceanDown && !oceanUp) {
    return "coastal-sea-down";
  }
  return "";
}

function tileTextureOverride(tile, assetBase = MAP_TILE_ASSET_BASE) {
  if (!tile || tile.code === 0) {
    return "";
  }
  const { x, y } = tile;
  const key = `${x},${y}`;
  switch (key) {
    case "12,3":
      return BENEVOLENT_MONASTERY_IMAGE;
    case "13,5":
      return `${assetBase}/melkern.png`;
    case "13,6":
      return `${assetBase}/minde.png`;
    case "1,3":
      return `${assetBase}/coastal_convex_NW.png`;
    case "1,4":
      return `${assetBase}/coastal_seawest.png`;
    case "1,5":
      return `${assetBase}/coastal_seawest.png`;
    case "1,6":
      return `${assetBase}/coastal_seawest.png`;
    case "2,3":
      return `${assetBase}/coastal_seaup.png`;
    case "2,7":
      return `${assetBase}/coastal_concave_SW.png`;
    case "3,2":
      return `${assetBase}/coastal_convex_NW.png`;
    case "3,3":
      return `${assetBase}/coastal_concave_NW.png`;
    case "5,1":
      return `${assetBase}/coastal_seaup_Wend.png`;
    case "10,1":
      return `${assetBase}/coastal_seaup.png`;
    case "10,7":
      return `${assetBase}/coastal_concave_SE.png`;
    case "14,1":
      return `${assetBase}/coastal_convex_NE.png`;
    case "15,5":
      return `${assetBase}/coastal_concave_SE.png`;
    case "14,2":
      return `${assetBase}/coastal_concave_NE.png`;
    case "15,2":
      return `${assetBase}/coastal_convex_NE.png`;
    case "16,3":
      return `${assetBase}/coastal_convex_NE.png`;
    case "16,4":
      return `${assetBase}/coastal_seaeast.png`;
    case "16,5":
      return `${assetBase}/coastal_convex_SE.png`;
    case "14,7":
      return `${assetBase}/coastal_convex_SE.png`;
    case "15,3":
      return `${assetBase}/coastal_concave_NE.png`;
    case "15,6":
      return `${assetBase}/coastal_convex_SE.png`;
    case "10,8":
      return `${assetBase}/coastal_convex_SE.png`;
    case "2,8":
      return `${assetBase}/coastal_convex_SW.png`;
    case "1,7":
      return `${assetBase}/coastal_convex_SW.png`;
    default:
      return "";
  }
}

function displayMarkerPosition(state) {
  if (markerAnimation.active && markerAnimation.tile) {
    return markerAnimation.tile;
  }
  if (state?.travel?.active && state?.travel?.cursor) {
    return state.travel.cursor;
  }
  return state?.player?.position || null;
}

function travelPathNeighbors(map, pos) {
  const out = [];
  for (let dx = -1; dx <= 1; dx += 1) {
    for (let dy = -1; dy <= 1; dy += 1) {
      if (dx === 0 && dy === 0) {
        continue;
      }
      const next = tileAt(map, pos.x + dx, pos.y + dy);
      if (next && next.code !== 0) {
        out.push(next);
      }
    }
  }
  return out;
}

function boatPathNeighbors(map, pos) {
  const out = [];
  for (let dx = -1; dx <= 1; dx += 1) {
    for (let dy = -1; dy <= 1; dy += 1) {
      if (dx === 0 && dy === 0) {
        continue;
      }
      const next = tileAt(map, pos.x + dx, pos.y + dy);
      if (next && waterTravelTile(next.code)) {
        out.push(next);
      }
    }
  }
  return out;
}

function pathHeuristic(from, target) {
  if (!from || !target) {
    return 0;
  }
  return Math.abs(from.x - target.x) + Math.abs(from.y - target.y);
}

function shortestTravelPath(map, start, target, options = {}) {
  if (!start || !target) {
    return [];
  }
  if (sameTile(start, target)) {
    return [start];
  }

  const startKey = `${start.x},${start.y}`;
  const targetKey = `${target.x},${target.y}`;
  const distances = new Map([[startKey, 0]]);
  const previous = new Map();
  const queue = [{ x: start.x, y: start.y, cost: 0 }];

  while (queue.length) {
    queue.sort((a, b) => {
      const scoreDiff = (a.cost + pathHeuristic(a, target)) - (b.cost + pathHeuristic(b, target));
      if (scoreDiff !== 0) {
        return scoreDiff;
      }
      const targetDiff = pathHeuristic(a, target) - pathHeuristic(b, target);
      if (targetDiff !== 0) {
        return targetDiff;
      }
      if (a.y !== b.y) {
        return a.y - b.y;
      }
      return a.x - b.x;
    });
    const current = queue.shift();
    const currentKey = `${current.x},${current.y}`;
    if (current.cost !== distances.get(currentKey)) {
      continue;
    }
    if (currentKey === targetKey) {
      break;
    }

    const availableNeighbors = options.useBoat
      ? boatPathNeighbors(map, current)
      : travelPathNeighbors(map, current);
    const neighbors = availableNeighbors.sort((left, right) => {
      const targetDiff = pathHeuristic(left, target) - pathHeuristic(right, target);
      if (targetDiff !== 0) {
        return targetDiff;
      }
      if (left.y !== right.y) {
        return left.y - right.y;
      }
      return left.x - right.x;
    });

    for (const next of neighbors) {
      const nextKey = `${next.x},${next.y}`;
      const nextCost = current.cost + (options.useBoat ? 1 : movementCost(next.code));
      if (!distances.has(nextKey) || nextCost < distances.get(nextKey)) {
        distances.set(nextKey, nextCost);
        previous.set(nextKey, currentKey);
        queue.push({ x: next.x, y: next.y, cost: nextCost });
      }
    }
  }

  if (!distances.has(targetKey)) {
    return [start];
  }

  const path = [];
  let cursor = targetKey;
  while (cursor) {
    const [x, y] = cursor.split(",").map(Number);
    path.push({ x, y });
    cursor = previous.get(cursor);
  }
  path.reverse();
  return path;
}

function ensureMapMarker() {
  const grid = mapRoot.querySelector(".map-grid");
  if (!grid) {
    return null;
  }

  let layer = grid.querySelector(".map-marker-layer");
  if (!layer) {
    layer = document.createElement("div");
    layer.className = "map-marker-layer";
    layer.innerHTML = '<span class="map-player-marker" title="Player"></span>';
    grid.appendChild(layer);
  }

  const marker = layer.querySelector(".map-player-marker");
  if (marker) {
    marker.style.setProperty("--player-sprite-url", `url('${currentPlayerSpriteUrl}')`);
  }
  return marker;
}

function ensureMapOverlayLayer() {
  const grid = mapRoot.querySelector(".map-grid");
  if (!grid) {
    return null;
  }
  let layer = grid.querySelector(".map-overlay-layer");
  if (!layer) {
    layer = document.createElement("div");
    layer.className = "map-overlay-layer";
    grid.appendChild(layer);
  }
  return layer;
}

function tileAnchorPosition(button, container) {
  if (!button || !container) {
    return null;
  }
  const tileBox = button.getBoundingClientRect();
  const containerBox = container.getBoundingClientRect();
  return {
    x: tileBox.left - containerBox.left + (tileBox.width / 2),
    y: tileBox.top - containerBox.top + (tileBox.height * 0.82)
  };
}

function placeMarkerAtTile(tile, options = {}) {
  const instant = !!options.instant;
  const grid = mapRoot.querySelector(".map-grid");
  const marker = ensureMapMarker();
  if (!grid || !marker || !tile) {
    return;
  }
  const tileButton = grid.querySelector(`.tile-button[data-x="${tile.x}"][data-y="${tile.y}"]`);
  const anchor = tileAnchorPosition(tileButton, grid);
  if (!anchor) {
    return;
  }
  marker.classList.toggle("is-snapping", instant);
  marker.style.left = `${anchor.x}px`;
  marker.style.top = `${anchor.y}px`;
}

function wait(ms) {
  return new Promise((resolve) => {
    window.setTimeout(resolve, ms);
  });
}

async function animateTravelSelection(state, target) {
  const start = displayMarkerPosition(state);
  if (!start || !target || sameTile(start, target)) {
    return;
  }

  const startTile = tileAt(state?.map || [], start.x, start.y);
  const targetTile = tileAt(state?.map || [], target.x, target.y);
  const useBoat = !!state?.player?.carriesBoat
    && !!startTile
    && !!targetTile
    && waterTravelTile(startTile.code)
    && waterTravelTile(targetTile.code);
  const path = shortestTravelPath(state?.map || [], start, target, { useBoat });
  if (!path.length) {
    return;
  }

  markerAnimation.active = true;
  markerAnimation.tile = start;
  render(store.getState());

  const marker = ensureMapMarker();
  if (!marker) {
    markerAnimation.active = false;
    markerAnimation.tile = null;
    return;
  }

  mapRoot.classList.add("is-travel-animating");
  placeMarkerAtTile(start, { instant: true });
  for (const step of path.slice(1)) {
    markerAnimation.tile = step;
    placeMarkerAtTile(step);
    await wait(TRAVEL_ANIMATION_STEP_MS);
  }
  mapRoot.classList.remove("is-travel-animating");
  markerAnimation.active = false;
  markerAnimation.tile = null;
}

function renderMap(state) {
  const map = state?.map || [];
  const canShowOceanLabels = !!state?.player?.carriesBoat;
  const loads = state?.loads || { active: false, counts: {} };
  const boatLeftPosition = state?.player?.boatLeftPosition || null;
  if (!map.length) {
    mapRoot.innerHTML = '<p>No map loaded for this backend yet.</p>';
    return;
  }

  const displayMarker = displayMarkerPosition(state);
  const rowsHtml = map.map((row) => {
    const tilesHtml = row.map((tile) => {
      const classes = [
        "tile-button",
        `terrain-${tile.terrain}`
      ];
      if (!tile.isVisible) classes.push("is-hidden");
      const textureVariant = coastalTextureVariant(map, tile.x, tile.y);
      if (textureVariant && tile.isVisible) classes.push(textureVariant);
      if (displayMarker && tile.x === displayMarker.x && tile.y === displayMarker.y) classes.push("is-player");
      if (tile.isCursor) classes.push("is-cursor");
      if (tile.isAdjacent) classes.push("is-adjacent");
      if (tile.isReachable) classes.push("is-reachable");
      if (tile.code === 0 && !tile.isReachable && !(displayMarker && tile.x === displayMarker.x && tile.y === displayMarker.y)) {
        classes.push("is-blocked");
      }

      const dataAttrs = `data-x="${tile.x}" data-y="${tile.y}"`;
      const textureOverride = tileTextureOverride(tile);
      const styleParts = [];
      if (textureOverride && tile.isVisible) {
        styleParts.push(`background-image: linear-gradient(rgba(255, 255, 255, 0.06), rgba(0, 0, 0, 0.08)), url('${escapeHtml(textureOverride)}')`);
      }
      const styleAttr = styleParts.length ? ` style="${styleParts.join("; ")};"` : "";
      const loadCount = Number(loads.counts?.[`${tile.x},${tile.y}`] || 0);

      return (
        `<button type="button" class="${classes.join(" ")}" ${dataAttrs}${styleAttr}>` +
        (tile.isReachable && tile.travelCost !== null ? `<span class="tile-cost">${escapeHtml(tile.travelCost)}</span>` : "") +
        (tile.isVisible && loads.active && loadCount > 0 ? `<span class="tile-load-count" title="${escapeHtml(loadCount)} living players">&#9829;<span class="tile-load-count-value">${escapeHtml(loadCount)}</span></span>` : "") +
        (tile.isVisible && tile.activeStory ? `<span class="tile-story-flag" title="${escapeHtml(tile.activeStory.title || tile.activeStory.id || 'Active story')}">&#9873;</span>` : "") +
        (tile.isVisible && boatLeftPosition && tile.x === boatLeftPosition.x && tile.y === boatLeftPosition.y
          ? `<span class="tile-boat-anchor" title="Your boat is waiting here">&#9875;</span>`
          : "") +
        (tile.isVisible && showTileLabels ? `<span class="tile-label">${escapeHtml(tileLabel(tile, canShowOceanLabels))}</span>` : "") +
        "</button>"
      );
    }).join("");

    return `<div class="map-row" style="grid-template-columns: repeat(${row.length}, minmax(42px, 1fr));">${tilesHtml}</div>`;
  }).join("");

  mapRoot.innerHTML = `<div class="map-grid">${rowsHtml}</div>`;
  const overlayLayer = ensureMapOverlayLayer();
  if (overlayLayer) {
    const frens = state?.frens?.entries || [];
    const byTile = new Map();
    for (const fren of frens) {
      const key = `${fren.position.x},${fren.position.y}`;
      const bucket = byTile.get(key) || [];
      bucket.push(fren);
      byTile.set(key, bucket);
    }
    overlayLayer.innerHTML = "";
    for (const [key, entries] of byTile.entries()) {
      const [x, y] = key.split(",").map(Number);
      const grid = mapRoot.querySelector(".map-grid");
      const tileButton = grid?.querySelector(`.tile-button[data-x="${x}"][data-y="${y}"]`);
      const anchor = tileAnchorPosition(tileButton, grid);
      if (!anchor) {
        continue;
      }
      entries.forEach((fren, index) => {
        const marker = document.createElement("span");
        marker.className = "map-fren-marker";
        marker.title = fren.name;
        marker.style.left = `${anchor.x + (index * 12) - ((entries.length - 1) * 6)}px`;
        marker.style.top = `${anchor.y - 20}px`;
        marker.style.setProperty("--player-sprite-url", `url('${spriteUrlFromAppearance16(fren.appearance16)}')`);
        overlayLayer.appendChild(marker);
      });
    }
  }
  placeMarkerAtTile(displayMarker, { instant: true });
}

function renderPlace(state) {
  const place = state?.place;
  const arrivalResult = currentArrivalResult(state, place);
  if (!place) {
    placeTitle.textContent = "Unknown place";
    placeMeta.textContent = "";
    placeText.textContent = "";
    if (placeActions) {
      placeActions.innerHTML = "";
    }
    placeVisual.removeAttribute("src");
    return;
  }
  syncPlacePanelMode(place);

  placeTitle.textContent = place.title || "Unknown place";
  placeMeta.textContent = `${place.terrain} @ (${place.x}, ${place.y})`;
  if (isCityPlace(place) && placePanelMode.view === "explore") {
    placeText.innerHTML = "";
    placeText.textContent = "No active city adventure is waiting here right now. The city settles into its ordinary rhythm: stalls are open, prices are argued over, creatures are offered, scrolls change hands, and captains call for passengers.";
  } else if (arrivalResult) {
    if (Number(arrivalResult.outcomeTier || 0) > 0) {
      const request = authoredNarrativeRequest(arrivalResult, place, currentAttitude);
      ensureAuthoredNarrative(request);
      const authoredTitle = authoredNarrativeTitle(request);
      const authoredText = authoredNarrativeText(request);
      const aftermath = storyAftermathLines(arrivalResult);
      setPlaceTextStory(
        authoredTitle || place.story?.title || "Story",
        renderNarrativeText(authoredText || arrivalResult.body || "", { companionName: arrivalResult.grantedCompanion }),
        aftermath
      );
    } else {
      ensureAuthoredNarrative(null);
      setPlaceTextStory(
        place.story?.title || "Missed Encounter",
        storyMissedMessage(place),
        storyAftermathLines(arrivalResult)
      );
    }
  } else if (isArrivalStory(place) && placePanelMode.view === "explore") {
    ensureAuthoredNarrative(null);
    const companionCount = Number(state?.player?.companions || 0);
    placeText.innerHTML = "";
    placeText.textContent = [
      `${place.story?.title || "An arrival encounter"} is active here.`,
      companionCount >= 3
        ? "This place resolves on arrival, but companion encounters here only yield a new bond while you travel with fewer than three companions.\n\nSell, gift, or otherwise part with one companion if you want this place to resolve into a new companion story."
        : "This place resolves on arrival.\n\nTravel into it with your current attitude, and the encounter will settle as part of the move itself."
    ].filter(Boolean).join("\n\n");
  } else if (place.story && placePanelMode.view === "explore") {
    ensureAuthoredNarrative(null);
    placeText.innerHTML = "";
    placeText.textContent =
      `${place.story.title || "A bound story"} is waiting here.\n\n` +
      "Enter the story to read the scene and choose your path.";
  } else if (!isCityPlace(place) && placePanelMode.view === "explore") {
    ensureAuthoredNarrative(null);
    placeText.innerHTML = "";
    placeText.textContent = "No active adventure is waiting on this tile right now. What remains is the place itself: its weather, its habits, and the small local possibilities that belong to it.";
  } else if (isArrivalStory(place)) {
    ensureAuthoredNarrative(null);
    placeText.innerHTML = "";
    placeText.textContent =
      `${place.story?.title || "An arrival encounter"} is active here right now.\n\n` +
      "This tile is carrying a live encounter. Open Explore to see the encounter panel, then travel into the tile with your current attitude to resolve it on arrival.";
  } else {
    ensureAuthoredNarrative(null);
    placeText.innerHTML = "";
    placeText.textContent = place.text || "";
  }
  placeVisual.src = placeImageForDisplay(place);
  placeVisual.onerror = () => {
    placeVisual.onerror = null;
    placeVisual.src = placeImageFallback(place);
  };
  renderPlaceActions(place, state?.player);

  const travel = state?.travel;
  if (travel?.active && travel.cursor) {
    travelNotice.classList.remove("hidden");
    travelNotice.textContent =
      `Travel planning mode. Cursor at (${travel.cursor.x}, ${travel.cursor.y}). ` +
      `Moves left: ${travel.movesLeft}. Attitude: ${currentAttitude}. ` +
      `Your committed position remains (${state.player.position.x}, ${state.player.position.y}).`;
  } else {
    travelNotice.classList.add("hidden");
    travelNotice.textContent = "";
  }

  const canName = !!place.canName && !travel?.active;
  nameInput.disabled = !canName;
  nameButton.disabled = !canName;
  nameInput.placeholder = canName
    ? "Name this place"
    : (travel?.active ? "Finish travel planning before naming" : "This place cannot be named right now");
}

function renderPlayer(state) {
  const player = state?.player;
  if (!player) {
    return;
  }
  syncAvatarFromChain(player);
  playerName.textContent = player.name;
  if (seasonChip) {
    const season = String(player.season || "").trim();
    seasonChip.textContent = `Season: ${season ? season[0].toUpperCase() + season.slice(1) : "Spring"}`;
  }
  playerPosition.textContent = `(${player.position.x}, ${player.position.y})`;
  playerPearls.textContent = String(player.pearls);
  playerLevel.textContent = String(player.level);
  playerTravelBonus.textContent = `+${player.travelBonus || 0}`;
  if (playerItems) {
    const items = [];
    if (player.boatStatus && player.boatStatus.toLowerCase() !== "none") {
      items.push(player.boatStatus);
    }
    playerItems.textContent = items.length ? items.join(" · ") : "None";
  }
  if (playerSpiritStats) {
    playerSpiritStats.textContent = `B ${player.boldness ?? "-"} · C ${player.caution ?? "-"} · K ${player.kindness ?? "-"} · Soul ${player.soul ?? "-"}`;
  }
  if (playerCompanions) {
    const companionList = state?.companionList || [];
    if (!companionList.length) {
      playerCompanions.textContent = "None";
    } else {
      const names = companionList.map((companion) => {
        const label = companion.name || companion.species || `#${companion.id}`;
        return companion.active ? `${label} (active)` : label;
      });
      const suffix = Number(player.companions || companionList.length) >= 3
        ? " · max travel companions reached"
        : "";
      playerCompanions.textContent = `${names.join(", ")}${suffix}`;
    }
  }
  if (playerMonsters) {
    const monsterMarks = (state?.monsterMarks || []).filter((entry) => entry?.state === "yes");
    if (!monsterMarks.length) {
      playerMonsters.textContent = "None";
    } else {
      playerMonsters.textContent = monsterMarks
        .map((entry) => `${entry.kind} (known)`)
        .join(", ");
    }
  }
  const companionList = state?.companionList || [];
  const monsterMarks = (state?.monsterMarks || []).filter((entry) => entry?.state === "yes");
  const currentMoves = state?.travel?.active
    ? Number(state?.travel?.movesLeft || 0)
    : (3 + Number(player?.travelBonus || 0));
  const claimCount = Number(state?.companionClaimsCount || 0);
  const hasBoat = !!(player.boatStatus && player.boatStatus.toLowerCase() !== "none");
  if (stagePearls) {
    stagePearls.textContent = String(player.pearls ?? 0);
  }
  if (stageMoves) {
    stageMoves.textContent = String(currentMoves);
  }
  if (stageBoat) {
    stageBoat.textContent = hasBoat ? "1" : "0";
  }
  if (stageBoldness) {
    stageBoldness.textContent = String(player.boldness ?? 0);
  }
  if (stageCaution) {
    stageCaution.textContent = String(player.caution ?? 0);
  }
  if (stageKindness) {
    stageKindness.textContent = String(player.kindness ?? 0);
  }
  if (stageSoul) {
    stageSoul.textContent = String(player.soul ?? 0);
  }
  if (stageCompanions) {
    stageCompanions.textContent = String(companionList.length);
  }
  if (stageMonsters) {
    stageMonsters.textContent = String(monsterMarks.length);
  }
  if (stageClaims) {
    stageClaims.textContent = String(claimCount);
  }
  if (mintCompanionButton) {
    const canMint = claimCount > 0;
    mintCompanionButton.disabled = !canMint;
    mintCompanionButton.setAttribute("aria-pressed", canMint ? "true" : "false");
    mintCompanionButton.classList.toggle("stage-stat-button-mint-ready", canMint);
  }
  if (stageCompanionIcon) {
    stageCompanionIcon.textContent = emojiForCompanionList(companionList);
  }
  if (stageMonsterIcon) {
    stageMonsterIcon.textContent = emojiForMonsterMarks(monsterMarks);
  }
  if (playerStageName) {
    playerStageName.textContent = player.name || "Player";
  }
  if (playerStagePosition) {
    playerStagePosition.textContent = `at (${player.position.x}, ${player.position.y})`;
  }
  if (playerStageStats) {
    playerStageStats.textContent = `Lvl ${player.level} · Moves ${currentMoves} · Travel +${player.travelBonus || 0}`;
  }
  if (playerStageWealth) {
    playerStageWealth.textContent = `Pearls ${player.pearls ?? 0}`;
  }
  if (playerStageItems) {
    playerStageItems.textContent = playerItems?.textContent || "None";
  }
  if (playerStageCompanions) {
    playerStageCompanions.textContent = playerCompanions?.textContent || "None";
  }
  if (playerStageMonsters) {
    playerStageMonsters.textContent = playerMonsters?.textContent || "None";
  }
  if (playerStageClaims) {
    playerStageClaims.textContent = claimCount > 0 ? `Mintable ${claimCount}` : "None";
  }
  const identity = api.identity();
  currentAttitude = identity.attitude || currentAttitude;
  if (identityPlayerName && document.activeElement !== identityPlayerName) {
    identityPlayerName.value = identity.playerName || "";
  }
  if (identityKeyName && document.activeElement !== identityKeyName) {
    identityKeyName.value = identity.keyName || "";
  }

}

function renderDrawerPanels() {
  mapPanel?.classList.toggle("hidden", mainViewMode !== "map");
  playerPanel?.classList.toggle("hidden", mainViewMode !== "player");
  portraitPanel?.classList.toggle("hidden", mainViewMode !== "portrait");
  placePanel?.classList.toggle("hidden", mainViewMode !== "place");
  mailPanel?.classList.toggle("hidden", mainViewMode !== "mail");
  if (mapHomeButton) {
    mapHomeButton.disabled = mainViewMode === "map";
  }
  if (openPlayerPanelButton) {
    openPlayerPanelButton.disabled = mainViewMode === "player";
  }
  if (openPortraitPanelButton) {
    openPortraitPanelButton.disabled = mainViewMode === "portrait";
  }
  if (openPlacePanelButton) {
    openPlacePanelButton.disabled = mainViewMode === "place";
  }
  if (openMailPanelButton) {
    openMailPanelButton.disabled = mainViewMode === "mail";
  }
}

function setMainViewMode(mode) {
  const nextMode = mode === "player" || mode === "portrait" || mode === "place" || mode === "mail" ? mode : "map";
  const previousMode = mainViewMode;
  mainViewMode = nextMode;
  render(store.getState());
  if (nextMode === "portrait") {
    window.requestAnimationFrame(() => {
      avatarEditor?.focus();
    });
  }
  if (nextMode === "map" && previousMode !== "map") {
    window.requestAnimationFrame(() => {
      repositionMarkerAfterLayout();
    });
  }
}

function renderTravelControls(state) {
  const travel = state?.travel;
  const active = !!travel?.active;
  travelBadge.classList.toggle("hidden", !active);
  travelBadge.textContent = active ? `Travel Mode · ${travel.movesLeft} left` : "Travel Mode";
  tileLabelsButton.textContent = showTileLabels ? "Hide Tile Labels" : "Show Tile Labels";
}

function latestCliCommand(state) {
  const log = state?.log || [];
  for (const entry of log) {
    const text = String(entry ?? "");
    const commandMatch = text.match(/(gnokey maketx call[\s\S]*)$/);
    if (commandMatch) {
      return commandMatch[1].trim();
    }
  }
  return "";
}

function renderMapCommandOverlay(state) {
  if (!mapCommandOverlay || !mapCommandText) {
    return;
  }
  const command = latestCliCommand(state);
  const show = !!command && !!state?.travel?.active;
  mapCommandOverlay.classList.toggle("hidden", !show);
  mapCommandText.value = show ? command : "";
  if (copyMapCommandButton) {
    copyMapCommandButton.disabled = !show;
  }
}

function renderPlayerCommandOverlay() {
  if (!playerCommandOverlay || !playerCommandText) {
    return;
  }
  const text = String(playerCommandState?.text || "").trim();
  const show = !!text;
  playerCommandOverlay.classList.toggle("hidden", !show);
  playerCommandText.value = show ? text : "";
  if (playerCommandTitle) {
    playerCommandTitle.textContent = playerCommandState?.title || "Player Command";
  }
  if (copyPlayerCommandButton) {
    copyPlayerCommandButton.disabled = !show;
  }
}

function setPlayerCommandOverlay(title, text) {
  playerCommandState = {
    title: String(title || "Player Command"),
    text: String(text || "").trim()
  };
  renderPlayerCommandOverlay();
}

function clearPlayerCommandOverlay() {
  setPlayerCommandOverlay("", "");
}

function renderMailCommandOverlay() {
  if (!mailCommandOverlay || !mailCommandText) {
    return;
  }
  const text = String(mailCommandState?.text || "").trim();
  const show = !!text;
  mailCommandOverlay.classList.toggle("hidden", !show);
  mailCommandText.value = show ? text : "";
  if (mailCommandTitle) {
    mailCommandTitle.textContent = mailCommandState?.title || "Message Command";
  }
  if (copyMailCommandButton) {
    copyMailCommandButton.disabled = !show;
  }
}

function setMailCommandOverlay(title, text) {
  mailCommandState = {
    title: String(title || "Message Command"),
    text: String(text || "").trim()
  };
  renderMailCommandOverlay();
}

function clearMailCommandOverlay() {
  setMailCommandOverlay("", "");
}

function buildImportIdentityNote(playerName, keyName) {
  const cleanPlayerName = String(playerName || "").trim() || "Nisse";
  const cleanKeyName = String(keyName || "").trim() || "mykey";
  return [
    "Local player import",
    `Player: ${cleanPlayerName}`,
    `Key: ${cleanKeyName}`,
    "",
    "This action imports an existing on-chain player into the local browser session.",
    "No gnokey transaction is required."
  ].join("\n");
}

function renderLog(state) {
  const log = state?.log || [];
  eventLog.innerHTML = log.map((entry) => {
    const text = String(entry ?? "");
    const commandMatch = text.match(/(gnokey maketx call[\s\S]*)$/);
    if (commandMatch) {
      const intro = text.slice(0, commandMatch.index).trim();
      return (
        `<div class="event-log-entry">` +
        (intro ? `<div class="event-log-text">${escapeHtml(intro)}</div>` : "") +
        `<pre class="event-log-command">${escapeHtml(commandMatch[1])}</pre>` +
        `</div>`
      );
    }
    return `<div class="event-log-entry"><div class="event-log-text">${escapeHtml(text)}</div></div>`;
  }
  ).join("");
}

function render(state) {
  renderMap(state);
  renderPlace(state);
  renderPlayer(state);
  renderMailBox(state);
  renderAdenaDeployBox();
  renderCompanionRegistryBox();
  renderFrensBox(state);
  renderTravelControls(state);
  renderMapCommandOverlay(state);
  renderPlayerCommandOverlay();
  renderMailCommandOverlay();
  renderLog(state);
  renderAttitudeButton();
  renderAvatarEditor();
  renderDrawerPanels();
}

function repositionMarkerAfterLayout() {
  const state = store.getState();
  const markerTile = displayMarkerPosition(state);
  if (!markerTile) {
    return;
  }

  const realign = () => placeMarkerAtTile(markerTile, { instant: true });
  realign();
  window.requestAnimationFrame(realign);
  window.setTimeout(realign, 60);
  window.setTimeout(realign, 180);
}

function centerMapOnMarker() {
  const state = store.getState();
  const markerTile = displayMarkerPosition(state);
  const grid = mapRoot.querySelector(".map-grid");
  if (!markerTile || !grid) {
    return;
  }

  const tileButton = grid.querySelector(`.tile-button[data-x="${markerTile.x}"][data-y="${markerTile.y}"]`);
  if (!tileButton) {
    return;
  }

  const rootBox = mapRoot.getBoundingClientRect();
  const tileBox = tileButton.getBoundingClientRect();
  const targetLeft = (tileBox.left - rootBox.left) + mapRoot.scrollLeft + (tileBox.width / 2) - (mapRoot.clientWidth / 2);
  const targetTop = (tileBox.top - rootBox.top) + mapRoot.scrollTop + (tileBox.height / 2) - (mapRoot.clientHeight / 2);

  mapRoot.scrollTo({
    left: Math.max(0, targetLeft),
    top: Math.max(0, targetTop),
    behavior: "auto"
  });
}

function centerMapOnMarkerAfterLayout() {
  const recenter = () => centerMapOnMarker();
  recenter();
  window.requestAnimationFrame(recenter);
  window.setTimeout(recenter, 60);
  window.setTimeout(recenter, 180);
}

async function loadState() {
  try {
    const nextState = await api.getState();
    setUiState(nextState);
    centerMapOnMarkerAfterLayout();
  } catch (err) {
    setUiState(errorState(err?.message || String(err)));
  }
}

async function runAction(action) {
  try {
    const nextState = await action();
    setUiState(nextState);
  } catch (err) {
    const current = store.getState();
    const message = err?.message || String(err);
    setUiState(current ? {
      ...current,
      log: [message, ...(current.log || [])].slice(0, 24)
    } : errorState(message));
  }
}

function syncFullscreenButtonLabel() {
  if (!mapFullscreenButton || !mapPanel) {
    return;
  }
  mapFullscreenButton.textContent = document.fullscreenElement === mapPanel
    ? "Exit Fullscreen"
    : "Fullscreen Map";
}

refreshButton?.addEventListener("click", async () => {
  await runAction(() => api.refresh());
  centerMapOnMarkerAfterLayout();
});

mapFullscreenButton?.addEventListener("click", async () => {
  if (!mapPanel) {
    return;
  }

  try {
    if (document.fullscreenElement === mapPanel) {
      await document.exitFullscreen();
    } else {
      await mapPanel.requestFullscreen();
    }
  } catch (err) {
    const current = store.getState();
    const message = err?.message || String(err);
    store.setState(current ? {
      ...current,
      log: [message, ...(current.log || [])].slice(0, 24)
    } : errorState(message));
  }
});

attitudeCautiousButton?.addEventListener("click", () => {
  currentAttitude = api.setAttitude ? api.setAttitude("cautious") : "cautious";
  render(store.getState());
});

attitudeKindButton?.addEventListener("click", () => {
  currentAttitude = api.setAttitude ? api.setAttitude("kind") : "kind";
  render(store.getState());
});

attitudeBoldButton?.addEventListener("click", () => {
  currentAttitude = api.setAttitude ? api.setAttitude("bold") : "bold";
  render(store.getState());
});

mintCompanionButton?.addEventListener("click", async () => {
  const state = store.getState();
  const playerName = state?.player?.name || identityPlayerName?.value || "Nisse";
  const claim = (state?.companionClaims || []).find((entry) => Number(entry?.count || 0) > 0);
  if (!claim?.claimID) {
    setPlayerCommandOverlay("Mint Companion", "No mintable companion claims are ready.");
    setMainViewMode("player");
    return;
  }
  await handleRealmCallAction({
    func: "MintEarnedCompanion",
    args: [playerName, claim.claimID, ""],
    memo: `Mint ${claim.type || "companion"}`,
    fallback: () => api.stageMintEarnedCompanion(),
    overlay: "player",
    switchView: "player"
  });
});

tileLabelsButton?.addEventListener("click", () => {
  showTileLabels = !showTileLabels;
  saveTileLabelsPreference(showTileLabels);
  render(store.getState());
});

importIdentityButton?.addEventListener("click", async () => {
  await runAction(() => api.importIdentity(identityPlayerName?.value, identityKeyName?.value));
  setPlayerCommandOverlay(
    "Import Player",
    buildImportIdentityNote(identityPlayerName?.value, identityKeyName?.value)
  );
});

stageMintButton?.addEventListener("click", async () => {
  const playerName = String(identityPlayerName?.value || "").trim();
  if (!playerName) {
    setPlayerCommandOverlay("MintPlayer", "Enter the player name for the new nisse.");
    setMainViewMode("player");
    return;
  }
  await handleRealmCallAction({
    func: "MintPlayer",
    args: [playerName],
    memo: `Mint player ${playerName}`,
    fallback: () => api.stageMintIdentity(identityPlayerName?.value, identityKeyName?.value),
    overlay: "player",
    switchView: "player"
  });
});

companionRegistryButton?.addEventListener("click", async () => {
  const query = companionRegistryInput?.value.trim() || "";
  if (!query) {
    companionRegistryState = {
      query: "",
      loading: false,
      text: "",
      error: "Companion kind is required."
    };
    render(store.getState());
    return;
  }
  companionRegistryState = {
    query,
    loading: true,
    text: "",
    error: ""
  };
  render(store.getState());
  try {
    const text = await api.describeCompanionRegistry(query);
    companionRegistryState = {
      query,
      loading: false,
      text,
      error: ""
    };
  } catch (err) {
    companionRegistryState = {
      query,
      loading: false,
      text: "",
      error: err?.message || String(err)
    };
  }
  render(store.getState());
});

companionRegistryInput?.addEventListener("keydown", async (event) => {
  if (event.key !== "Enter") {
    return;
  }
  event.preventDefault();
  companionRegistryButton?.click();
});

loadPlayersButton?.addEventListener("click", async () => {
  await runAction(() => api.loadPlayerCounts());
});

clearLoadsButton?.addEventListener("click", async () => {
  await runAction(() => api.clearPlayerCounts());
});

loadFrensButton?.addEventListener("click", async () => {
  await runAction(() => api.loadFrens(frensInput?.value || ""));
});

clearFrensButton?.addEventListener("click", async () => {
  await runAction(() => api.clearFrens());
});

frensInput?.addEventListener("keydown", async (event) => {
  if (event.key !== "Enter") {
    return;
  }
  event.preventDefault();
  loadFrensButton?.click();
});

messageToInput?.addEventListener("input", () => {
  mailComposerState = {
    ...mailComposerState,
    to: messageToInput.value
  };
});

messageBodyInput?.addEventListener("input", () => {
  mailComposerState = {
    ...mailComposerState,
    body: messageBodyInput.value
  };
});

messageSendButton?.addEventListener("click", async () => {
  const state = store.getState();
  const playerName = state?.player?.name || identityPlayerName?.value || "Nisse";
  await handleRealmCallAction({
    func: "WriteToFriend",
    args: [playerName, mailComposerState.to, mailComposerState.body],
    memo: `Message ${mailComposerState.to || "friend"}`,
    fallback: () => api.stageWriteToFriend(mailComposerState.to, mailComposerState.body),
    overlay: "mail",
    switchView: "mail"
  });
});

messageRefreshButton?.addEventListener("click", async () => {
  await runAction(() => api.refresh());
});

adenaConnectButton?.addEventListener("click", async () => {
  try {
    await connectAdenaWallet();
  } catch (err) {
    adenaState = {
      ...adenaState,
      connecting: false,
      connected: false,
      error: err?.message || String(err)
    };
    render(store.getState());
  }
});

adenaUploadPackageButton?.addEventListener("click", async () => {
  try {
    const command = await buildHostedPackageCliCommand();
    setPlayerCommandOverlay("Stage Upload CLI", command);
    setMainViewMode("player");
    pushLogMessage("Staged gnokey addpkg command for the staging network.");
  } catch (err) {
    adenaState = {
      ...adenaState,
      error: err?.message || String(err)
    };
    render(store.getState());
  }
});

avatarPalette?.addEventListener("click", (event) => {
  const target = event.target instanceof HTMLElement ? event.target.closest("[data-avatar-color]") : null;
  if (!target) {
    return;
  }
  avatarState.selected = Number(target.getAttribute("data-avatar-color")) || 0;
  renderAvatarEditor();
});

avatarEditor?.addEventListener("pointerdown", (event) => {
  avatarPointerDown = true;
  paintAvatarFromPointer(event);
});

avatarEditor?.addEventListener("pointermove", (event) => {
  if (!avatarPointerDown) {
    return;
  }
  paintAvatarFromPointer(event);
});

window.addEventListener("pointerup", () => {
  avatarPointerDown = false;
});

avatarEraseButton?.addEventListener("click", () => {
  avatarState.selected = 0;
  updateAvatarDirtyState();
  renderAvatarEditor();
});

avatarClearButton?.addEventListener("click", () => {
  avatarState.pixels = defaultAvatarPixels();
  updateAvatarDirtyState();
  renderAvatarEditor();
});

avatarSaveButton?.addEventListener("click", async () => {
  persistAvatarState();
  renderAvatarEditor();
  const payload = avatarState.pixels.some((value) => value !== 0)
    ? encodeAvatarPixels(avatarState.pixels)
    : "none";
  const state = store.getState();
  const playerName = state?.player?.name || identityPlayerName?.value || "Nisse";
  await handleRealmCallAction({
    func: "SetPlayerAppearance",
    args: [playerName, payload],
    memo: "Update portrait",
    fallback: () => api.stageSetPlayerAppearance(payload),
    overlay: "player",
    switchView: "portrait"
  });
});

nameButton.addEventListener("click", async () => {
  const value = nameInput.value.trim();
  if (!value) {
    return;
  }
  const state = store.getState();
  const playerName = state?.player?.name || identityPlayerName?.value || "Nisse";
  await handleRealmCallAction({
    func: "NameTile",
    args: [playerName, value],
    memo: `Name tile ${value}`,
    fallback: () => api.nameCurrentTile(value),
    overlay: "player",
    switchView: "place"
  });
  nameInput.value = "";
});

nameInput.addEventListener("keydown", async (event) => {
  if (event.key !== "Enter") {
    return;
  }
  event.preventDefault();
  nameButton.click();
});

placeActions?.addEventListener("click", (event) => {
  const button = event.target.closest("button");
  if (!button) {
    return;
  }
  const state = store.getState();
  const place = state?.place;
  if (!place) {
    return;
  }

  const placeAction = button.dataset.placeAction;
  if (placeAction === "place-explore") {
    placePanelMode = {
      key: placePanelKey(place),
      view: "explore"
    };
    render(store.getState());
    return;
  }
  if (placeAction === "place-back") {
    placePanelMode = {
      key: placePanelKey(place),
      view: "default"
    };
    render(store.getState());
    return;
  }
  if (placeAction === "buy-boat") {
    const playerName = state?.player?.name || identityPlayerName?.value || "Nisse";
    handleRealmCallAction({
      func: "BuyBoat",
      args: [playerName],
      memo: "Buy boat",
      fallback: () => api.stageBuyBoat(),
      overlay: "player",
      switchView: "place"
    });
    return;
  }

  const service = button.dataset.cityService;
  if (!service) {
    return;
  }
  const serviceMessages = {
    "scroll-seller": "Scrolls and Wisdom: this is the future bookseller for sayings, old scrolls, and pieces of wisdom bought with pearls.",
    "boat-trips": "Boat Trips: this will become the city guide for sailing, coastal passage, and captains offering routes."
  };
  const message = serviceMessages[service];
  if (!message) {
    return;
  }
  const current = store.getState();
  store.setState({
    ...current,
    log: [message, ...(current.log || [])].slice(0, 24)
  });
});

openPlayerPanelButton?.addEventListener("click", () => {
  setMainViewMode("player");
});

openPortraitPanelButton?.addEventListener("click", () => {
  setMainViewMode("portrait");
});

openPlacePanelButton?.addEventListener("click", () => {
  setMainViewMode("place");
});

openMailPanelButton?.addEventListener("click", () => {
  setMainViewMode("mail");
});

mapHomeButton?.addEventListener("click", () => {
  setMainViewMode("map");
});

copyMapCommandButton?.addEventListener("click", async () => {
  if (!mapCommandText?.value) {
    return;
  }
  mapCommandText.focus();
  mapCommandText.select();
  try {
    if (navigator?.clipboard?.writeText) {
      await navigator.clipboard.writeText(mapCommandText.value);
    }
  } catch (err) {
    // Selection fallback is already active.
  }
});

copyPlayerCommandButton?.addEventListener("click", async () => {
  if (!playerCommandText?.value) {
    return;
  }
  playerCommandText.focus();
  playerCommandText.select();
  try {
    if (navigator?.clipboard?.writeText) {
      await navigator.clipboard.writeText(playerCommandText.value);
    }
  } catch (err) {
    // Selection fallback is already active.
  }
});

closePlayerCommandButton?.addEventListener("click", () => {
  clearPlayerCommandOverlay();
});

copyMailCommandButton?.addEventListener("click", async () => {
  if (!mailCommandText?.value) {
    return;
  }
  mailCommandText.focus();
  mailCommandText.select();
  try {
    if (navigator?.clipboard?.writeText) {
      await navigator.clipboard.writeText(mailCommandText.value);
    }
  } catch (err) {
    // Selection fallback is already active.
  }
});

closeMailCommandButton?.addEventListener("click", () => {
  clearMailCommandOverlay();
});

store.subscribe(render);
document.addEventListener("fullscreenchange", () => {
  syncFullscreenButtonLabel();
  repositionMarkerAfterLayout();
});
window.addEventListener("resize", repositionMarkerAfterLayout);
applyAvatarSprite();
renderAttitudeButton();

mapRoot.addEventListener("click", async (event) => {
  if (travelAnimationLocked) {
    return;
  }
  const button = event.target.closest(".tile-button");
  if (!button) {
    return;
  }

  const x = Number(button.dataset.x);
  const y = Number(button.dataset.y);
  const current = store.getState();
  const clickedTile = current?.map?.[y]?.[x];
  if (!clickedTile) {
    return;
  }
  if (!clickedTile.isVisible && !current?.travel?.active) {
    return;
  }

  if (!current?.travel?.active) {
    if (clickedTile?.isPlayer) {
      await runAction(() => api.beginTravel());
    }
    return;
  }

  travelAnimationLocked = true;
  try {
    await animateTravelSelection(current, { x, y });
    if (canUseAdenaWrites()) {
      const playerName = current?.player?.name || identityPlayerName?.value || "Nisse";
      await handleRealmCallAction({
        func: "TravelPlayer",
        args: [playerName, String(x), String(y), currentAttitude],
        memo: `Travel to (${x}, ${y})`,
        fallback: () => api.moveTravelTo(x, y)
      });
    } else {
      await runAction(() => api.moveTravelTo(x, y));
    }
  } finally {
    travelAnimationLocked = false;
  }
});

loadState();
syncFullscreenButtonLabel();
