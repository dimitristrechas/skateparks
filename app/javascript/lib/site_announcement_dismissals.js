const KEY_PREFIX = "skateparks.site_announcement.dismissed.";

export function dismissalKey(id) {
  return `${KEY_PREFIX}${id}`;
}

export function readDismissal(id) {
  try {
    return localStorage.getItem(dismissalKey(id));
  } catch {
    return null;
  }
}

export function writeDismissal(id, dismissToken) {
  try {
    localStorage.setItem(dismissalKey(id), dismissToken);
    return true;
  } catch {
    return false;
  }
}

export function clearDismissal(id) {
  try {
    localStorage.removeItem(dismissalKey(id));
  } catch {
    // Ignore storage errors in private browsing or quota failures.
  }
}

export function filterDismissedAnnouncements(root) {
  root.querySelectorAll("[data-site-announcements-target='item']").forEach((item) => {
    const { announcementId, dismissToken } = item.dataset;
    const stored = readDismissal(announcementId);

    if (stored === dismissToken) {
      item.remove();
    } else if (stored) {
      clearDismissal(announcementId);
    }
  });

  if (root.querySelectorAll("[data-site-announcements-target='item']").length === 0) {
    root.remove();
    return false;
  }

  return true;
}
