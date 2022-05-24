import React from "react";
import VideoEditorComponent from "./VideoEditorComponent";

describe("VideoEditorComponent", () => {
  test("#fromBlock", () => {
    const input = `

    This is the home page!

    {::video url="https://www.youtube.com/watch?v=SAK117AmzSE" alt="" /}

    {::content_block slug="hours-location/block" /}

  `;

    const match = input.match(VideoEditorComponent.pattern);

    const data = VideoEditorComponent.fromBlock(match);

    expect(data).toEqual({
      url: "https://www.youtube.com/watch?v=SAK117AmzSE",
      alt: "",
    });
  });

  describe("#toPreview", () => {
    const tests = [
      {
        alt: "alt text",
        url: "https://www.youtube.com/watch?v=LO2k-BNySLI",
        expected: (
          <div className="video">
            <iframe
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
              frameBorder="0"
              height="315"
              src="https://www.youtube-nocookie.com/embed/LO2k-BNySLI"
              title="alt text"
              width="560"
            />
          </div>
        ),
      },
      {
        url: "https://www.youtube.com/watch?v=X_eXSzyZudM&somebogusarg=foo",
        expected: (
          <div className="video">
            {/* eslint-disable-next-line jsx-a11y/iframe-has-title */}
            <iframe
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
              frameBorder="0"
              height="315"
              src="https://www.youtube-nocookie.com/embed/X_eXSzyZudM"
              width="560"
            />
          </div>
        ),
      },
      {
        url: "https://www.youtube.com/watch?v=SAK117AmzSE",
        alt: "some alt text",
        expected: (
          <div className="video">
            <iframe
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
              frameBorder="0"
              height="315"
              src="https://www.youtube-nocookie.com/embed/SAK117AmzSE"
              title="some alt text"
              width="560"
            />
          </div>
        ),
      },
      {
        url: "https://videocast.nih.gov/watch=44332",
        alt: "some alt text",
        expected: (
          <div className="video">
            <iframe
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
              frameBorder="0"
              height="315"
              src="https://videocast.nih.gov/embed.asp?live=44332"
              title="some alt text"
              width="560"
            />
          </div>
        ),
      },
      {
        url: "https://example.org/not-a-video",
        alt: "some alt text",
        expected: <div>Unrecognized video url</div>,
      },
    ];

    tests.forEach(({ url, alt, expected }) =>
      it(`${url} (${alt})`, () => {
        const data = {
          url,
          alt,
        };
        const preview = VideoEditorComponent.toPreview(data);
        expect(preview).toEqual(expected);
      })
    );
  });
});
