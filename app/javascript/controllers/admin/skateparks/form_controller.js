import Sortable from "sortablejs";
import { Controller } from "@hotwired/stimulus";

const ACTIVE_SORT_CLASSES = ["bg-neutral-50", "dark:bg-gray-800", "shadow-md"];
const DISABLED_BUTTON_CLASSES = ["cursor-not-allowed", "opacity-50"];
const SORTABLE_ITEM_SELECTOR = "[data-sortable-item]";
const VISIBLE_SORTABLE_ITEM_SELECTOR = `${SORTABLE_ITEM_SELECTOR}:not([data-destroyed='true'])`;
const YOUTUBE_VIDEO_ID_REGEX = /^[\w-]{11}$/;

export default class extends Controller {
  static targets = [
    "announcement",
    "countrySelect",
    "emptyState",
    "emptyVideoState",
    "newImagesInput",
    "newImageTemplate",
    "newVideoTemplate",
    "newVideoUrlError",
    "newVideoUrlInput",
    "sortableList",
    "sortableVideoList",
    "stateSelect",
  ];

  static values = {
    confirmDelete: String,
    confirmDeleteVideo: String,
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
    videoAltPattern: String,
    reorderVideoPattern: String,
    deleteVideoPattern: String,
    moveVideoUpPattern: String,
    moveVideoDownPattern: String,
    videoMovedPattern: String,
    videoRemoved: String,
    newVideoRemoved: String,
    videoAdded: String,
    invalidVideoUrl: String,
    duplicateVideoUrl: String,
  };

  connect() {
    this.itemElementCache = new WeakMap();
    this.pendingUploads = new Map();

    if (this.countrySelectTarget.value) {
      this.fetchStates(this.countrySelectTarget.value);
    }

    this.sortable = this.hasSortableListTarget ? this.createSortable(this.sortableListTarget) : null;
    this.videoSortable = this.hasSortableVideoListTarget ? this.createSortable(this.sortableVideoListTarget) : null;

    if (this.hasSortableListTarget) this.syncPositions("image");
    if (this.hasSortableVideoListTarget) this.syncPositions("video");
  }

