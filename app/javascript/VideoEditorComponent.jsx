import React from "react";

const VIDEO_TYPES = [
  {
    id: "youtube",
    // e.g. https://www.youtube.com/watch?v=SAK117AmzSE
    pattern: "https:\\/\\/www.youtube.com\\/watch\\?v=[\\w\\d]+(&|$)",
    generatePreview(url, alt) {
      // NOTE: Any changes here need to be kept in sync with renderer
      const u = new URL(url);
      const videoId = u.searchParams.get("v");
      const embedUrl = `https://www.youtube-nocookie.com/embed/${videoId}`;
      return (
        <iframe
          width="560"
          height="315"
          src={embedUrl}
          title={alt}
          frameBorder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        />
      );
    },
  },
];

/**
 * Escapes user input for storage in a Kramdown extension attribute.
 * Note that this _does not_ do sanitization--that'll be the job of
 * whatever's rendering the Markdown to HTML.
 * @param {any} input
 * @returns {string}
 */
function escapeForKramdownExtensionAttribute(input) {
  return String(input ?? "").replace(/"/g, '\\"');
}

/**
 * @param {any} value
 * @returns {string}
 */
function unescapeFromKramdownExtensionAttribute(value) {
  return String(value ?? "").replace(/\\"/g, '"');
}

const VideoEditorComponent = {
  id: "video",
  label: "Video",
  fields: [
    {
      name: "url",
      label: "Youtube URL",
      widget: "string",
    },
    {
      name: "alt",
      label: "Alt text",
      widget: "string",
    },
  ],
  pattern: /{::video url="(.*)" alt="(.*)" \/}/,
  /**
   * @param {string[]} match
   * @returns {{alt: string, url: string}}
   */
  fromBlock(match) {
    return {
      url: unescapeFromKramdownExtensionAttribute(match[1]),
      alt: unescapeFromKramdownExtensionAttribute(match[2]),
    };
  },
  /**
   *
   * @param {{alt: string, url: string}} data
   */
  toBlock({ url, alt }) {
    return `{::video url="${escapeForKramdownExtensionAttribute(
      url
    )}" alt="${escapeForKramdownExtensionAttribute(alt)}" /}`;
  },
  toPreview({ url, alt }) {
    const provider = VIDEO_TYPES.find(({ pattern }) => {
      const rx = new RegExp(`^${pattern}$`, "i");
      return rx.test(url);
    });
    if (!provider) {
      return <div>Unrecognized video url: {url}</div>;
    }

    return provider.generatePreview(url, alt);
  },
};

export default VideoEditorComponent;
