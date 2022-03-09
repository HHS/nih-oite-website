import React from 'react'
import { AuthenticationPage as GitGatewayAuthenticationPage } from 'netlify-cms-backend-git-gateway'
import {
  AuthenticationPage,
  buttons,
  shadows,
  colors,
} from 'netlify-cms-ui-default'
import styled from '@emotion/styled'

const LoginButton = styled.button`
  ${buttons.button};
  ${shadows.dropDeep};
  ${buttons.default};
  ${buttons.gray};

  padding: 0 30px;
  display: block;
  margin: 20px auto 0;
`;

const AuthForm = styled.form`
  width: 350px;
`;

const ErrorMessage = styled.p`
  color: ${colors.errorText};
`;

export default class NihGatewayAuthenticationPage extends GitGatewayAuthenticationPage {
  handleErrorLogin = async e => {
    e.preventDefault();
    return this.handleSSOLogin()
  };

  handleSSOLogin = async () => {
    try {
      const client = await GitGatewayAuthenticationPage.authClient();
      const user = await client.login()
      this.props.onLogin(user);
    } catch (error) {
      this.setState({
        errors: { server: error.description || error.msg || error },
      });
    }
  };

  render() {
    const { errors } = this.state;
    const { config, t } = this.props;

    if (errors.server) {
      return (
        <AuthenticationPage
          logoUrl={config.logo_url}
          siteUrl={config.site_url}
          renderPageContent={() => (
            <AuthForm onSubmit={this.handleErrorLogin}>
              {!errors.server ? null : <ErrorMessage>{String(errors.server)}</ErrorMessage>}
              <LoginButton>Try again</LoginButton>
            </AuthForm>
          )}
          t={t}
        />
      )
    }
    return (
      <AuthenticationPage
        logoUrl={config.logo_url}
        siteUrl={config.site_url}
        onLogin={this.handleSSOLogin}
        renderButtonContent={() => t("auth.login")}
        t={t}
      />
    )
  }
}
