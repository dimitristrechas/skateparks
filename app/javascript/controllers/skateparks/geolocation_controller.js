import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["distanceRadio", "latitude", "longitude", "message"];

  static values = {
    defaultDistance: Number,
    deniedMessage: String,
    unavailableMessage: String,
    waitForLocationMessage: String,
  };

  connect() {
    this.pendingDistanceValue = null;
    this.syncFormState();
  }

  requestLocation() {
    if (!navigator.geolocation) {
      this.pendingDistanceValue = null;
      this.showMessage(this.unavailableMessageValue);
      return;
    }

    navigator.geolocation.getCurrentPosition(this.handleLocationSuccess, this.handleLocationError, {
      enableHighAccuracy: true,
      maximumAge: 300000,
      timeout: 10000,
    });
  }

  handleSubmit = (event) => {
    if (this.selectedDistanceValue === "" || this.hasCoordinates) return;

    event.preventDefault();

    if (!navigator.geolocation) {
      this.showMessage(this.unavailableMessageValue);
      return;
    }

    this.showMessage(this.waitForLocationMessageValue);

    if (this.pendingDistanceValue == null) {
      this.pendingDistanceValue = this.selectedDistanceValue;
      this.requestLocation();
    }
  };

  selectDistance = (event) => {
    const value = event.target.value || "";

    if (value === "") {
      this.clearLocation();
      return;
    }

    if (this.hasCoordinates) {
      this.applyDistance(value);
      return;
    }

    this.pendingDistanceValue = value;
    this.hideMessage();
    this.requestLocation();
  };

  clearLocation = () => {
    this.pendingDistanceValue = null;
    this.latitudeTarget.value = "";
    this.longitudeTarget.value = "";
    this.selectDistanceValue("");
    this.hideMessage();
    this.syncFormState();
  };

  handleLocationSuccess = ({ coords }) => {
    this.latitudeTarget.value = coords.latitude;
    this.longitudeTarget.value = coords.longitude;
    this.applyDistance(
      this.pendingDistanceValue || this.selectedDistanceValue || String(this.defaultDistanceValue || "")
    );
    this.pendingDistanceValue = null;
    this.hideMessage();
  };

  handleLocationError = (error) => {
    this.pendingDistanceValue = null;
    this.selectDistanceValue("");
    this.latitudeTarget.value = "";
    this.longitudeTarget.value = "";
    this.syncFormState();

    if (error.code === error.PERMISSION_DENIED) {
      this.showMessage(this.deniedMessageValue);
      return;
    }

    this.showMessage(this.unavailableMessageValue);
  };

  applyDistance(value) {
    this.selectDistanceValue(value);
    this.syncFormState();
  }

  syncFormState() {
    const hasActiveDistance = this.hasCoordinates && this.selectedDistanceValue !== "";

    this.latitudeTarget.disabled = !hasActiveDistance;
    this.longitudeTarget.disabled = !hasActiveDistance;
  }

  get hasCoordinates() {
    return this.latitudeTarget.value !== "" && this.longitudeTarget.value !== "";
  }

  get selectedDistanceValue() {
    const selectedRadio = this.distanceRadioTargets.find((radio) => radio.checked);

    return selectedRadio ? selectedRadio.value : "";
  }

  selectDistanceValue(value) {
    this.distanceRadioTargets.forEach((radio) => {
      radio.checked = radio.value === value;
    });
  }

  showMessage(message) {
    this.messageTarget.textContent = message;
    this.messageTarget.hidden = false;
  }

  hideMessage() {
    this.messageTarget.textContent = "";
    this.messageTarget.hidden = true;
  }
}
