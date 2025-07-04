import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

const swipeThreshold = 50;

export default class extends Controller {
  static targets = [
    "container",
    "previewImage",
    "gallery",
    "galleryImage",
    "galleryImageIndicator",
  ];

  static values = {
    lat: String,
    lng: String,
  };

  connect() {
    this.imageIndexOpened = 0;
    this.touchstartX = 0;
    this.touchstartY = 0;

    import("leaflet").then((L) => {
      this.map = L.map(this.containerTarget, {
        zoomDelta: 0.5,
        zoomSnap: 0.5,
      }).setView([this.latValue, this.lngValue], 20);

      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      }).addTo(this.map);

      L.marker([this.latValue, this.lngValue]).addTo(this.map);
    });

    document.addEventListener("click", (event) => {
      // Check if click target is the modal element itself
      const isModal = event.target === this.galleryTarget;

      // If clicked outside or on padding, call the callback function
      if (!isModal && !this.galleryTarget.contains(event.target)) {
        // console.log("outside");
      }
    });
  }

  galleryTargetConnected(element) {
    document.addEventListener("keydown", this.modalKeysHandler);
    document.addEventListener("touchstart", this.galleryTouchStartHandler);
    document.addEventListener("touchend", this.galleryTouchEndHandler);
  }

  galleryTargetDisonnected() {
    document.removeEventListener("keydown", this.modalKeysHandler);
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
    this.previewImageTargets.forEach((img, idx) => {
      if (img.id === event.target.id) {
        this.imageIndexOpened = idx;
      }
    });

    this.galleryTarget.classList.remove("hidden");
    this.galleryTarget.classList.add("flex");

    this.showGalleryImage(this.imageIndexOpened);
    window.document.body.classList.add("overflow-hidden");
  }

  onPreviousGalleryImage(event) {
    this.hideGalleryImage(this.imageIndexOpened);
    if (this.imageIndexOpened == 0) {
      this.imageIndexOpened = this.galleryImageTargets.length - 1;
    } else {
      this.imageIndexOpened--;
    }
    this.showGalleryImage(this.imageIndexOpened);
  }

  onNextGalleryImage(event) {
    this.hideGalleryImage(this.imageIndexOpened);
    if (this.imageIndexOpened == this.galleryImageTargets.length - 1) {
      this.imageIndexOpened = 0;
    } else {
      this.imageIndexOpened++;
    }
    this.showGalleryImage(this.imageIndexOpened);
  }

  showGalleryImage(idx) {
    this.galleryImageTargets[idx].classList.remove("hidden");
    this.galleryImageIndicatorTargets[idx].classList.remove(
      "opacity-25"
    );
    this.galleryImageIndicatorTargets[idx].classList.add(
      "opacity-100"
    );
  }

  hideGalleryImage(idx) {
    this.galleryImageTargets[idx].classList.add("hidden");
    this.galleryImageIndicatorTargets[idx].classList.add(
      "opacity-25"
    );
    this.galleryImageIndicatorTargets[idx].classList.remove(
      "opacity-100"
    );
  }

  onModalClose() {
    this.hideModalElements();
  }

  modalKeysHandler = (event) => {
    if (event.keyCode == 27) {
      this.onModalClose();
    } else if (event.code == "ArrowRight") {
      this.onNextGalleryImage();
    } else if (event.code == "ArrowLeft") {
      this.onPreviousGalleryImage();
    }
  };

  galleryTouchStartHandler = (event) => {
    this.touchstartX = event.changedTouches[0].screenX;
    this.touchstartY = event.changedTouches[0].screenY;
  };

  galleryTouchEndHandler = (event) => {
    if (event.changedTouches.length > 1) return;

    const touchendX = event.changedTouches[0].screenX;
    const touchendY = event.changedTouches[0].screenY;

    const swipeX = touchendX - this.touchstartX;
    const swipeY = touchendY - this.touchstartY;

    if (
      Math.abs(swipeX) > Math.abs(swipeY) &&
      Math.abs(swipeX) > swipeThreshold
    ) {
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
    document.removeEventListener("touchstart", this.galleryTouchStartHandler);
    document.removeEventListener("touchend", this.galleryTouchEndHandler);
    this.hideModalElements();
  }

  hideModalElements() {
    this.galleryTarget.classList.add("hidden");
    this.galleryTarget.classList.remove("flex");
    this.galleryImageTargets.forEach((img) => img.classList.add("hidden"));
    this.galleryImageIndicatorTargets.forEach((img) =>
      img.classList.add("opacity-25", "w-4", "h-4", "lg:w-5", "lg:h-5")
    );
    this.galleryImageIndicatorTargets.forEach((img) =>
      img.classList.remove("opacity-100", "w-5", "h-5", "lg:w-6", "lg:h-6")
    );
    window.document.body.classList.remove("overflow-hidden");
  }
}
