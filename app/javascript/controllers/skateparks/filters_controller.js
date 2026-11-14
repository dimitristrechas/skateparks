import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["countrySelect"];

  static values = {
    locale: String,
  };

  connect() {
    if (this.hasCountrySelectTarget) {
      this.countrySelectTarget.addEventListener("change", this.handleCountryChange);
    }
  }

  handleCountryChange = (event) => {
    const countryCode = event.target.value;

    this.fetchAvailableCities(countryCode);
  };

  submitForm = (event) => {
    const form = event.target.form;
    if (!form) return;

    form.requestSubmit();
  };

  fetchAvailableCities(countryCode) {
    this.fetchTurboStream(`/available_cities/${encodeURIComponent(countryCode)}`);
  }

  fetchTurboStream(path) {
    const url = new URL(path, window.location.origin);
    if (this.localeValue && this.localeValue !== "en") {
      url.searchParams.set("locale", this.localeValue);
    }

    fetch(url.toString(), {
      method: "GET",
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }
}
