// Restore Compact Mode - 89 Above
user_pref("browser.compactmode.show", true);

// about:home Search Bar - 89 Above
user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);

// Disable "Slow startup" warnings and associated disk history
// (bug #13346)
user_pref("browser.slowStartup.notificationDisabled", true);
user_pref("browser.slowStartup.maxSamples", 0);
user_pref("browser.slowStartup.samples", 0);

// Disable the "Refresh" prompt that is displayed for stale profiles.
user_pref("browser.disableResetPrompt", true);

user_pref("browser.send_pings", false);

// Disable the Pocket extension (Bug #18886 and #31602)
user_pref("extensions.pocket.enabled", false);
user_pref("network.http.referer.hideOnionSource", true);

// Disable use of WiFi location information
user_pref("browser.region.network.scan", false);
user_pref("browser.region.network.url", "");

user_pref("dom.enable_resource_timing", false);
user_pref("dom.w3c_touch_events.enabled", 0);
user_pref("dom.vr.enabled", false);
user_pref("dom.netinfo.enabled", false);

// Enable Webrender
user_pref("gfx.webrender.all", true);
user_pref("gfx.x11-egl.force-enabled", true);

//Enable VAAPI support
user_pref("media.ffmpeg.vaapi.enabled", true);

//Fix webrtc
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.peerconnection.ice.no_host", true);

//Disable pocket
user_pref("extensions.pocket.enabled", false);

//Fix activitystream
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

//Disable accessibility features for better performance
user_pref("accessibility.force_disabled", 1);

user_pref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");

user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("network.prefetch-next", false);

//security
user_pref("dom.security.https_only_mode", true);
user_pref("security.ssl.require_safe_negotiation", true);
user_pref("security.pki.sha1_enforcement_level", 1);
user_pref("security.family_safety.mode", 0);
user_pref("security.cert_pinning.enforcement_level", 2);

user_pref("devtools.debugger.remote-enabled", false);
user_pref("browser.contentblocking.category", "strict");
user_pref("privacy.partition.serviceWorkers", true);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

