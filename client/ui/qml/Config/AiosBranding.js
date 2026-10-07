.pragma library

// AIOS owns the customer-facing brand. Keep backend protocol identifiers,
// serialized configs, key fields and runtime matching unchanged.
function isAiosProtocol(value) {
    var name = String(value == null ? "" : value);
    return /amnezia[\s_-]*(?:wg|wireguard)|\bawg(?:\s*v?\d+(?:\.\d+)*)?\b/i.test(name);
}

function label(value) {
    var text = String(value == null ? "" : value);
    return text
        .replace(/amnezia[\s_-]*(?:wg|wireguard)/gi, "AIOS VPN")
        .replace(/\bawg(?:\s*v?\d+(?:\.\d+)*)?\b/gi, "AIOS VPN")
        .replace(/\bamnezia[\s_-]*vpn\b/gi, "AIOS VPN")
        .replace(/\bamnezia\b/gi, "AIOS VPN");
}

function protocol(value) {
    return isAiosProtocol(value) ? "AIOS VPN" : label(value);
}

function protocolDescription(name, description) {
    // Upstream vendor descriptions explain a different product, not AIOS VPN.
    return isAiosProtocol(name) ? "" : label(description);
}
