import CMS from "netlify-cms-app";
import { GitGatewayBackend } from "netlify-cms-backend-git-gateway";
import AuthenticationPage from "./AuthenticationPage";
import ContentBlockEditorComponent from "./ContentBlockEditorComponent";
import VideoEditorComponent from "./VideoEditorComponent";
import ReadOnlyControl from "./ReadOnlyControl";
import ReadOnlyPreview from "./ReadOnlyPreview";
import {
  TwoColumns,
  ThreeColumns,
  FourColumns,
} from "./ColumnsEditorComponent";

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
CMS.registerEditorComponent(TwoColumns);
CMS.registerEditorComponent(ThreeColumns);
CMS.registerEditorComponent(FourColumns);
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
