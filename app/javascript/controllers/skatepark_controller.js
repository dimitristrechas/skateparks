import { Controller } from "@hotwired/stimulus";

const swipeThreshold = 50;

export default class extends Controller {
  static targets = [
    "announcer",
    "container",
    "gallery",
    "galleryImage",
    "galleryImageIndicator",
    "previewImage",
    "previewVideo",
    "videoIframe",
    "videoModal",
  ];

  static values = {
    lat: String,
    lng: String,
    announcementPattern: String,
  };

  connect() {
    this.imageIndexOpened = 0;
    this.videoIndexOpened = 0;
    this.touchstartX = 0;
    this.touchstartY = 0;
    this.isMultiTouchGesture = false;
    this.lastFocusedElement = null;
    this.focusableElements = null;
    this.activeModal = null;

    document.addEventListener("keydown", this.modalKeysHandler);
    document.addEventListener("keydown", this.focusTrapHandler);
    document.addEventListener("touchstart", this.galleryTouchStartHandler);
    document.addEventListener("touchend", this.galleryTouchEndHandler);

    if (!this.hasContainerTarget) return;

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
    this.imageIndexOpened = this.previewImageTargets.indexOf(event.currentTarget);
    this.openModal(this.galleryTarget);
    this.showGalleryImage(this.imageIndexOpened);
  }

  onVideoClick(event) {
    if (!this.hasVideoModalTarget || !this.hasVideoIframeTarget) return;

    this.lastFocusedElement = event.currentTarget;
    this.videoIndexOpened = this.previewVideoTargets.indexOf(event.currentTarget);

    this.openModal(this.videoModalTarget);
    this.playCurrentVideo();
  }

  setupFocusTrap(modalElement) {
    const focusableSelectors = 'button:not([disabled]), [tabindex]:not([tabindex="-1"])';
    this.focusableElements = Array.from(modalElement.querySelectorAll(focusableSelectors)).filter(
      (element) => element.getClientRects().length > 0
    );
  }

  focusFirstModalElement() {
    if (this.focusableElements && this.focusableElements.length > 0) {
      this.focusableElements[0].focus();
    }
  }

  focusTrapHandler = (event) => {
    if (!this.activeModal || event.key !== "Tab" || !this.focusableElements || this.focusableElements.length === 0) {
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
    if (!this.isImageModalOpen()) return;

    this.hideGalleryImage(this.imageIndexOpened);
    if (this.imageIndexOpened === 0) {
      this.imageIndexOpened = this.galleryImageTargets.length - 1;
    } else {
      this.imageIndexOpened--;
    }
    this.showGalleryImage(this.imageIndexOpened);
  }

  onNextGalleryImage() {
    if (!this.isImageModalOpen()) return;

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
    this.closeImageModal();
  }

  onPreviousVideo() {
    if (!this.hasPreviewVideoTarget || this.previewVideoTargets.length <= 1) return;

    this.stopVideoPlayback();

    if (this.videoIndexOpened === 0) {
      this.videoIndexOpened = this.previewVideoTargets.length - 1;
    } else {
      this.videoIndexOpened--;
    }

    this.playCurrentVideo();
  }

  onNextVideo() {
    if (!this.hasPreviewVideoTarget || this.previewVideoTargets.length <= 1) return;

    this.stopVideoPlayback();

    if (this.videoIndexOpened === this.previewVideoTargets.length - 1) {
      this.videoIndexOpened = 0;
    } else {
      this.videoIndexOpened++;
    }

    this.playCurrentVideo();
  }

  onVideoModalClose() {
    this.closeVideoModal();
  }

  modalKeysHandler = (event) => {
    if (!this.isImageModalOpen() && !this.isVideoModalOpen()) return;

    if (event.key === "Escape") {
      if (this.isVideoModalOpen()) {
        this.closeVideoModal();
      } else {
        this.closeImageModal();
      }
    } else if (event.code === "ArrowRight") {
      if (this.isVideoModalOpen()) {
        this.onNextVideo();
      } else {
        this.onNextGalleryImage();
      }
    } else if (event.code === "ArrowLeft") {
      if (this.isVideoModalOpen()) {
        this.onPreviousVideo();
      } else {
        this.onPreviousGalleryImage();
      }
    }
  };

  galleryTouchStartHandler = (event) => {
    if (!this.isImageModalOpen()) return;

    if (event.touches.length > 1) {
      this.isMultiTouchGesture = true;
      return;
    }
    this.isMultiTouchGesture = false;
    this.touchstartX = event.changedTouches[0].screenX;
    this.touchstartY = event.changedTouches[0].screenY;
  };

  galleryTouchEndHandler = (event) => {
    if (!this.isImageModalOpen()) return;

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
    this.map?.remove();
    document.removeEventListener("keydown", this.modalKeysHandler);
    document.removeEventListener("keydown", this.focusTrapHandler);
    document.removeEventListener("touchstart", this.galleryTouchStartHandler);
    document.removeEventListener("touchend", this.galleryTouchEndHandler);
    this.closeImageModal({ restoreFocus: false });
    this.closeVideoModal({ restoreFocus: false });
  }

  openModal(modalTarget) {
    modalTarget.classList.remove("hidden");
    modalTarget.classList.add("flex");
    this.activeModal = modalTarget;
    window.document.body.classList.add("overflow-hidden");

    requestAnimationFrame(() => {
      this.setupFocusTrap(modalTarget);
      this.focusFirstModalElement();
    });
  }

  closeImageModal({ restoreFocus = true } = {}) {
    if (!this.hasGalleryTarget) return;

    this.galleryTarget.classList.add("hidden");
    this.galleryTarget.classList.remove("flex");
    this.galleryImageTargets.forEach((img) => img.classList.add("hidden"));
    this.galleryImageIndicatorTargets.forEach((img) => img.classList.add("opacity-50"));
    this.galleryImageIndicatorTargets.forEach((img) => img.classList.remove("opacity-100", "scale-125"));
    this.finishModalClose(restoreFocus);
  }

  closeVideoModal({ restoreFocus = true } = {}) {
    if (!this.hasVideoModalTarget) return;

    this.videoModalTarget.classList.add("hidden");
    this.videoModalTarget.classList.remove("flex");
    this.stopVideoPlayback();
    this.finishModalClose(restoreFocus);
  }

  finishModalClose(restoreFocus) {
    this.activeModal = null;
    this.focusableElements = null;

    if (!this.isImageModalOpen() && !this.isVideoModalOpen()) {
      window.document.body.classList.remove("overflow-hidden");
    }

    if (restoreFocus && this.lastFocusedElement) {
      this.lastFocusedElement.focus();
    }

    this.lastFocusedElement = null;
  }

  playCurrentVideo() {
    if (!this.hasVideoIframeTarget) return;

    const currentVideo = this.previewVideoTargets[this.videoIndexOpened];
    if (!currentVideo) return;

    const embedUrl = currentVideo.dataset.embedUrl;
    if (!embedUrl) return;

    this.videoIframeTarget.src = embedUrl;
  }

  stopVideoPlayback() {
    if (!this.hasVideoIframeTarget) return;

    this.videoIframeTarget.removeAttribute("src");
  }

  isImageModalOpen() {
    return this.hasGalleryTarget && !this.galleryTarget.classList.contains("hidden");
  }

  isVideoModalOpen() {
    return this.hasVideoModalTarget && !this.videoModalTarget.classList.contains("hidden");
  }
}
