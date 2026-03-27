import Sortable from "sortablejs";
import { Controller } from "@hotwired/stimulus";

const ACTIVE_SORT_CLASSES = ["bg-neutral-50", "dark:bg-gray-800", "shadow-md"];
const DISABLED_BUTTON_CLASSES = ["cursor-not-allowed", "opacity-50"];

export default class extends Controller {
  static targets = [
    "announcement",
    "countrySelect",
    "emptyState",
    "newImagesInput",
    "newImageTemplate",
    "sortableList",
    "stateSelect",
  ];

  connect() {
    this.pendingUploads = new Map();

    if (this.countrySelectTarget.value) {
      this.fetchStates(this.countrySelectTarget.value);
    }

    if (!this.hasSortableListTarget) return;

    this.sortable = Sortable.create(this.sortableListTarget, {
      animation: 150,
      chosenClass: "shadow-md",
      draggable: "[data-sortable-item]:not([data-destroyed='true'])",
      forceFallback: true,
      ghostClass: "bg-neutral-50",
      handle: "[data-sort-handle]",
      onChoose: ({ item }) => this.toggleActiveSortClasses(item, true),
      onEnd: ({ item }) => {
        this.toggleActiveSortClasses(item, false);
        this.syncPositions();
        this.announceMove(item);
      },
      onUnchoose: ({ item }) => this.toggleActiveSortClasses(item, false),
    });

    this.syncPositions();
  }

  disconnect() {
    this.sortable?.destroy();
    this.pendingUploads.forEach(({ objectUrl }) => URL.revokeObjectURL(objectUrl));
  }

  onCountryChange(event) {
    if (event.target.value) {
      this.fetchStates(event.target.value);
    } else {
      this.stateSelectTarget.innerHTML = "";
      this.stateSelectTarget.disabled = true;
    }
  }

  fetchStates(countryCode) {
    fetch(`/admin/states/${countryCode}`)
      .then((response) => response.json())
      .then((states) => {
        this.stateSelectTarget.innerHTML = this.buildStateOptions(states);
        this.stateSelectTarget.disabled = false;
      });
  }

  buildStateOptions(states) {
    return Object.entries(states)
      .map(([code, state]) => {
        const selected = code === this.stateSelectTarget.value ? "selected" : "";

        return `<option ${selected} value="${code}">${state.name}</option>`;
      })
      .join("");
  }

  moveUp(event) {
    this.moveItem(event.currentTarget, -1);
  }

  moveDown(event) {
    this.moveItem(event.currentTarget, 1);
  }

  onNewImagesChange(event) {
    const files = [...event.target.files];
    if (files.length === 0) return;

    files.forEach((file) => this.appendNewImage(file));
    this.syncPositions();
    this.announce(`${files.length} image${files.length === 1 ? " was" : "s were"} added to the list`);
  }

  removeImage(event) {
    const item = event.currentTarget.closest("[data-sortable-item]");
    if (!item) return;

    if (!window.confirm("Do you really want to delete this image?")) return;

    if (item.dataset.newUploadId) {
      this.removeNewUpload(item);
      return;
    }

    const destroyField = item.querySelector("[data-destroy-field]");
    if (destroyField) destroyField.value = "1";

    item.dataset.destroyed = "true";
    item.classList.add("hidden");
    this.syncPositions();
    this.announce("Image removed from the list");
  }

  moveItem(trigger, direction) {
    const item = trigger.closest("[data-sortable-item]");
    const items = this.visibleItems;
    const currentIndex = items.indexOf(item);
    const nextIndex = currentIndex + direction;

    if (currentIndex === -1 || !items[nextIndex]) return;

    if (direction < 0) {
      items[nextIndex].before(item);
    } else {
      items[nextIndex].after(item);
    }

    this.syncPositions();
    this.announce(`Image moved to position ${nextIndex + 1} of ${this.visibleItems.length}`);
    trigger.focus();
  }

