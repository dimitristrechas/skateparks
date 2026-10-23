import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dialog"];

  connect() {
    this.activeRowId = null;
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

  openReassignModal(event) {
    event.preventDefault();
    if (!this.hasDialogTarget) return;

    const trigger = event.currentTarget;
    this.lastFocusedElement = trigger;
    this.activeRowId = trigger.dataset.videoSuggestionId;

    const pickerController = this.pickerController();
    if (pickerController) {
      pickerController.setSelection(trigger.dataset.skateparkId, trigger.dataset.skateparkName);
    }

    this.dialogTarget.showModal();

    const comboboxInput = this.dialogTarget.querySelector('[role="combobox"]');
    if (comboboxInput) {
      comboboxInput.focus();
      comboboxInput.select();
    }
  }

  closeReassignModal() {
    if (!this.hasDialogTarget || !this.dialogTarget.open) return;

    this.dialogTarget.close();
  }

  applyReassignment(event) {
    event.preventDefault();
    const pickerController = this.pickerController();
    if (!pickerController || !pickerController.validateSelection()) return;

    const selectedId = pickerController.hiddenInputTarget.value;
    const selectedName = pickerController.inputTarget.value.trim();

    if (this.activeRowId) {
      const row = document.getElementById(this.activeRowId);
      if (row) {
        const hiddenInput = row.querySelector("[data-assigned-skatepark-input]");
        const nameLabel = row.querySelector("[data-assigned-skatepark-name]");
        const trigger = row.querySelector("[data-video-suggestion-id]");

        if (hiddenInput) hiddenInput.value = selectedId;
        if (nameLabel) nameLabel.textContent = selectedName;
        if (trigger) {
          trigger.dataset.skateparkId = selectedId;
          trigger.dataset.skateparkName = selectedName;
        }
      }
    }

    this.closeReassignModal();
  }

  onCancel = (event) => {
    event.preventDefault();
    this.closeReassignModal();
  };

  onClose = () => {
    if (this.lastFocusedElement) {
      this.lastFocusedElement.focus();
      this.lastFocusedElement = null;
    }
    this.activeRowId = null;
  };

  pickerController() {
    if (!this.hasDialogTarget) return null;

    const pickerElement = this.dialogTarget.querySelector('[data-controller~="admin--skatepark-picker"]');
    if (!pickerElement) return null;

    return this.application.getControllerForElementAndIdentifier(pickerElement, "admin--skatepark-picker");
  }
}
