import { Controller } from "@hotwired/stimulus";

const DEBOUNCE_MS = 180;
const ANNOUNCE_DELAY_MS = 250;

export default class extends Controller {
  static targets = ["hiddenInput", "input", "listbox", "error", "status"];

  static values = {
    searchUrl: String,
    required: Boolean,
    noResultsText: String,
    resultsCountOne: String,
    resultsCountOther: String,
    selectionRequired: String,
  };

  connect() {
    this.activeIndex = -1;
    this.items = [];
    this.abortController = null;
    this.debounceTimer = null;
    this.announceTimer = null;
    this.selectedName = this.hasInputTarget ? this.inputTarget.value : "";
    this.parentForm = this.requiredValue ? this.element.closest("form") : null;
    if (this.parentForm) {
      this.parentForm.addEventListener("submit", this.onFormSubmit);
    }
  }

  disconnect() {
    if (this.parentForm) {
      this.parentForm.removeEventListener("submit", this.onFormSubmit);
      this.parentForm = null;
    }
    this.cancelPendingWork();
  }

  onFormSubmit = (event) => {
    if (!this.validateSelection()) {
      event.preventDefault();
    }
  };

  onFocus() {
    this.clearError();
    this.scheduleSearch(this.inputTarget.value.trim(), 0);
  }

  onInput() {
    this.clearError();
    const currentText = this.inputTarget.value;
    if (this.hasHiddenInputTarget && currentText !== this.selectedName) {
      this.hiddenInputTarget.value = "";
    }

    this.scheduleSearch(currentText.trim(), DEBOUNCE_MS);
  }

  onBlur() {
    window.setTimeout(() => {
      if (!this.element.contains(document.activeElement)) {
        this.closeListbox();
      }
    }, 150);
  }

  onKeydown(event) {
    if (event.key === "ArrowDown") {
      event.preventDefault();
      if (!this.isListboxOpen()) {
        this.scheduleSearch(this.inputTarget.value.trim(), 0);
        return;
      }
      this.moveActiveIndex(1);
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      if (!this.isListboxOpen()) return;
      this.moveActiveIndex(-1);
    } else if (event.key === "Enter") {
      if (this.isListboxOpen() && this.activeIndex >= 0 && this.items[this.activeIndex]) {
        event.preventDefault();
        this.commitSelection(this.items[this.activeIndex]);
      }
    } else if (event.key === "Escape") {
      if (this.isListboxOpen()) {
        event.preventDefault();
        event.stopPropagation();
        this.closeListbox();
      }
    }
  }

  selectOption(event) {
    event.preventDefault();
    const option = event.currentTarget;
    const index = Number.parseInt(option.dataset.index, 10);
    const item = this.items[index];
    if (item) {
      this.commitSelection(item);
    }
  }

  setSelection(id, name) {
    this.clearError();
    this.selectedName = name || "";
    if (this.hasHiddenInputTarget) {
      this.hiddenInputTarget.value = id || "";
    }
    if (this.hasInputTarget) {
      this.inputTarget.value = name || "";
    }
    this.closeListbox();
  }

  validateSelection() {
    if (this.hasHiddenInputTarget && this.hiddenInputTarget.value) {
      this.clearError();
      return true;
    }

    this.reportError(this.selectionRequiredValue);
    return false;
  }

  scheduleSearch(query, delay) {
    if (this.debounceTimer) {
      window.clearTimeout(this.debounceTimer);
    }

    this.debounceTimer = window.setTimeout(() => {
      this.performSearch(query);
    }, delay);
  }

  async performSearch(query) {
    if (!this.hasSearchUrlValue) return;

    if (this.abortController) {
      this.abortController.abort();
    }
    this.abortController = new AbortController();

    const url = new URL(this.searchUrlValue, window.location.origin);
    url.searchParams.set("q", query);

    try {
      const response = await fetch(url.toString(), {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal,
      });
      if (!response.ok) return;

      const items = await response.json();
      this.renderResults(Array.isArray(items) ? items : []);
    } catch (error) {
      if (error.name !== "AbortError") {
        this.closeListbox();
      }
    }
  }

