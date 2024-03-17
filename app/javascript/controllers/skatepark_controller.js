import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

const swipeThreshold = 50;

export default class extends Controller {
  static targets = ["container", "previewImage", "gallery", "galleryImage"];

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
  }

  galleryTargetConnected() {
    document.addEventListener("keydown", this.modalKeysHandler);
    document.addEventListener("touchstart", this.galleryTouchStartHandler);
    document.addEventListener("touchend", this.galleryTouchEndHandler);
  }

  galleryTargetDisonnected() {
    document.removeEventListener("keydown", this.modalKeysHandler);
  }

  onImageClick(event) {
    this.previewImageTargets.forEach((img, idx) => {
      if (img.id === event.target.id) {
        this.imageIndexOpened = idx;
      }
    });

    this.galleryTarget.classList.remove("hidden");
    this.galleryImageTargets[this.imageIndexOpened].classList.remove("hidden");
    window.document.body.classList.add("overflow-hidden");
  }

  onPreviousGalleryImage(event) {
    this.galleryImageTargets[this.imageIndexOpened].classList.add("hidden");
    if (this.imageIndexOpened == 0) {
      this.imageIndexOpened = this.galleryImageTargets.length - 1;
    } else {
      this.imageIndexOpened--;
    }
    this.galleryImageTargets[this.imageIndexOpened].classList.remove("hidden");
  }

  onNextGalleryImage(event) {
    this.galleryImageTargets[this.imageIndexOpened].classList.add("hidden");
    if (this.imageIndexOpened == this.galleryImageTargets.length - 1) {
      this.imageIndexOpened = 0;
    } else {
      this.imageIndexOpened++;
    }
    this.galleryImageTargets[this.imageIndexOpened].classList.remove("hidden");
  }

  onModalClose() {
    this.galleryTarget.classList.add("hidden");
    this.galleryImageTargets.forEach((img) => img.classList.add("hidden"));
    window.document.body.classList.remove("overflow-hidden");
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
    this.galleryTarget.classList.add("hidden");
    this.galleryImageTargets.forEach((img) => img.classList.add("hidden"));
    window.document.body.classList.remove("overflow-hidden");
  }
}
