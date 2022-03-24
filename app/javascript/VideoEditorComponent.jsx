import React from "react"

const VIDEO_TYPES = [
    {
        id: "youtube",
        // e.g. https://www.youtube.com/watch?v=SAK117AmzSE
        pattern:"https:\\/\\/www.youtube.com\\/watch\\?v=[\\w\\d]+(&|$)",
        generatePreview(url, alt) {
            const u = new URL(url)
            const videoId = u.searchParams.get("v");
            const embedUrl = `https://www.youtube-nocookie.com/embed/${videoId}`;
            return <iframe width="560" height="315" src={embedUrl} title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>;
        }
    }
]

export const VideoEditorComponent = {
    id: "video",
    label: "Video",
    fields: [
        {
            name: "url",
            label: "URL",
            widget: "string",
        },
        {
            name: "alt",
            label: "Alt text",
            widget: "string",
        }

    ],
    pattern: /{::video url="(.*?)" alt=".*?" \/}/,
    /**
     * @param {string[]} match 
     * @returns {{alt: string, url: string}}
     */
    fromBlock(match) {
        return {
            url: decodeURIComponent(match[1]),
            alt: decodeURIComponent(match[2]),
        }
    },
    /**
     * 
     * @param {{alt: string, url: string}} data 
     */
    toBlock({url, alt}) {
        url = encodeURIComponent((url ?? "").trim())
        alt = encodeURIComponent((alt ?? "").trim())
        return `{::video url="${url}" alt="${alt}" /}`
    },
    toPreview({url, alt}) {
        console.log(url, alt)
        const provider = VIDEO_TYPES.find(({pattern}) => {
            const rx = new RegExp(`^${pattern}$`, "i");
            console.log(url, rx, rx.test(url))
            return rx.test(url)
        });
        if (!provider) {
            return <div>Unrecognized video url: {url}</div>
        }
        return provider.generatePreview(url, alt)
    },
}

