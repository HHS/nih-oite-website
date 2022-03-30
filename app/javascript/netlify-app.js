import CMS from "netlify-cms-app";
import { GitGatewayBackend } from "netlify-cms-backend-git-gateway";
import AuthenticationPage from "./AuthenticationPage";
import VideoEditorComponent from "./VideoEditorComponent";

class NihGateway extends GitGatewayBackend {
  // eslint-disable-next-line class-methods-use-this
  authComponent() {
    return AuthenticationPage;
  }
}

CMS.registerBackend("nih-gateway", NihGateway);
CMS.registerEditorComponent(VideoEditorComponent);
CMS.init();
