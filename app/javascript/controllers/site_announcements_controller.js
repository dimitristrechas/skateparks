import { Controller } from "@hotwired/stimulus";
import { filterDismissedAnnouncements, writeDismissal } from "lib/site_announcement_dismissals";

export default class extends Controller {
  static targets = ["item"];

  connect() {
    if (!this.element.isConnected) return;

    filterDismissedAnnouncements(this.element);
  }

  dismiss(event) {
    event.preventDefault();

    const item = event.currentTarget.closest("[data-site-announcements-target='item']");
    if (!item) return;

    const itemIndex = this.itemTargets.indexOf(item);
    const { announcementId, dismissToken } = item.dataset;

    const prefix = this.element.dataset.dismissKeyPrefix;

    writeDismissal(announcementId, dismissToken, prefix);
    item.remove();

    if (this.itemTargets.length === 0) {
      this.focusMainHeading();
      this.removeWrapperIfEmpty();
      return;
    }

    const focusIndex = Math.min(itemIndex, this.itemTargets.length - 1);
    this.itemTargets[focusIndex].querySelector("button")?.focus();
  }

  removeWrapperIfEmpty() {
    if (!this.element.isConnected) return;

    if (this.itemTargets.length === 0) {
      this.element.remove();
    }
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
