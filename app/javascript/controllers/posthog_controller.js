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
    if (!window.posthog) return;

    const consent = localStorage.getItem(CONSENT_KEY);

    if (consent === ACCEPTED) {
      this.initPosthog({ persistence: "localStorage+cookie", optOut: false, sessionRecording: true });
      this.hideBanner();
    } else if (consent === REJECTED) {
      this.initPosthog({ persistence: "memory", optOut: true, sessionRecording: false });
      this.hideBanner();
    } else {
      this.initPosthog({ persistence: "memory", optOut: true, sessionRecording: false });
      this.showBanner();
    }
  }

  accept(event) {
    event.preventDefault();
    localStorage.setItem(CONSENT_KEY, ACCEPTED);
    window.posthog.set_config({ persistence: "localStorage+cookie", disable_session_recording: false });
    window.posthog.opt_in_capturing();
    this.startSessionRecording();
    this.hideBanner();
  }

  reject(event) {
    event.preventDefault();
    localStorage.setItem(CONSENT_KEY, REJECTED);
    window.posthog.opt_out_capturing();
    this.hideBanner();
  }

  openSettings(event) {
    event.preventDefault();
    this.showBanner();
    if (this.hasBannerTarget) {
      this.bannerTarget.scrollIntoView({ behavior: "smooth", block: "end" });
      this.bannerTarget.focus({ preventScroll: true });
    }
  }

  initPosthog({ persistence, optOut, sessionRecording }) {
    window.posthog.init(this.apiKeyValue, {
      api_host: this.apiHostValue,
      persistence,
      person_profiles: "identified_only",
      opt_out_capturing_by_default: optOut,
      disable_session_recording: !sessionRecording,
    });

    if (!optOut) {
      window.posthog.opt_in_capturing();
    }

    if (sessionRecording) {
      this.startSessionRecording();
    }
  }

  startSessionRecording() {
    if (typeof window.posthog.startSessionRecording === "function") {
      window.posthog.startSessionRecording();
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