  syncPositions() {
    const visibleItems = this.visibleItems;

    visibleItems.forEach((item, index) => {
      const position = index + 1;
      const positionField = item.querySelector("[data-position-field]");
      const positionLabel = item.querySelector("[data-position-label]");
      const preview = item.querySelector("[data-image-preview]");
      const handle = item.querySelector("[data-sort-handle]");
      const deleteButton = item.querySelector("[data-delete-button]");
      const moveUpButton = item.querySelector("[data-move-up-button]");
      const moveDownButton = item.querySelector("[data-move-down-button]");

      if (positionField) positionField.value = position;
      if (positionLabel) positionLabel.textContent = position;
      if (preview) preview.alt = `Image ${position}`;
      if (handle) handle.setAttribute("aria-label", `Reorder image ${position}`);
      if (deleteButton) deleteButton.setAttribute("aria-label", `Delete image ${position}`);
      if (moveUpButton) moveUpButton.setAttribute("aria-label", `Move image ${position} up`);
      if (moveDownButton) moveDownButton.setAttribute("aria-label", `Move image ${position} down`);

      this.updateMoveButtonState(moveUpButton, position === 1);
      this.updateMoveButtonState(moveDownButton, position === visibleItems.length);
    });

    this.syncNewImagesInput(visibleItems);
    this.syncEmptyState(visibleItems);
  }

  updateMoveButtonState(button, disabled) {
    if (!button) return;

    button.disabled = disabled;
    DISABLED_BUTTON_CLASSES.forEach((className) => {
      button.classList.toggle(className, disabled);
    });
  }

  announceMove(item) {
    const position = this.visibleItems.indexOf(item) + 1;
    if (position <= 0) return;

    this.announce(`Image moved to position ${position} of ${this.visibleItems.length}`);
  }

  announce(message) {
    if (!this.hasAnnouncementTarget) return;

    this.announcementTarget.textContent = "";

    requestAnimationFrame(() => {
      this.announcementTarget.textContent = message;
    });
  }

  toggleActiveSortClasses(item, enabled) {
    ACTIVE_SORT_CLASSES.forEach((className) => {
      item.classList.toggle(className, enabled);
    });
  }

  appendNewImage(file) {
    const uploadId =
      typeof crypto !== "undefined" && typeof crypto.randomUUID === "function"
        ? crypto.randomUUID()
        : `${Date.now()}-${this.pendingUploads.size}`;
    const objectUrl = URL.createObjectURL(file);
    const fragment = this.newImageTemplateTarget.content.cloneNode(true);
    const item = fragment.querySelector("[data-sortable-item]");
    const preview = fragment.querySelector("[data-image-preview]");
    const fileName = fragment.querySelector("[data-file-name]");

    item.dataset.newUploadId = uploadId;
    preview.src = objectUrl;
    fileName.textContent = file.name;

    this.pendingUploads.set(uploadId, { file, objectUrl });
    this.sortableListTarget.append(fragment);
  }

  removeNewUpload(item) {
    const upload = this.pendingUploads.get(item.dataset.newUploadId);

    if (upload) {
      URL.revokeObjectURL(upload.objectUrl);
      this.pendingUploads.delete(item.dataset.newUploadId);
    }

    item.remove();
    this.syncPositions();
    this.announce("New image removed from the list");
  }

  syncNewImagesInput(visibleItems = this.visibleItems) {
    if (!this.hasNewImagesInputTarget || typeof DataTransfer === "undefined") return;

    const transfer = new DataTransfer();

    visibleItems
      .filter((item) => item.dataset.newUploadId)
      .forEach((item) => {
        const upload = this.pendingUploads.get(item.dataset.newUploadId);
        if (upload) transfer.items.add(upload.file);
      });

    this.newImagesInputTarget.files = transfer.files;
  }

  syncEmptyState(visibleItems = this.visibleItems) {
    if (!this.hasEmptyStateTarget) return;

    this.emptyStateTarget.classList.toggle("hidden", visibleItems.length > 0);
  }

  get visibleItems() {
    if (!this.hasSortableListTarget) return [];

    return [...this.sortableListTarget.querySelectorAll("[data-sortable-item]")].filter(
      (item) => item.dataset.destroyed !== "true"
    );
  }
}
