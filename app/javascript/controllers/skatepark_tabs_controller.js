import { Controller } from "@hotwired/stimulus";

const ACTIVE_TAB_CLASSES = ["border-neutral-900", "text-neutral-900", "dark:border-white", "dark:text-white"];
const INACTIVE_TAB_CLASSES = ["border-transparent", "text-neutral-500", "dark:text-neutral-400"];

export default class extends Controller {
  static targets = ["panel", "tab"];

  static values = {
    defaultTab: String,
  };

  connect() {
    this.showTab(this.initialTab(), { updateHash: false });
  }

  switchTab(event) {
    event.preventDefault();

    this.showTab(event.currentTarget.dataset.tab);
  }

  onKeydown(event) {
    if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return;

    event.preventDefault();

    const currentIndex = this.tabTargets.indexOf(event.currentTarget);
    if (currentIndex === -1) return;

    let nextIndex = currentIndex;

    if (event.key === "ArrowRight") {
      nextIndex = (currentIndex + 1) % this.tabTargets.length;
    } else if (event.key === "ArrowLeft") {
      nextIndex = (currentIndex - 1 + this.tabTargets.length) % this.tabTargets.length;
    } else if (event.key === "Home") {
      nextIndex = 0;
    } else if (event.key === "End") {
      nextIndex = this.tabTargets.length - 1;
    }

    const nextTab = this.tabTargets[nextIndex];

    this.showTab(nextTab.dataset.tab);
    nextTab.focus();
  }

  showTab(tabName, { updateHash = true } = {}) {
    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.tab === tabName;

      tab.setAttribute("aria-selected", isActive);
      tab.setAttribute("tabindex", isActive ? "0" : "-1");

      ACTIVE_TAB_CLASSES.forEach((className) => {
        tab.classList.toggle(className, isActive);
      });

      INACTIVE_TAB_CLASSES.forEach((className) => {
        tab.classList.toggle(className, !isActive);
      });
    });

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.tab !== tabName);
    });

    if (updateHash) this.updateHash(tabName);
  }

  initialTab() {
    const hashTab = window.location.hash.replace("#", "");
    if (this.tabTargets.some((tab) => tab.dataset.tab === hashTab)) return hashTab;

    return this.defaultTabValue || this.tabTargets[0]?.dataset.tab;
  }

  updateHash(tabName) {
    const url = new URL(window.location.href);
    url.hash = tabName;

    window.history.replaceState({}, "", url);
  }
}
