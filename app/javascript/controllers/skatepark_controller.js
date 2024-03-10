import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

export default class extends Controller {
  static targets = ["container", "previewImage", "gallery", "galleryImage"];

  static values = {
    lat: String,
    lng: String,
  };

  connect() {
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
    console.log("galleryTargetConnected");
    document.addEventListener("keydown", this.modalCloseEscHandler);
  }

  galleryTargetDisonnected() {
    console.log("galleryTargetDisonnected");
    document.removeEventListener("keydown", this.modalCloseEscHandler);
  }

  onImageClick(event) {
    let imageIndexOpened = 0;

    this.previewImageTargets.forEach((img, idx) => {
      if (img.id === event.target.id) {
        imageIndexOpened = idx;
      }
    });

    this.galleryTarget.classList.remove("hidden");
    this.galleryImageTargets[imageIndexOpened].classList.remove("hidden");
    window.document.body.classList.add("overflow-hidden");
  }

  onModalClose() {
    this.galleryTarget.classList.add("hidden");
    this.galleryImageTargets.forEach((img) => img.classList.add("hidden"));
    window.document.body.classList.remove("overflow-hidden");
  }

  modalCloseEscHandler = (event) => {
    if (event.keyCode == 27) {
      this.onModalClose();
    }
  };

  disconnect() {
    this.map.remove();
    document.removeEventListener("keydown", this.modalCloseEscHandler);
    this.galleryTarget.classList.add("hidden");
    this.galleryImageTargets.forEach((img) => img.classList.add("hidden"));
    window.document.body.classList.remove("overflow-hidden");
  }
}