  renderResults(items) {
    if (!this.hasListboxTarget || !this.hasInputTarget) return;

    this.items = items;
    this.activeIndex = items.length > 0 ? 0 : -1;
    this.listboxTarget.innerHTML = "";

    if (items.length === 0) {
      const emptyItem = document.createElement("li");
      emptyItem.setAttribute("role", "presentation");
      emptyItem.className = "px-3 py-2 text-sm text-neutral-500 dark:text-neutral-400";
      emptyItem.textContent = this.noResultsTextValue;
      this.listboxTarget.appendChild(emptyItem);
      this.openListbox();
      this.inputTarget.removeAttribute("aria-activedescendant");
      this.announceStatus(this.noResultsTextValue);
      return;
    }

    items.forEach((item, index) => {
      const option = document.createElement("li");
      option.id = `${this.listboxTarget.id}-option-${index}`;
      option.setAttribute("role", "option");
      option.setAttribute("aria-selected", index === this.activeIndex ? "true" : "false");
      option.dataset.id = String(item.id);
      option.dataset.name = item.name;
      option.dataset.index = String(index);
      option.dataset.action = "mousedown->admin--skatepark-picker#selectOption";
      option.className = this.optionClasses(index === this.activeIndex);

      const nameSpan = document.createElement("span");
      nameSpan.className = "font-medium";
      nameSpan.textContent = item.name;
      option.appendChild(nameSpan);

      if (item.location_name) {
        const locationSpan = document.createElement("span");
        locationSpan.className = "ml-2 text-xs text-neutral-500 dark:text-neutral-400";
        locationSpan.textContent = item.location_name;
        option.appendChild(locationSpan);
      }

      this.listboxTarget.appendChild(option);
    });

    this.openListbox();
    this.syncActiveOption();
    this.announceResultsCount(items.length);
  }

  moveActiveIndex(delta) {
    if (this.items.length === 0) return;

    const total = this.items.length;
    this.activeIndex = (this.activeIndex + delta + total) % total;
    this.syncActiveOption();
  }

  syncActiveOption() {
    if (!this.hasListboxTarget || !this.hasInputTarget) return;

    const options = this.listboxTarget.querySelectorAll('[role="option"]');
    options.forEach((option, index) => {
      const isActive = index === this.activeIndex;
      option.setAttribute("aria-selected", isActive ? "true" : "false");
      option.className = this.optionClasses(isActive);
      if (isActive) {
        this.inputTarget.setAttribute("aria-activedescendant", option.id);
        if (typeof option.scrollIntoView === "function") {
          option.scrollIntoView({ block: "nearest" });
        }
      }
    });
  }

  commitSelection(item) {
    this.selectedName = item.name;
    if (this.hasHiddenInputTarget) {
      this.hiddenInputTarget.value = String(item.id);
    }
    if (this.hasInputTarget) {
      this.inputTarget.value = item.name;
    }
    this.clearError();
    this.cancelPendingWork();
    this.closeListbox();
    this.dispatch("selected", { detail: { id: item.id, name: item.name } });
  }

  optionClasses(isActive) {
    const base = "cursor-pointer px-3 py-2 text-sm text-neutral-800 dark:text-neutral-100";
    if (isActive) {
      return `${base} bg-neutral-100 dark:bg-neutral-700`;
    }
    return `${base} hover:bg-neutral-100 dark:hover:bg-neutral-700`;
  }

  isListboxOpen() {
    return this.hasListboxTarget && !this.listboxTarget.classList.contains("hidden");
  }

  openListbox() {
    if (!this.hasListboxTarget || !this.hasInputTarget) return;

    this.listboxTarget.classList.remove("hidden");
    this.inputTarget.setAttribute("aria-expanded", "true");
  }

  closeListbox() {
    if (!this.hasListboxTarget || !this.hasInputTarget) return;

    this.listboxTarget.classList.add("hidden");
    this.inputTarget.setAttribute("aria-expanded", "false");
    this.inputTarget.removeAttribute("aria-activedescendant");
    this.activeIndex = -1;
  }

  announceResultsCount(count) {
    const message =
      count === 1 ? this.resultsCountOneValue : this.resultsCountOtherValue.replace("{count}", String(count));
    this.announceStatus(message);
  }

  announceStatus(message) {
    if (!this.hasStatusTarget) return;

    if (this.announceTimer) {
      window.clearTimeout(this.announceTimer);
    }

    this.announceTimer = window.setTimeout(() => {
      if (this.hasStatusTarget) {
        this.statusTarget.textContent = message;
      }
    }, ANNOUNCE_DELAY_MS);
  }

  clearError() {
    if (!this.hasInputTarget) return;

    this.inputTarget.removeAttribute("aria-describedby");
    this.inputTarget.removeAttribute("aria-invalid");

    if (!this.hasErrorTarget) return;

    this.errorTarget.textContent = "";
    this.errorTarget.classList.add("hidden");
  }

  reportError(message) {
    if (!this.hasInputTarget || !this.hasErrorTarget) return;

    this.inputTarget.setAttribute("aria-describedby", this.errorTarget.id);
    this.inputTarget.setAttribute("aria-invalid", "true");
    this.errorTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
    this.inputTarget.focus();
  }

  cancelPendingWork() {
    if (this.debounceTimer) {
      window.clearTimeout(this.debounceTimer);
      this.debounceTimer = null;
    }
    if (this.announceTimer) {
      window.clearTimeout(this.announceTimer);
      this.announceTimer = null;
    }
    if (this.abortController) {
      this.abortController.abort();
      this.abortController = null;
    }
  }
}
