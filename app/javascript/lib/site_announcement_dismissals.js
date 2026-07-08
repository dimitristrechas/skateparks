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
