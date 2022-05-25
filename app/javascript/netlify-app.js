import CMS from "netlify-cms-app";
import { GitGatewayBackend } from "netlify-cms-backend-git-gateway";
import AuthenticationPage from "./AuthenticationPage";
import ContentBlockEditorComponent from "./ContentBlockEditorComponent";
import VideoEditorComponent from "./VideoEditorComponent";
import ReadOnlyControl from "./ReadOnlyControl";
import ReadOnlyPreview from "./ReadOnlyPreview";
import createColumnsComponent from "./ColumnsEditorComponent";

// Restrict the editor components permitted inside columns to prevent
// nesting etc.
const EDITOR_COMPONENTS_ALLOWED_IN_COLUMNS = [
  "image",
  "video",
  "content_block",
];

class NihGateway extends GitGatewayBackend {
  // eslint-disable-next-line class-methods-use-this
  authComponent() {
    return AuthenticationPage;
  }
}

[].slice
  .call(
    document.querySelectorAll("link[rel=stylesheet][data-netlify-preview-style")
  )
  .forEach((link) => {
    CMS.registerPreviewStyle(link.href);
  });

CMS.registerBackend("nih-gateway", NihGateway);
CMS.registerEditorComponent(
  createColumnsComponent({
    label: "Two Columns (50/50)",
    columns: ["left", "right"].map((name) => ({
      name,
      span: 6,
    })),
    editorComponents: EDITOR_COMPONENTS_ALLOWED_IN_COLUMNS,
    cms: CMS,
  })
);
CMS.registerEditorComponent(
  createColumnsComponent({
    label: "Three Columns",
    columns: ["left", "center", "right"].map((name) => ({
      name,
      span: 4,
    })),
    editorComponents: EDITOR_COMPONENTS_ALLOWED_IN_COLUMNS,
    cms: CMS,
  })
);
CMS.registerEditorComponent(
  createColumnsComponent({
    label: "Four Columns",
    columns: ["one", "two", "three", "four"].map((name) => ({
      name,
      span: 3,
    })),
    editorComponents: EDITOR_COMPONENTS_ALLOWED_IN_COLUMNS,
    cms: CMS,
  })
);
CMS.registerEditorComponent(ContentBlockEditorComponent);
CMS.registerEditorComponent(VideoEditorComponent);
CMS.registerWidget("readonly", ReadOnlyControl, ReadOnlyPreview);

CMS.registerEventListener({
  name: "preSave",
  handler: ({ entry }) =>
    entry.get("data").set("updated_at", new Date().toISOString()),
});
CMS.registerEventListener({
  name: "preSave",
  handler: ({ entry, author: { login } }) =>
    entry.get("data").set("updated_by", login),
});

CMS.registerRemarkPlugin({
  settings: {
    rule: "-",
  },
});

CMS.init();
