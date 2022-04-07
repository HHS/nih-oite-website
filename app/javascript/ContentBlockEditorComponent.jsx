import React from "react";
import createKramdownExtensionEditorComponent from "./kramdown";

const ContentBlockEditorComponent = createKramdownExtensionEditorComponent({
  id: "content_block",
  label: "Content block",
  fields: [
    {
      name: "slug",
      label: "Block",
      widget: "relation",
      collection: "block",
      search_fields: ["name", "{{slug}}"],
      value_field: "{{slug}}",
      display_fields: ["name"],
    },
  ],
  toPreview: ({ slug }) => (
    <div className="bg-base-lighter padding-1">
      Content block: <code>{slug}</code>
    </div>
  ),
});

export default ContentBlockEditorComponent;
