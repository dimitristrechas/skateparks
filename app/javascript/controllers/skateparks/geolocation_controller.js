import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "distanceRadio",
    "latitude",
    "longitude",
    "message",
    "nearestSortRadio",
    "sortRadio",
    "sortForm",
    "sortLatitude",
    "sortLongitude",
    "filterSort",
  ];

  static values = {
    defaultDistance: Number,
    deniedMessage: String,
    unavailableMessage: String,
    waitForLocationMessage: String,
  };

  connect() {
    this.pendingDistanceValue = null;
    this.pendingNearestSort = false;
    this.previousSortValue = this.currentSortValue;
    this.syncFormState();
    this.checkGrantedPermission();
  }

  checkGrantedPermission() {
    if (!navigator.permissions?.query) return;

    navigator.permissions
      .query({ name: "geolocation" })
      .then((status) => {
        this.applyPermissionState(status.state);
        status.onchange = () => this.applyPermissionState(status.state);
      })
      .catch(() => {});
  }

  applyPermissionState(state) {
    if (state === "granted") {
      this.hideMessage();
      if (!this.hasCoordinates) {
        this.requestSilentLocation();
      }
      return;
    }

    if (state === "denied") {
      this.setCoordinates("", "");
      this.selectDistanceValue("");
      if (this.hasNearestSortRadioTarget && this.nearestSortRadioTarget.checked) {
        this.restorePreviousSort();
      }
      this.syncFormState();
    }
  }

  requestSilentLocation() {
    if (!navigator.geolocation) return;

    navigator.geolocation.getCurrentPosition(
      ({ coords }) => {
        this.setCoordinates(coords.latitude, coords.longitude);
        this.syncFormState();
      },
      () => {},
      {
        enableHighAccuracy: true,
        maximumAge: 300000,
        timeout: 10000,
      }
    );
  }

  requestLocation() {
    if (!navigator.geolocation) {
      this.pendingDistanceValue = null;
      this.pendingNearestSort = false;
      this.showMessage(this.unavailableMessageValue);
      return;
    }

    navigator.geolocation.getCurrentPosition(this.handleLocationSuccess, this.handleLocationError, {
      enableHighAccuracy: true,
      maximumAge: 300000,
      timeout: 10000,
    });
  }

  selectNearestSort = () => {
    if (this.hasCoordinates) {
      this.syncFormState();
      this.sortFormTarget?.requestSubmit();
      return;
    }

    if (!navigator.geolocation) {
      this.restorePreviousSort();
      this.showMessage(this.unavailableMessageValue);
      return;
    }

    this.pendingNearestSort = true;
    this.hideMessage();
    this.requestLocation();
  };

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
    this.selectDistanceValue("");
    this.hideMessage();
    this.syncFormState();
  };

  handleLocationSuccess = ({ coords }) => {
    this.setCoordinates(coords.latitude, coords.longitude);

    if (this.pendingNearestSort) {
      this.pendingNearestSort = false;
      this.hideMessage();
      this.syncFormState();
      this.sortFormTarget?.requestSubmit();
      return;
    }

    this.applyDistance(
      this.pendingDistanceValue || this.selectedDistanceValue || String(this.defaultDistanceValue || "")
    );
    this.pendingDistanceValue = null;
    this.hideMessage();
  };

  handleLocationError = (error) => {
    if (this.pendingNearestSort) {
      this.pendingNearestSort = false;
      this.restorePreviousSort();
    } else {
      this.pendingDistanceValue = null;
      this.selectDistanceValue("");
    }

    this.setCoordinates("", "");
    this.syncFormState();

    if (error.code === error.PERMISSION_DENIED) {
      this.showMessage(this.deniedMessageValue);
      return;
    }

    this.showMessage(this.unavailableMessageValue);
  };

  restorePreviousSort() {
    const fallbackValue = this.previousSortValue === "nearest" ? "" : this.previousSortValue;

    if (this.hasNearestSortRadioTarget) {
      this.nearestSortRadioTarget.checked = false;
    }

    this.sortRadioTargets.forEach((radio) => {
      radio.checked = radio.value === fallbackValue;
    });
  }

  get currentSortValue() {
    if (this.hasNearestSortRadioTarget && this.nearestSortRadioTarget.checked) {
      return "nearest";
    }

    const checkedRadio = this.sortRadioTargets.find((radio) => radio.checked);
    return checkedRadio ? checkedRadio.value : "";
  }

  setCoordinates(lat, lng) {
    this.latitudeTarget.value = lat;
    this.longitudeTarget.value = lng;
    if (this.hasSortLatitudeTarget) this.sortLatitudeTarget.value = lat;
    if (this.hasSortLongitudeTarget) this.sortLongitudeTarget.value = lng;
  }

  applyDistance(value) {
    this.selectDistanceValue(value);
    this.syncFormState();
  }

  syncFormState() {
    const isNearestSort = this.hasNearestSortRadioTarget && this.nearestSortRadioTarget.checked;
    const needsCoordinates = this.hasCoordinates && (this.selectedDistanceValue !== "" || isNearestSort);

    this.latitudeTarget.disabled = !needsCoordinates;
    this.longitudeTarget.disabled = !needsCoordinates;

    if (this.hasSortLatitudeTarget) this.sortLatitudeTarget.disabled = !this.hasCoordinates;
    if (this.hasSortLongitudeTarget) this.sortLongitudeTarget.disabled = !this.hasCoordinates;
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
