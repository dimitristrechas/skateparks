export const YOUTUBE_VIDEO_ID_REGEX = /^[A-Za-z0-9_-]{11}$/;

export function extractYouTubeVideoId(url) {
  try {
    const parsedUrl = new URL(url);
    const host = parsedUrl.hostname.replace(/^www\./, "");
    const pathSegments = parsedUrl.pathname.split("/").filter(Boolean);

    let candidate;

    switch (host) {
      case "youtu.be":
        candidate = pathSegments[0];
        break;
      case "youtube.com":
      case "m.youtube.com":
        if (pathSegments[0] === "watch") {
          candidate = parsedUrl.searchParams.get("v");
        } else if (["shorts", "embed", "v"].includes(pathSegments[0])) {
          candidate = pathSegments[1];
        }
        break;
      case "youtube-nocookie.com":
        if (pathSegments[0] === "embed") candidate = pathSegments[1];
        break;
      default:
        candidate = null;
    }

    return YOUTUBE_VIDEO_ID_REGEX.test(candidate || "") ? candidate : null;
  } catch {
    return null;
  }
}

export function thumbnailUrlFor(videoId) {
  return `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`;
}
