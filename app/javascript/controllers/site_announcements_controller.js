import { Controller } from "@hotwired/stimulus";
import { attachDismissListeners, filterDismissedAnnouncements } from "lib/site_announcement_dismissals";

export default class extends Controller {
  static targets = ["item"];

  connect() {
    if (!this.element.isConnected) return;

    filterDismissedAnnouncements(this.element);
    attachDismissListeners(this.element);
    this.handleDismissed = this.handleDismissed.bind(this);
    this.element.addEventListener("site-announcements:dismissed", this.handleDismissed);
  }

  disconnect() {
    this.element.removeEventListener("site-announcements:dismissed", this.handleDismissed);
  }

  handleDismissed({ detail: { itemIndex, regionRemoved } }) {
    if (regionRemoved) {
      this.focusMainHeading();
      return;
    }

    if (this.itemTargets.length === 0) {
      this.focusMainHeading();
      return;
    }

    const focusIndex = Math.min(itemIndex, this.itemTargets.length - 1);
    this.itemTargets[focusIndex].querySelector("[data-site-announcements-dismiss-button]")?.focus();
  }

  focusMainHeading() {
    const heading = document.querySelector("main h1");
    if (!heading) return;

    if (!heading.hasAttribute("tabindex")) {
      heading.setAttribute("tabindex", "-1");
    }

    heading.focus();
  }
}
