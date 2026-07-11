const KEY_PREFIX = "skateparks.site_announcement.dismissed.";

export function dismissalKey(id, prefix = KEY_PREFIX) {
  return `${prefix}${id}`;
}

export function readDismissal(id, prefix = KEY_PREFIX) {
  try {
    return localStorage.getItem(dismissalKey(id, prefix));
  } catch {
    return null;
  }
}

export function writeDismissal(id, dismissToken, prefix = KEY_PREFIX) {
  try {
    localStorage.setItem(dismissalKey(id, prefix), dismissToken);
    return true;
  } catch {
    return false;
  }
}

export function clearDismissal(id, prefix = KEY_PREFIX) {
  try {
    localStorage.removeItem(dismissalKey(id, prefix));
  } catch {
    // Ignore storage errors in private browsing or quota failures.
  }
}

export function filterDismissedAnnouncements(root) {
  const prefix = root.dataset.dismissKeyPrefix || KEY_PREFIX;

  root.querySelectorAll("[data-site-announcements-target='item']").forEach((item) => {
    const { announcementId, dismissToken } = item.dataset;
    const stored = readDismissal(announcementId, prefix);

    if (stored === dismissToken) {
      item.remove();
    } else if (stored) {
      clearDismissal(announcementId, prefix);
    }
  });

  if (root.querySelectorAll("[data-site-announcements-target='item']").length === 0) {
    root.remove();
    return false;
  }

  return true;
}

export function dismissAnnouncementItem(root, item) {
  if (!root || !item) return false;

  const prefix = root.dataset.dismissKeyPrefix || KEY_PREFIX;
  const { announcementId, dismissToken } = item.dataset;

  writeDismissal(announcementId, dismissToken, prefix);
  item.remove();

  if (root.querySelectorAll("[data-site-announcements-target='item']").length === 0) {
    root.remove();
    return true;
  }

  return false;
}

export function dismissAnnouncementFromEvent(root, event) {
  const button = event.target.closest("[data-site-announcements-dismiss-button]");
  if (!button || !root.contains(button)) return null;

  event.preventDefault();

  const item = button.closest("[data-site-announcements-target='item']");
  if (!item) return null;

  const itemIndex = [...root.querySelectorAll("[data-site-announcements-target='item']")].indexOf(item);
  const regionRemoved = dismissAnnouncementItem(root, item);

  return { itemIndex, regionRemoved };
}

export function attachDismissListeners(root) {
  if (root.dataset.siteAnnouncementsDismissBound === "true") return;

  root.addEventListener("click", (event) => {
    const result = dismissAnnouncementFromEvent(root, event);
    if (!result) return;

    root.dispatchEvent(
      new CustomEvent("site-announcements:dismissed", {
        bubbles: false,
        detail: result,
      })
    );
  });

  root.dataset.siteAnnouncementsDismissBound = "true";
}

export function initializeSiteAnnouncements(root) {
  if (!root) return;

  filterDismissedAnnouncements(root);
  attachDismissListeners(root);
}
