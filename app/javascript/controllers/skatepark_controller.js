import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

export default class extends Controller {
  static targets = ["container"];

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
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      }).addTo(this.map);

      L.marker([this.latValue, this.lngValue]).addTo(this.map);
    });
  }

  disconnect() {
    this.map.remove();
  }
}
