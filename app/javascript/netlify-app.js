import CMS from 'netlify-cms-app'
import { GitGatewayBackend } from 'netlify-cms-backend-git-gateway'
import AuthenticationPage from './AuthenticationPage.jsx'

class NihGateway extends GitGatewayBackend {
  authComponent() {
    return AuthenticationPage
  }
}

CMS.registerBackend('nih-gateway', NihGateway)
CMS.init()
