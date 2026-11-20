// ZeroOmega proxy auto-config rules
var FindProxyForURL = function(init, profiles) {
    return function(url, host) {
        "use strict";
        var result = init, scheme = url.substr(0, url.indexOf(":"));
        do {
            if (!profiles[result]) return result;
            result = profiles[result];
            if (typeof result === "function") result = result(url, host, scheme);
        } while (typeof result !== "string" || result.charCodeAt(0) === 43);
        return result;
    };
}("+auto switch", {
    "+auto switch": function(url, host, scheme) {
        "use strict";
        if (/(?:^|\.)github\.com$/.test(host)) return "+proxy";
        if (/(?:^|\.)githubcopilot\.com$/.test(host)) return "+proxy";
        if (/(?:^|\.)ycombinator\.com$/.test(host)) return "+proxy";
        if (/(?:^|\.)duckduckgo\.com$/.test(host)) return "+proxy";
        if (/(?:^|\.)githubassets\.com$/.test(host)) return "+proxy";
        if (/^hellogithub\.com$/.test(host)) return "+proxy";
        if (/(?:^|\.)githubusercontent\.com$/.test(host)) return "+proxy";
        return "DIRECT";
    },
    "+proxy": function(url, host, scheme) {
        "use strict";
        if (/^127\.0\.0\.1$/.test(host) || /^::1$/.test(host) || /^localhost$/.test(host) || /^<local>  $/.test(host) || host.indexOf(":") >= 0 && (typeof isInNetEx === "function" ? isInNetEx(host, "fc00::/7") : isInNet(host, "fc00::", "fe00::")) || host.indexOf(":") >= 0 && (typeof isInNetEx === "function" ? isInNetEx(host, "fe80::/10") : isInNet(host, "fe80::", "ffc0::"))) return "DIRECT";
        return "PROXY 127.0.0.1:7897";
    }
});
