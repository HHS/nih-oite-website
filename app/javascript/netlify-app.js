import CMS from 'netlify-cms-app'
import { GitGatewayBackend } from 'netlify-cms-backend-git-gateway'
import AuthenticationPage from './AuthenticationPage.jsx'
import {VideoEditorComponent} from "./VideoEditorComponent.jsx"

class NihGateway extends GitGatewayBackend {
  authComponent() {
    return AuthenticationPage
  }
}

CMS.registerBackend('nih-gateway', NihGateway)
CMS.registerEditorComponent(VideoEditorComponent)
CMS.init()
