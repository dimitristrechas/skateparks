import { Controller } from "@hotwired/stimulus";

const swipeThreshold = 50;

export default class extends Controller {
  static targets = ["container", "previewImage", "gallery", "galleryImage", "galleryImageIndicator", "announcer"];

  static values = {
    lat: String,
    lng: String,
    announcementPattern: String,
  };

  connect() {
    this.imageIndexOpened = 0;
    this.touchstartX = 0;
    this.touchstartY = 0;
    this.isMultiTouchGesture = false;
    this.lastFocusedElement = null;
    this.focusableElements = null;

    import("leaflet").then(({ Map, TileLayer, Marker }) => {
      this.map = new Map(this.containerTarget, {
        zoomDelta: 0.5,
        zoomSnap: 0.5,
      }).setView([this.latValue, this.lngValue], 20);

      new TileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      }).addTo(this.map);

      new Marker([this.latValue, this.lngValue]).addTo(this.map);
    });
  }

  galleryTargetConnected() {
    document.addEventListener("keydown", this.modalKeysHandler);
    document.addEventListener("keydown", this.focusTrapHandler);
    document.addEventListener("touchstart", this.galleryTouchStartHandler);
    document.addEventListener("touchend", this.galleryTouchEndHandler);
  }

  galleryTargetDisconnected() {
    document.removeEventListener("keydown", this.modalKeysHandler);
    document.removeEventListener("keydown", this.focusTrapHandler);
    document.removeEventListener("touchstart", this.galleryTouchStartHandler);
    document.removeEventListener("touchend", this.galleryTouchEndHandler);
  }

  onGalleryImageIndicatorClick(event) {
    this.hideGalleryImage(this.imageIndexOpened);
    this.galleryImageIndicatorTargets.forEach((img, idx) => {
      if (img.id === event.target.id) {
        this.imageIndexOpened = idx;
      }
    });
    this.showGalleryImage(this.imageIndexOpened);
  }

  onImageClick(event) {
    this.lastFocusedElement = event.currentTarget;

    this.previewImageTargets.forEach((img, idx) => {
      if (img.id === event.currentTarget.id) {
        this.imageIndexOpened = idx;
      }
    });

    this.galleryTarget.classList.remove("hidden");
    this.galleryTarget.classList.add("flex");

    this.showGalleryImage(this.imageIndexOpened);
    window.document.body.classList.add("overflow-hidden");

    requestAnimationFrame(() => {
      this.setupFocusTrap();
      this.focusFirstModalElement();
    });
  }

  setupFocusTrap() {
    const focusableSelectors = 'button:not([disabled]), [tabindex]:not([tabindex="-1"])';
    this.focusableElements = Array.from(this.galleryTarget.querySelectorAll(focusableSelectors)).filter(
      (element) => element.getClientRects().length > 0
    );
  }

  focusFirstModalElement() {
    if (this.focusableElements && this.focusableElements.length > 0) {
      this.focusableElements[0].focus();
    }
  }

  focusTrapHandler = (event) => {
    if (event.key !== "Tab" || !this.focusableElements || this.focusableElements.length === 0) {
      return;
    }

    const firstElement = this.focusableElements[0];
    const lastElement = this.focusableElements[this.focusableElements.length - 1];

    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault();
      lastElement.focus();
    } else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault();
      firstElement.focus();
    }
  };

  onPreviousGalleryImage() {
    this.hideGalleryImage(this.imageIndexOpened);
    if (this.imageIndexOpened === 0) {
      this.imageIndexOpened = this.galleryImageTargets.length - 1;
    } else {
      this.imageIndexOpened--;
    }
    this.showGalleryImage(this.imageIndexOpened);
  }

  onNextGalleryImage() {
    this.hideGalleryImage(this.imageIndexOpened);
    if (this.imageIndexOpened === this.galleryImageTargets.length - 1) {
      this.imageIndexOpened = 0;
    } else {
      this.imageIndexOpened++;
    }
    this.showGalleryImage(this.imageIndexOpened);
  }

  showGalleryImage(idx) {
    this.galleryImageTargets[idx].classList.remove("hidden");
    this.galleryImageIndicatorTargets[idx].classList.remove("opacity-50");
    this.galleryImageIndicatorTargets[idx].classList.add("opacity-100", "scale-125");

    if (this.hasAnnouncerTarget && this.hasAnnouncementPatternValue) {
      this.announcerTarget.textContent = this.announcementPatternValue
        .replace("{current}", idx + 1)
        .replace("{total}", this.galleryImageTargets.length);
    }
  }

  hideGalleryImage(idx) {
    this.galleryImageTargets[idx].classList.add("hidden");
    this.galleryImageIndicatorTargets[idx].classList.add("opacity-50");
    this.galleryImageIndicatorTargets[idx].classList.remove("opacity-100", "scale-125");
  }

  onModalClose() {
    this.hideModalElements();
  }

  modalKeysHandler = (event) => {
    if (event.keyCode === 27) {
      this.onModalClose();
    } else if (event.code === "ArrowRight") {
      this.onNextGalleryImage();
    } else if (event.code === "ArrowLeft") {
      this.onPreviousGalleryImage();
    }
  };

  galleryTouchStartHandler = (event) => {
    if (event.touches.length > 1) {
      this.isMultiTouchGesture = true;
      return;
    }
    this.isMultiTouchGesture = false;
    this.touchstartX = event.changedTouches[0].screenX;
    this.touchstartY = event.changedTouches[0].screenY;
  };

  galleryTouchEndHandler = (event) => {
    if (this.isMultiTouchGesture) {
      if (event.touches.length === 0) {
        this.isMultiTouchGesture = false;
      }
      return;
    }
    if (event.changedTouches.length > 1) return;

    const touchendX = event.changedTouches[0].screenX;
    const touchendY = event.changedTouches[0].screenY;

    const swipeX = touchendX - this.touchstartX;
    const swipeY = touchendY - this.touchstartY;

    if (Math.abs(swipeX) > Math.abs(swipeY) && Math.abs(swipeX) > swipeThreshold) {
      if (swipeX > 0) {
        this.onPreviousGalleryImage();
      } else {
        this.onNextGalleryImage();
      }
    }
  };

  disconnect() {
    this.map.remove();
    document.removeEventListener("keydown", this.modalKeysHandler);
    document.removeEventListener("keydown", this.focusTrapHandler);
    document.removeEventListener("touchstart", this.galleryTouchStartHandler);
    document.removeEventListener("touchend", this.galleryTouchEndHandler);
    this.hideModalElements();
  }

  hideModalElements() {
    this.galleryTarget.classList.add("hidden");
    this.galleryTarget.classList.remove("flex");
    this.galleryImageTargets.forEach((img) => img.classList.add("hidden"));
    this.galleryImageIndicatorTargets.forEach((img) => img.classList.add("opacity-50"));
    this.galleryImageIndicatorTargets.forEach((img) => img.classList.remove("opacity-100", "scale-125"));
    window.document.body.classList.remove("overflow-hidden");

    if (this.lastFocusedElement) {
      this.lastFocusedElement.focus();
      this.lastFocusedElement = null;
    }

    this.focusableElements = null;
  }
}
