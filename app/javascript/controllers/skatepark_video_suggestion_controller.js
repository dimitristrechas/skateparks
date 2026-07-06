import { Controller } from "@hotwired/stimulus";
import { extractYouTubeVideoId } from "lib/youtube_url";

export default class extends Controller {
  static targets = ["dialog", "form", "urlInput", "error", "announcer", "honeypot"];

  static values = {
    invalidVideoUrl: String,
  };

  connect() {
    this.lastFocusedElement = null;
    if (!this.hasDialogTarget) return;

    this.dialogTarget.addEventListener("cancel", this.onCancel);
    this.dialogTarget.addEventListener("close", this.onClose);
  }

  disconnect() {
    if (!this.hasDialogTarget) return;

    this.dialogTarget.removeEventListener("cancel", this.onCancel);
    this.dialogTarget.removeEventListener("close", this.onClose);
  }

  open(event) {
    event.preventDefault();
    if (!this.hasDialogTarget) return;

    this.lastFocusedElement = event.currentTarget;
    this.clearUrlError();
    this.dialogTarget.showModal();

    if (this.hasUrlInputTarget) {
      this.urlInputTarget.focus();
    }
  }

  close() {
    if (!this.hasDialogTarget) return;
    if (!this.dialogTarget.open) return;

    this.dialogTarget.close();
  }

  onCancel = (event) => {
    event.preventDefault();
    this.close();
  };

  onClose = () => {
    if (this.lastFocusedElement) {
      this.lastFocusedElement.focus();
      this.lastFocusedElement = null;
    }
  };

  validateBeforeSubmit(event) {
    if (!this.hasUrlInputTarget) return;

    const youtubeUrl = this.urlInputTarget.value.trim();
    this.clearUrlError();

    if (!youtubeUrl) {
      event.preventDefault();
      return;
    }

    const videoId = extractYouTubeVideoId(youtubeUrl);
    if (!videoId) {
      event.preventDefault();
      this.reportUrlError(this.invalidVideoUrlValue);
    }
  }

  clearUrlError() {
    if (!this.hasUrlInputTarget) return;

    this.urlInputTarget.removeAttribute("aria-describedby");
    this.urlInputTarget.removeAttribute("aria-invalid");

    if (!this.hasErrorTarget) return;

    this.errorTarget.textContent = "";
    this.errorTarget.classList.add("hidden");
  }

  reportUrlError(message) {
    if (!this.hasUrlInputTarget || !this.hasErrorTarget) return;

    this.urlInputTarget.setAttribute("aria-describedby", this.errorTarget.id);
    this.urlInputTarget.setAttribute("aria-invalid", "true");
    this.errorTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
    this.urlInputTarget.focus();
  }
}
