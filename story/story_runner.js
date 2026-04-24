(function (global) {
  const resourceCache = new Map();
  let placeCatalogPromise = null;

  function appUrl(path) {
    return new URL(String(path || "./"), document.baseURI).href;
  }

  function cleanInput(value) {
    return String(value || "").trim();
  }

  function normalizedFieldValue(value, fallback) {
    const normalized = cleanInput(value);
    return normalized || String(fallback || "");
  }

  function normalizeRealmText(value) {
    return String(value || "").replace(/\r\n/g, "\n").trim();
  }

  function normalizeStoryPathCode(value) {
    return String(value || "").replace(/\D+/g, "");
  }

  function parseExploreStoryMeta(text) {
    const normalized = normalizeRealmText(text);
    const idMatch = normalized.match(/^\s*StoryID:\s*(.+)$/m);
    const storyId = cleanInput(idMatch ? idMatch[1] : "").toLowerCase();
    if (!storyId || storyId === "none") {
      return null;
    }

    const titleMatch = normalized.match(/^\s*StoryTitle:\s*(.+)$/m);
    const themeMatch = normalized.match(/^\s*StoryTheme:\s*(.+)$/m);
    const pathMatch = normalized.match(/^\s*StoryPath:\s*(.+)$/m);
    const resourcePath = normalizedFieldValue(pathMatch ? pathMatch[1] : "", "./stories/" + storyId + "/story.json");

    return {
      id: storyId,
      title: cleanInput(titleMatch ? titleMatch[1] : ""),
      theme: cleanInput(themeMatch ? themeMatch[1] : "").toLowerCase(),
      resourcePath
    };
  }

  async function loadPlaceCatalog() {
    if (!placeCatalogPromise) {
      placeCatalogPromise = fetch(appUrl("./story/places.json"), { cache: "no-store" })
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
        placeName: sceneMeta.placeName
      };
    } catch (err) {
      return sceneMeta;
    }
  }

  function storyResourceBase(resourcePath) {
    const normalizedPath = normalizedFieldValue(resourcePath, "");
    if (!normalizedPath) {
      return "";
    }
    const absolutePath = appUrl(normalizedPath);
    const lastSlash = absolutePath.lastIndexOf("/");
    return lastSlash >= 0 ? absolutePath.slice(0, lastSlash + 1) : "/";
  }

  function resolveStoryAssetPath(resourcePath, assetPath) {
    const normalizedAssetPath = normalizedFieldValue(assetPath, "");
    if (!normalizedAssetPath) {
      return "";
    }
    if (/^[a-z]+:\/\//i.test(normalizedAssetPath)) {
      return normalizedAssetPath;
    }
    if (normalizedAssetPath.startsWith("/")) {
      return appUrl("." + normalizedAssetPath);
    }
    return storyResourceBase(resourcePath) + normalizedAssetPath.replace(/^\.\//, "");
  }

  async function loadTaggedStoryResource(resourcePath) {
    const normalizedResourcePath = normalizedFieldValue(resourcePath, "");
    if (!normalizedResourcePath) {
      throw new Error("Missing tagged story resource path.");
    }

    const requestPath = appUrl(normalizedResourcePath);
    const cacheKey = `tagged:${requestPath}`;
    if (!resourceCache.has(cacheKey)) {
      resourceCache.set(
        cacheKey,
        fetch(requestPath, { cache: "no-store" })
          .then((response) => {
            if (!response.ok) {
              throw new Error("HTTP " + response.status);
            }
            return response.text();
          })
          .then((raw) => parseTaggedStoryText(raw))
      );
    }

    return resourceCache.get(cacheKey);
  }

  function parseTaggedStoryText(text) {
    const normalized = String(text || "").replace(/\r\n/g, "\n");
    const headingMatch = normalized.match(/^\s*#\s+(.+?)\s*(?:\n|$)/);
    if (headingMatch) {
      const title = cleanInput(headingMatch[1]);
      const body = normalized.replace(/^\s*#\s+.+?\s*(?:\n|$)/, "").trim();
      return {
        meta: { title },
        sections: { body }
      };
    }

    const lines = normalized.split("\n");
    const meta = {};
    const sections = {};
    let currentSection = "";
    let buffer = [];

    const flush = () => {
      if (!currentSection) {
        return;
      }
      sections[currentSection] = buffer.join("\n").trim();
      buffer = [];
    };

    lines.forEach((line) => {
      const sectionMatch = line.match(/^\[([a-z0-9_-]+)\]\s*$/i);
      if (sectionMatch) {
        flush();
        currentSection = cleanInput(sectionMatch[1]).toLowerCase();
        return;
      }

      const metaMatch = !currentSection && line.match(/^@([a-z0-9_-]+)\s+(.+)$/i);
      if (metaMatch) {
        meta[cleanInput(metaMatch[1]).toLowerCase()] = cleanInput(metaMatch[2]);
        return;
      }

      buffer.push(line);
    });

    flush();
    return { meta, sections };
  }

  function interpolateStoryText(text, context) {
    const source = String(text || "");
    const values = context || {};
    return source.replace(/\$([a-zA-Z][a-zA-Z0-9_]*)/g, (match, key) => {
      const value = values[key];
      if (value === undefined || value === null || value === "") {
        return "";
      }
      return String(value);
    });
  }

  global.NisseStoryRunner = {
    parseExploreStoryMeta,
    parseTaggedStoryText,
    interpolateStoryText,
    normalizeStoryPathCode,
    loadTaggedStoryResource,
    resolveTileSceneMeta
  };
})(window);
