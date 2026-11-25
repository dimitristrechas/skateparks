import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    citiesUrl: String,
  };

  handleCountryChange(event) {
    this.fetchAvailableCities(event.target.value);
  }

  submitForm(event) {
    event.target.form?.requestSubmit();
  }

  async fetchAvailableCities(countryCode) {
    const url = new URL(this.citiesUrlValue, window.location.origin);
    if (countryCode) url.searchParams.set("country_code", countryCode);

    try {
      const response = await fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);

      Turbo.renderStreamMessage(await response.text());
    } catch (error) {
      console.error("Failed to load cities", error);
    }
  }
}
