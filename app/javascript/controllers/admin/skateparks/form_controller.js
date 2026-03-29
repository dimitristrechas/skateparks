import Sortable from "sortablejs";
import { Controller } from "@hotwired/stimulus";

const ACTIVE_SORT_CLASSES = ["bg-neutral-50", "dark:bg-gray-800", "shadow-md"];
const DISABLED_BUTTON_CLASSES = ["cursor-not-allowed", "opacity-50"];
const SORTABLE_ITEM_SELECTOR = "[data-sortable-item]";
const VISIBLE_SORTABLE_ITEM_SELECTOR = `${SORTABLE_ITEM_SELECTOR}:not([data-destroyed='true'])`;

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

  static values = {
    confirmDelete: String,
    imageAltPattern: String,
    reorderPattern: String,
    deletePattern: String,
    moveUpPattern: String,
    moveDownPattern: String,
    imageMovedPattern: String,
    imageRemoved: String,
    newImageRemoved: String,
    imagesAddedOne: String,
    imagesAddedOther: String,
  };

  connect() {
    this.itemElementCache = new WeakMap();
    this.pendingUploads = new Map();

    if (this.countrySelectTarget.value) {
      this.fetchStates(this.countrySelectTarget.value);
    }

    if (!this.hasSortableListTarget) return;

    this.sortable = Sortable.create(this.sortableListTarget, {
      animation: 150,
      chosenClass: "shadow-md",
      draggable: VISIBLE_SORTABLE_ITEM_SELECTOR,
      forceFallback: true,
      ghostClass: "bg-neutral-50",
      handle: "[data-sort-handle]",
      onChoose: ({ item }) => this.toggleActiveSortClasses(item, true),
      onEnd: ({ item }) => {
        this.toggleActiveSortClasses(item, false);
      },
      onUnchoose: ({ item }) => this.toggleActiveSortClasses(item, false),
      onUpdate: ({ item, oldDraggableIndex, newDraggableIndex, oldIndex, newIndex }) => {
        this.syncReorderedItems(item, oldDraggableIndex ?? oldIndex, newDraggableIndex ?? newIndex);
      },
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

    const startIndex = Math.max(0, this.visibleItems.length - 1);

    files.forEach((file) => this.appendNewImage(file));
    this.syncPositions({ startIndex });
    const message =
      files.length === 1 ? this.imagesAddedOneValue : this.imagesAddedOtherValue.replace("{count}", files.length);
    this.announce(message);
  }

  removeImage(event) {
    const item = event.currentTarget.closest("[data-sortable-item]");
    if (!item) return;

    if (!window.confirm(this.confirmDeleteValue)) return;

    const currentIndex = this.visibleItems.indexOf(item);

    if (item.dataset.newUploadId) {
      this.removeNewUpload(item, currentIndex);
      return;
    }

    const destroyField = item.querySelector("[data-destroy-field]");
    if (destroyField) destroyField.value = "1";

    item.dataset.destroyed = "true";
    item.classList.add("hidden");
    this.syncPositions({ startIndex: currentIndex, syncNewImages: false });
    this.announce(this.imageRemovedValue);
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

    const visibleItems = this.visibleItems;

    this.syncPositions({
      visibleItems,
      startIndex: Math.min(currentIndex, nextIndex),
      endIndex: Math.max(currentIndex, nextIndex),
      syncNewImages: this.isNewUpload(item),
      syncEmptyState: false,
    });
    this.announceMove(nextIndex + 1, visibleItems.length);
    trigger.focus();
  }

  syncPositions({
    visibleItems = this.visibleItems,
    startIndex = 0,
    endIndex = visibleItems.length - 1,
    syncNewImages = true,
    syncEmptyState = true,
  } = {}) {
    if (visibleItems.length > 0) {
      const normalizedStartIndex = Math.max(0, Math.min(startIndex, visibleItems.length - 1));
      const normalizedEndIndex = Math.max(normalizedStartIndex, Math.min(endIndex, visibleItems.length - 1));

      visibleItems.slice(normalizedStartIndex, normalizedEndIndex + 1).forEach((item, offset) => {
        this.syncItemPosition(item, normalizedStartIndex + offset, visibleItems.length);
      });
    }

    if (syncNewImages) this.syncNewImagesInput(visibleItems);
    if (syncEmptyState) this.syncEmptyState(visibleItems);
  }

  updateMoveButtonState(button, disabled) {
    if (!button) return;
    if (button.disabled === disabled) return;

    button.disabled = disabled;
    DISABLED_BUTTON_CLASSES.forEach((className) => {
      button.classList.toggle(className, disabled);
    });
  }

  announceMove(position, total) {
    if (!position || position <= 0) return;
    this.announce(this.imageMovedPatternValue.replace("{position}", position).replace("{total}", total));
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

  syncReorderedItems(item, oldIndex, newIndex) {
    if (oldIndex == null || newIndex == null || oldIndex === newIndex) return;

    const visibleItems = this.visibleItems;

    this.syncPositions({
      visibleItems,
      startIndex: Math.min(oldIndex, newIndex),
      endIndex: Math.max(oldIndex, newIndex),
      syncNewImages: this.isNewUpload(item),
      syncEmptyState: false,
    });
    this.announceMove(newIndex + 1, visibleItems.length);
  }

  syncItemPosition(item, index, total) {
    const position = index + 1;
    const { positionField, positionLabel, preview, handle, deleteButton, moveUpButton, moveDownButton } =
      this.itemElements(item);

    this.updateValue(positionField, position);
    this.updateText(positionLabel, position);
    this.updateAttribute(preview, "alt", this.imageAltPatternValue.replace("{position}", position));
    this.updateAttribute(handle, "aria-label", this.reorderPatternValue.replace("{position}", position));
    this.updateAttribute(deleteButton, "aria-label", this.deletePatternValue.replace("{position}", position));
    this.updateAttribute(moveUpButton, "aria-label", this.moveUpPatternValue.replace("{position}", position));
    this.updateAttribute(moveDownButton, "aria-label", this.moveDownPatternValue.replace("{position}", position));

    this.updateMoveButtonState(moveUpButton, position === 1);
    this.updateMoveButtonState(moveDownButton, position === total);
  }

  itemElements(item) {
    const cachedElements = this.itemElementCache.get(item);
    if (cachedElements) return cachedElements;

    const elements = {
      positionField: item.querySelector("[data-position-field]"),
      positionLabel: item.querySelector("[data-position-label]"),
      preview: item.querySelector("[data-image-preview]"),
      handle: item.querySelector("[data-sort-handle]"),
      deleteButton: item.querySelector("[data-delete-button]"),
      moveUpButton: item.querySelector("[data-move-up-button]"),
      moveDownButton: item.querySelector("[data-move-down-button]"),
    };

    this.itemElementCache.set(item, elements);

    return elements;
  }

  updateValue(element, value) {
    if (!element) return;

    const nextValue = String(value);
    if (element.value !== nextValue) element.value = nextValue;
  }

  updateText(element, value) {
    if (!element) return;

    const nextValue = String(value);
    if (element.textContent !== nextValue) element.textContent = nextValue;
  }

  updateAttribute(element, attributeName, value) {
    if (!element) return;
    if (element.getAttribute(attributeName) === value) return;

    element.setAttribute(attributeName, value);
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

  removeNewUpload(item, currentIndex = this.visibleItems.indexOf(item)) {
    const upload = this.pendingUploads.get(item.dataset.newUploadId);

    if (upload) {
      URL.revokeObjectURL(upload.objectUrl);
      this.pendingUploads.delete(item.dataset.newUploadId);
    }

    item.remove();
    this.syncPositions({ startIndex: currentIndex });
    this.announce(this.newImageRemovedValue);
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

    return [...this.sortableListTarget.querySelectorAll(VISIBLE_SORTABLE_ITEM_SELECTOR)];
  }

  isNewUpload(item) {
    return Boolean(item?.dataset.newUploadId);
  }
}
