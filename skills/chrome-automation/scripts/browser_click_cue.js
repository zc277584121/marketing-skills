(function () {
  const DEFAULT_OPTIONS = {
    pulse: true,
    arrow: true,
    pulseSize: 44,
    pulseBorder: 3,
    pulseDurationMs: 560,
    arrowSize: 34,
    arrowDurationMs: 680,
    accent: "31, 111, 235",
  };

  const normalize = (value) => (value || "").replace(/\s+/g, " ").trim();
  const TEXT_TARGET_SELECTOR = [
    "button",
    "a",
    "label",
    "input",
    "textarea",
    "[role='button']",
    "[role='tab']",
    "[role='menuitem']",
    "[role='option']",
    "[role='checkbox']",
    "[role='radio']",
    "[aria-label]",
  ].join(", ");

  const isVisible = (element) => {
    if (!element) return false;
    const rect = element.getBoundingClientRect();
    const style = window.getComputedStyle(element);
    return rect.width > 0 && rect.height > 0 && style.visibility !== "hidden" && style.display !== "none";
  };

  const mergeOptions = (options) => ({ ...DEFAULT_OPTIONS, ...(options || {}) });

  const removeExistingStyle = () => {
    const existing = document.querySelector("#browser-click-cue-style");
    if (existing) existing.remove();
  };

  const install = (options) => {
    const settings = mergeOptions(options);
    let root = document.querySelector("#browser-click-cue-root");
    if (!root) {
      root = document.createElement("div");
      root.id = "browser-click-cue-root";
      document.documentElement.append(root);
    }

    removeExistingStyle();
    const style = document.createElement("style");
    style.id = "browser-click-cue-style";
    style.textContent = `
      #browser-click-cue-root {
        position: fixed;
        inset: 0;
        pointer-events: none;
        z-index: 2147483647;
      }
      .browser-click-cue-pulse {
        position: absolute;
        width: ${settings.pulseSize}px;
        height: ${settings.pulseSize}px;
        border: ${settings.pulseBorder}px solid rgba(${settings.accent}, 0.9);
        border-radius: 999px;
        background: rgba(${settings.accent}, 0.1);
        box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.9);
        transform: translate(-50%, -50%) scale(0.55);
        animation: browser-click-cue-pulse ${settings.pulseDurationMs}ms ease-out forwards;
      }
      .browser-click-cue-arrow {
        position: absolute;
        width: ${settings.arrowSize}px;
        height: ${settings.arrowSize}px;
        transform: translate(-2px, -2px);
        filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.55)) drop-shadow(0 0 2px rgba(255, 255, 255, 0.85));
        animation: browser-click-cue-arrow ${settings.arrowDurationMs}ms ease-out forwards;
      }
      @keyframes browser-click-cue-pulse {
        0% { opacity: 0.98; transform: translate(-50%, -50%) scale(0.55); }
        100% { opacity: 0; transform: translate(-50%, -50%) scale(1.7); }
      }
      @keyframes browser-click-cue-arrow {
        0% { opacity: 0; transform: translate(-2px, -2px) scale(0.96); }
        12% { opacity: 1; transform: translate(-2px, -2px) scale(1); }
        72% { opacity: 1; transform: translate(-2px, -2px) scale(1); }
        100% { opacity: 0; transform: translate(-2px, -2px) scale(0.98); }
      }
    `;
    document.documentElement.append(style);
    window.browserClickCueOptions = settings;
    return "click cue installed";
  };

  const findBySelector = (selector) => Array.from(document.querySelectorAll(selector)).find(isVisible);

  const labelFor = (candidate) =>
    normalize(
      candidate.innerText ||
        candidate.textContent ||
        candidate.getAttribute("aria-label") ||
        candidate.getAttribute("title") ||
        candidate.getAttribute("placeholder") ||
        candidate.value,
    );

  const findByText = (text) => {
    const needle = normalize(text);
    const candidates = Array.from(document.querySelectorAll(TEXT_TARGET_SELECTOR)).filter(isVisible);
    return (
      candidates.find((candidate) => labelFor(candidate) === needle) ||
      candidates.find((candidate) => labelFor(candidate).includes(needle))
    );
  };

  const showAt = async (x, y, options) => {
    const settings = mergeOptions(options || window.browserClickCueOptions);
    install(settings);
    const root = document.querySelector("#browser-click-cue-root");

    if (settings.pulse) {
      const dot = document.createElement("div");
      dot.className = "browser-click-cue-pulse";
      dot.style.left = `${x}px`;
      dot.style.top = `${y}px`;
      root.append(dot);
      dot.addEventListener("animationend", () => dot.remove(), { once: true });
    }

    if (settings.arrow) {
      const arrow = document.createElement("div");
      arrow.className = "browser-click-cue-arrow";
      arrow.style.left = `${x}px`;
      arrow.style.top = `${y}px`;

      const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      svg.setAttribute("viewBox", "0 0 32 32");
      svg.setAttribute("width", String(settings.arrowSize));
      svg.setAttribute("height", String(settings.arrowSize));
      svg.setAttribute("aria-hidden", "true");

      const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
      path.setAttribute("d", "M5.5 3.5L25 17.2L16.7 18.7L21.6 28L17.3 30.1L12.5 20.9L6.6 27.1L5.5 3.5Z");
      path.setAttribute("fill", "#ffffff");
      path.setAttribute("stroke", "#111827");
      path.setAttribute("stroke-width", "1.9");
      path.setAttribute("stroke-linejoin", "round");

      svg.append(path);
      arrow.append(svg);
      root.append(arrow);
      arrow.addEventListener("animationend", () => arrow.remove(), { once: true });
    }

    const delayMs = Math.max(settings.pulseDurationMs, settings.arrowDurationMs, 260);
    await new Promise((resolve) => setTimeout(resolve, Math.min(delayMs, 700)));
    return "ok";
  };

  const showForElement = async (element, options) => {
    if (!element) throw new Error("No element to cue");
    element.scrollIntoView({ block: "center", inline: "nearest" });
    await new Promise((resolve) => setTimeout(resolve, 180));
    const rect = element.getBoundingClientRect();
    return showAt(rect.left + rect.width / 2, rect.top + rect.height / 2, options);
  };

  const api = {
    install,
    showAt,
    showForSelector: async (selector, options) => {
      const element = findBySelector(selector);
      if (!element) throw new Error(`No visible element for selector: ${selector}`);
      return showForElement(element, options);
    },
    showForText: async (text, options) => {
      const element = findByText(text);
      if (!element) throw new Error(`No visible element containing text: ${text}`);
      return showForElement(element, options);
    },
  };
  window.browserClickCue = api;

  return install();
})();
