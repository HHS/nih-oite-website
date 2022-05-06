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
    id: "columns-2",
    label: "Two Columns (50/50)",
    columnNames: ["left", "right"],
    editorComponents: EDITOR_COMPONENTS_ALLOWED_IN_COLUMNS,
  })
);
CMS.registerEditorComponent(
  createColumnsComponent({
    id: "columns-3",
    label: "Three Columns",
    columnNames: ["left", "center", "right"],
    editorComponents: EDITOR_COMPONENTS_ALLOWED_IN_COLUMNS,
  })
);
CMS.registerEditorComponent(
  createColumnsComponent({
    id: "columns-4",
    label: "Four Columns",
    columnNames: ["one", "two", "three", "four"],
    editorComponents: EDITOR_COMPONENTS_ALLOWED_IN_COLUMNS,
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

CMS.init();
