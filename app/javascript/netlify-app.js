import CMS from "netlify-cms-app";
import { GitGatewayBackend } from "netlify-cms-backend-git-gateway";
import AuthenticationPage from "./AuthenticationPage.jsx";
import { VideoEditorComponent } from "./VideoEditorComponent.jsx";

class NihGateway extends GitGatewayBackend {
  authComponent() {
    return AuthenticationPage;
  }
}

const stylesheetUrl = [].slice
  .call(
    document.querySelectorAll("link[rel=stylesheet][data-netlify-preview-style")
  )
  .forEach((link) => {
    CMS.registerPreviewStyle(link.href);
  });

CMS.registerBackend("nih-gateway", NihGateway);
CMS.registerEditorComponent(VideoEditorComponent);
CMS.init();
