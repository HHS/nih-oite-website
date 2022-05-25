import React from "react";
import { createKramdownExtensionEditorComponent } from "./kramdown";

const VIDEO_TYPES = [
  {
    id: "youtube",
    // e.g. https://www.youtube.com/watch?v=SAK117AmzSE
    pattern: "https:\\/\\/www.youtube.com\\/watch\\?.+",
    generatePreview(url, alt) {
      // NOTE: Any changes here need to be kept in sync with renderer
      const u = new URL(url);
      const videoId = u.searchParams.get("v");
      const embedUrl = `https://www.youtube-nocookie.com/embed/${videoId}`;
      return (
        <div className="video">
          <iframe
            width="560"
            height="315"
            src={embedUrl}
            title={alt}
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
      );
    },
  },
  {
    id: "nih-videocast",
    pattern: "https:\\/\\/videocast\\.nih\\.gov\\/watch=(\\d+)",
    generatePreview(url, alt) {
      const m = /^\/watch=(\d+)$/.exec(new URL(url).pathname);
      const videoId = m[1];

      const embedUrl = `https://videocast.nih.gov/embed.asp?live=${videoId}`;

      return (
        <div className="video">
          <iframe
            width="560"
            height="315"
            src={embedUrl}
            title={alt}
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
      );
    },
  },
];

const VideoEditorComponent = createKramdownExtensionEditorComponent({
  id: "video",
  label: "Video",
  fields: [
    {
      name: "url",
      label: "Video URL",
      widget: "string",
      hint: "Youtube or NIH Videocast URLs are supported.",
    },
    {
      name: "alt",
      label: "Alt text",
      widget: "string",
    },
  ],
  toPreview({ url, alt }) {
    const provider = VIDEO_TYPES.find(({ pattern }) => {
      const rx = new RegExp(`^${pattern}$`, "i");
      return rx.test(url);
    });
    if (!provider) {
      return <div>Unrecognized video url</div>;
    }

    return provider.generatePreview(url, alt);
  },
});

export default VideoEditorComponent;