  disconnect() {
    this.sortable?.destroy();
    this.videoSortable?.destroy();
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

  clearVideoUrlError() {
    if (!this.hasNewVideoUrlInputTarget) return;

    this.newVideoUrlInputTarget.removeAttribute("aria-describedby");
    this.newVideoUrlInputTarget.removeAttribute("aria-invalid");

    if (!this.hasNewVideoUrlErrorTarget) return;

    this.newVideoUrlErrorTarget.textContent = "";
    this.newVideoUrlErrorTarget.classList.add("hidden");
  }

  reportVideoUrlError(message) {
    if (!this.hasNewVideoUrlInputTarget || !this.hasNewVideoUrlErrorTarget) return;

    this.newVideoUrlInputTarget.setAttribute("aria-describedby", this.newVideoUrlErrorTarget.id);
    this.newVideoUrlInputTarget.setAttribute("aria-invalid", "true");
    this.newVideoUrlErrorTarget.textContent = message;
    this.newVideoUrlErrorTarget.classList.remove("hidden");
  }

  onNewImagesChange(event) {
    const files = [...event.target.files];
    if (files.length === 0) return;

    const startIndex = Math.max(0, this.visibleItems("image").length - 1);

    files.forEach((file) => this.appendNewImage(file));
    this.syncPositions("image", { startIndex });
    const message =
      files.length === 1 ? this.imagesAddedOneValue : this.imagesAddedOtherValue.replace("{count}", files.length);
    this.announce(message);
  }

  addVideo(event) {
    event.preventDefault();

    if (!this.hasNewVideoUrlInputTarget || !this.hasNewVideoTemplateTarget || !this.hasSortableVideoListTarget) {
      return;
    }

    const youtubeUrl = this.newVideoUrlInputTarget.value.trim();

    this.clearVideoUrlError();
    if (!youtubeUrl) return;

    const videoId = this.extractYouTubeVideoId(youtubeUrl);
    if (!videoId) {
      this.reportVideoUrlError(this.invalidVideoUrlValue);
      return;
    }

    if (this.videoAlreadyAdded(youtubeUrl)) {
      this.reportVideoUrlError(this.duplicateVideoUrlValue);
      return;
    }

    const startIndex = Math.max(0, this.visibleItems("video").length - 1);

    this.appendNewVideo(youtubeUrl, videoId);
    this.newVideoUrlInputTarget.value = "";
    this.syncPositions("video", { startIndex });
    this.announce(this.videoAddedValue);
  }

  removeImage(event) {
    const item = event.currentTarget.closest("[data-sortable-item]");
    if (!item) return;

    if (!window.confirm(this.confirmDeleteValue)) return;

    const currentIndex = this.visibleItems("image").indexOf(item);

    if (item.dataset.newUploadId) {
      this.removeNewUpload(item, currentIndex);
      return;
    }

    const destroyField = item.querySelector("[data-destroy-field]");
    if (destroyField) destroyField.value = "1";

    item.dataset.destroyed = "true";
    item.classList.add("hidden");
    this.syncPositions("image", { startIndex: currentIndex, syncNewImages: false });
    this.announce(this.imageRemovedValue);
  }

  removeVideo(event) {
    const item = event.currentTarget.closest("[data-sortable-item]");
    if (!item) return;

    if (!window.confirm(this.confirmDeleteVideoValue || this.confirmDeleteValue)) return;

    const currentIndex = this.visibleItems("video").indexOf(item);

    if (item.dataset.newRecord === "true") {
      item.remove();
      this.syncPositions("video", { startIndex: currentIndex });
      this.announce(this.newVideoRemovedValue);
      return;
    }

    const destroyField = item.querySelector("[data-destroy-field]");
    if (destroyField) destroyField.value = "1";

    item.dataset.destroyed = "true";
    item.classList.add("hidden");
    this.syncPositions("video", { startIndex: currentIndex });
    this.announce(this.videoRemovedValue);
  }

  moveItem(trigger, direction) {
    const item = trigger.closest("[data-sortable-item]");
    const resourceType = this.resourceTypeFor(item);
    const items = this.visibleItems(resourceType);
    const currentIndex = items.indexOf(item);
    const nextIndex = currentIndex + direction;

    if (currentIndex === -1 || !items[nextIndex]) return;

    if (direction < 0) {
      items[nextIndex].before(item);
    } else {
      items[nextIndex].after(item);
    }

    const visibleItems = this.visibleItems(resourceType);

    this.syncPositions(resourceType, {
      visibleItems,
      startIndex: Math.min(currentIndex, nextIndex),
      endIndex: Math.max(currentIndex, nextIndex),
      syncNewImages: resourceType === "image" && this.isNewUpload(item),
      syncEmptyState: false,
    });
    this.announceMove(resourceType, nextIndex + 1, visibleItems.length);
    trigger.focus();
  }

  syncPositions(
    resourceType,
    {
      visibleItems = this.visibleItems(resourceType),
      startIndex = 0,
      endIndex = visibleItems.length - 1,
      syncNewImages = true,
      syncEmptyState = true,
    } = {}
  ) {
    if (visibleItems.length > 0) {
      const normalizedStartIndex = Math.max(0, Math.min(startIndex, visibleItems.length - 1));
      const normalizedEndIndex = Math.max(normalizedStartIndex, Math.min(endIndex, visibleItems.length - 1));

      visibleItems.slice(normalizedStartIndex, normalizedEndIndex + 1).forEach((item, offset) => {
        this.syncItemPosition(item, normalizedStartIndex + offset, visibleItems.length);
      });
    }

    if (syncNewImages && resourceType === "image") this.syncNewImagesInput(visibleItems);
    if (syncEmptyState) this.syncEmptyState(resourceType, visibleItems);
  }

  updateMoveButtonState(button, disabled) {
    if (!button) return;
    if (button.disabled === disabled) return;

    button.disabled = disabled;
    DISABLED_BUTTON_CLASSES.forEach((className) => {
      button.classList.toggle(className, disabled);
    });
  }

  announceMove(resourceType, position, total) {
    if (!position || position <= 0) return;

    const { movedPattern } = this.patternsFor(resourceType);
    if (!movedPattern) return;

    this.announce(movedPattern.replace("{position}", position).replace("{total}", total));
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

    const resourceType = this.resourceTypeFor(item);
    const visibleItems = this.visibleItems(resourceType);

    this.syncPositions(resourceType, {
      visibleItems,
      startIndex: Math.min(oldIndex, newIndex),
      endIndex: Math.max(oldIndex, newIndex),
      syncNewImages: resourceType === "image" && this.isNewUpload(item),
      syncEmptyState: false,
    });
    this.announceMove(resourceType, newIndex + 1, visibleItems.length);
  }

  syncItemPosition(item, index, total) {
    const resourceType = this.resourceTypeFor(item);
    const patterns = this.patternsFor(resourceType);
    const { positionField, positionLabel, preview, handle, deleteButton, moveUpButton, moveDownButton } =
      this.itemElements(item);
    const position = index + 1;

    this.updateValue(positionField, position);
    this.updateText(positionLabel, position);
    this.updateAttribute(preview, "alt", patterns.altPattern.replace("{position}", position));
    this.updateAttribute(handle, "aria-label", patterns.reorderPattern.replace("{position}", position));
    this.updateAttribute(deleteButton, "aria-label", patterns.deletePattern.replace("{position}", position));
    this.updateAttribute(moveUpButton, "aria-label", patterns.moveUpPattern.replace("{position}", position));
    this.updateAttribute(moveDownButton, "aria-label", patterns.moveDownPattern.replace("{position}", position));

    this.updateMoveButtonState(moveUpButton, position === 1);
    this.updateMoveButtonState(moveDownButton, position === total);
  }

  itemElements(item) {
    const cachedElements = this.itemElementCache.get(item);
    if (cachedElements) return cachedElements;

    const elements = {
      positionField: item.querySelector("[data-position-field]"),
      positionLabel: item.querySelector("[data-position-label]"),
      preview: item.querySelector("[data-item-preview]"),
      handle: item.querySelector("[data-sort-handle]"),
      deleteButton: item.querySelector("[data-delete-button]"),
      moveUpButton: item.querySelector("[data-move-up-button]"),
      moveDownButton: item.querySelector("[data-move-down-button]"),
      videoUrlField: item.querySelector("[data-video-url-field]"),
      videoUrlLabel: item.querySelector("[data-video-url-label]"),
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
    const preview = fragment.querySelector("[data-item-preview]");
    const fileName = fragment.querySelector("[data-file-name]");

    item.dataset.newUploadId = uploadId;
    preview.src = objectUrl;
    fileName.textContent = file.name;

    this.pendingUploads.set(uploadId, { file, objectUrl });
    this.sortableListTarget.append(fragment);
  }

  appendNewVideo(youtubeUrl, videoId) {
    const fragment = this.newVideoTemplateTarget.content.cloneNode(true);
    const item = fragment.querySelector("[data-sortable-item]");
    const preview = fragment.querySelector("[data-item-preview]");
    const urlField = fragment.querySelector("[data-video-url-field]");
    const urlLabel = fragment.querySelector("[data-video-url-label]");

    item.dataset.newRecord = "true";
    preview.src = this.thumbnailUrlFor(videoId);
    urlField.value = youtubeUrl;
    urlLabel.textContent = youtubeUrl;

    this.sortableVideoListTarget.append(fragment);
  }

  videoAlreadyAdded(youtubeUrl) {
    return this.visibleItems("video").some((item) => this.videoUrlFor(item) === youtubeUrl);
  }

  videoUrlFor(item) {
    const { videoUrlField, videoUrlLabel } = this.itemElements(item);

    return videoUrlField?.value?.trim() || videoUrlLabel?.textContent?.trim() || "";
  }

  removeNewUpload(item, currentIndex = this.visibleItems("image").indexOf(item)) {
    const upload = this.pendingUploads.get(item.dataset.newUploadId);

    if (upload) {
      URL.revokeObjectURL(upload.objectUrl);
      this.pendingUploads.delete(item.dataset.newUploadId);
    }

    item.remove();
    this.syncPositions("image", { startIndex: currentIndex });
    this.announce(this.newImageRemovedValue);
  }

  syncNewImagesInput(visibleItems = this.visibleItems("image")) {
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

  syncEmptyState(resourceType, visibleItems = this.visibleItems(resourceType)) {
    const emptyState = this.emptyStateElement(resourceType);
    if (!emptyState) return;

    emptyState.classList.toggle("hidden", visibleItems.length > 0);
  }

  visibleItems(resourceType) {
    const listTarget = this.listTarget(resourceType);
    if (!listTarget) return [];

    return [...listTarget.querySelectorAll(VISIBLE_SORTABLE_ITEM_SELECTOR)];
  }

  isNewUpload(item) {
    return Boolean(item?.dataset.newUploadId);
  }

  resourceTypeFor(item) {
    return item?.dataset.resourceType || "image";
  }

  listTarget(resourceType) {
    if (resourceType === "video") {
      return this.hasSortableVideoListTarget ? this.sortableVideoListTarget : null;
    }

    return this.hasSortableListTarget ? this.sortableListTarget : null;
  }

  emptyStateElement(resourceType) {
    if (resourceType === "video") {
      return this.hasEmptyVideoStateTarget ? this.emptyVideoStateTarget : null;
    }

    return this.hasEmptyStateTarget ? this.emptyStateTarget : null;
  }

  patternsFor(resourceType) {
    if (resourceType === "video") {
      return {
        altPattern: this.videoAltPatternValue,
        reorderPattern: this.reorderVideoPatternValue,
        deletePattern: this.deleteVideoPatternValue,
        moveUpPattern: this.moveVideoUpPatternValue,
        moveDownPattern: this.moveVideoDownPatternValue,
        movedPattern: this.videoMovedPatternValue,
      };
    }

    return {
      altPattern: this.imageAltPatternValue,
      reorderPattern: this.reorderPatternValue,
      deletePattern: this.deletePatternValue,
      moveUpPattern: this.moveUpPatternValue,
      moveDownPattern: this.moveDownPatternValue,
      movedPattern: this.imageMovedPatternValue,
    };
  }

  createSortable(listTarget) {
    return Sortable.create(listTarget, {
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
  }

  extractYouTubeVideoId(url) {
    try {
      const parsedUrl = new URL(url);
      const host = parsedUrl.hostname.replace(/^www\./, "");
      const pathSegments = parsedUrl.pathname.split("/").filter(Boolean);

      let candidate;

      switch (host) {
        case "youtu.be":
          candidate = pathSegments[0];
          break;
        case "youtube.com":
        case "m.youtube.com":
          if (pathSegments[0] === "watch") {
            candidate = parsedUrl.searchParams.get("v");
          } else if (["shorts", "embed", "v"].includes(pathSegments[0])) {
            candidate = pathSegments[1];
          }
          break;
        case "youtube-nocookie.com":
          if (pathSegments[0] === "embed") candidate = pathSegments[1];
          break;
        default:
          candidate = null;
      }

      return YOUTUBE_VIDEO_ID_REGEX.test(candidate || "") ? candidate : null;
    } catch {
      return null;
    }
  }

  thumbnailUrlFor(videoId) {
    return `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`;
  }
}
