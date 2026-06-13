import { Controller } from "@hotwired/stimulus";

const CONSENT_KEY = "analytics_consent";
const ACCEPTED = "accepted";
const REJECTED = "rejected";

export default class extends Controller {
  static targets = ["banner"];

  static values = {
    apiKey: String,
    apiHost: String,
  };

  connect() {
    const consent = localStorage.getItem(CONSENT_KEY);

    if (window.posthog && this.apiKeyValue) {
      this.initPosthog();
    }

    this.applyConsentState(consent);
  }

  accept(event) {
    event.preventDefault();
    localStorage.setItem(CONSENT_KEY, ACCEPTED);
    this.enableAnalytics();
    this.hideBanner();
  }

  reject(event) {
    event.preventDefault();
    localStorage.setItem(CONSENT_KEY, REJECTED);
    this.disableAnalytics();
    this.hideBanner();
  }

  applyConsentState(consent) {
    if (consent === ACCEPTED) {
      this.enableAnalytics();
      this.hideBanner();
    } else if (consent === REJECTED) {
      this.disableAnalytics();
      this.hideBanner();
    } else {
      this.showBanner();
    }
  }

  initPosthog() {
    if (window.posthog.__loaded) return;

    window.posthog.init(this.apiKeyValue, {
      api_host: this.apiHostValue,
      cookieless_mode: "on_reject",
      person_profiles: "identified_only",
      opt_out_capturing_by_default: true,
      disable_session_recording: true,
    });
  }

  enableAnalytics() {
    if (!window.posthog) return;

    window.posthog.set_config({
      persistence: "localStorage+cookie",
      disable_session_recording: false,
    });
    window.posthog.opt_in_capturing();
    this.startSessionRecording();
  }

  disableAnalytics() {
    if (!window.posthog) return;

    this.stopSessionRecording();
    window.posthog.set_config({
      persistence: "memory",
      disable_session_recording: true,
    });
    window.posthog.opt_out_capturing();
  }

  startSessionRecording() {
    if (typeof window.posthog?.startSessionRecording === "function") {
      window.posthog.startSessionRecording();
    }
  }

  stopSessionRecording() {
    if (typeof window.posthog?.stopSessionRecording === "function") {
      window.posthog.stopSessionRecording();
    }
  }

  showBanner() {
    if (this.hasBannerTarget) {
      this.bannerTarget.classList.remove("hidden");
    }
  }

  hideBanner() {
    if (this.hasBannerTarget) {
      this.bannerTarget.classList.add("hidden");
    }
  }
}
