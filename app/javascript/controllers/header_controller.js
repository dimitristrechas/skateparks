import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["image", "toggleButton", "lightIcon", "darkIcon"];

  connect() {
    console.log("connect logo controller");
  }

  imageTargetConnected() {
    console.log("logo", this.imageTarget);
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      this.lightIconTarget.classList.remove("hidden");
      this.imageTarget.src = "/assets/skateparks_logo_dark.svg";
    } else {
      this.darkIconTarget.classList.remove("hidden");
      this.imageTarget.src = "/assets/skateparks_logo_light.svg";
    }
  }

  toggleThemeMode = (event) => {
    this.darkIconTarget.classList.toggle("hidden");
    this.lightIconTarget.classList.toggle("hidden");

    if (localStorage.getItem("theme")) {
      if (localStorage.getItem("theme") === "light") {
        document.documentElement.classList.add("dark");
        localStorage.setItem("theme", "dark");
      } else {
        document.documentElement.classList.remove("dark");
        localStorage.setItem("theme", "light");
      }
    } else {
      if (document.documentElement.classList.contains("dark")) {
        document.documentElement.classList.remove("dark");
        localStorage.setItem("theme", "light");
      } else {
        document.documentElement.classList.add("dark");
        localStorage.setItem("theme", "dark");
      }
    }
  };

  disconnect() {}
}
