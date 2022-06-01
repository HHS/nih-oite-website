NIH OITE Website
================

This application is one option for the groundwork for the new NIH OITE website.

## Docker use

Docker files exist to make it easy to run the application via Docker, but it is not (yet) setup to be easy to do development inside the docker containers.

To run the app via docker:

1. Copy `env.gitgateway.example` to `.env.gitgateway.local`
1. Update the two `CHANGE ME` values within `.env.gitgateway.local`
1. Run `docker compose up --build`
1. First time setup:
    1. Run `docker compose run web bundle exec rake db:create`
    1. Run `docker compose run web bundle exec rake db:migrate`
1. Open <http://localhost:3000> in your web browser


## Development

If you're new to Rails, see the [Getting Started with Rails](https://guides.rubyonrails.org/getting_started.html)
guide for an introduction to the framework.

### Local Setup

* Get `config/master.key` and the other credentials keys from Steve or Erica
* Install Ruby 3.1.1
* Install NodeJS 16.14.2
* Install PostgreSQL: `brew install postgresql`
  * Add postgres to your PATH if it wasn't done automatically
  `echo 'export PATH="/usr/local/opt/postgresql/bin:$PATH"' >> ~/.zshrc`
  * Start the server
  `brew services start postgresql`
* Install Ruby dependencies: `bundle install`
* Run git-gateway locally: See https://github.com/rahearn/git-gateway branch: `cloudgov-deploy`
* Install chromedriver for integration tests: `brew install --cask chromedriver`
  * Chromedriver must be allowed to run. You can either do that by:
    * The command line: `xattr -d com.apple.quarantine $(which chromedriver)` (this is the only option if you are on Big Sur)
    * Manually: clicking "allow" when you run the integration tests for the first time and a dialogue opens up
* Install JS dependencies: `yarn install`
* Create database: `bundle exec rake db:create`
* Run migrations: `bundle exec rake db:migrate`
* Run the server: `bundle exec rails s`
* Visit the site: http://localhost:3000

### Local Configuration

Environment variables can be set in development using the [dotenv](https://github.com/bkeepers/dotenv) gem.

Consistent but sensitive credentials should be added to `config/credentials.yml.enc` by using `$ rails credentials:edit`

Staging credentials should be added to `config/credentials/staging.yml.enc` by using `$ rails credentials:edit --environment staging`

Production credentials should be added to `config/credentials/production.yml.enc` by using `$ rails credentials:edit --environment production`

Any changes to variables in `.env` that should not be checked into git should be set
in `.env.local`.

If you wish to override a config globally for the `test` Rails environment you can set it in `.env.test.local`.
However, any config that should be set on other machines should either go into `.env` or be explicitly set as part
of the test.

## Security

### Authentication

TBD

### Inline `<script>` and `<style>` security

The system's Content-Security-Policy header prevents `<script>` and `<style>` tags from working without further
configuration. Use `<%= javascript_tag nonce: true %>` for inline javascript.

See the [CSP compliant script tag helpers](./doc/adr/0004-rails-csp-compliant-script-tag-helpers.md) ADR for
more information on setting these up successfully.

## Internationalization

### Managing locale files

We use the gem `i18n-tasks` to manage locale files. Here are a few common tasks:

Add missing keys across locales:
```
$ i18n-tasks missing # shows missing keys
$ i18n-tasks add-missing # adds missing keys across locale files
```

Key sorting:
```
$ i18n-tasks normalize
```

Removing unused keys:
```
$ i18n-tasks unused # shows unused keys
$ i18n-tasks remove-unused # removes unused keys across locale files
```

For more information on usage and helpful rake tasks to manage locale files, see [the documentation](https://github.com/glebm/i18n-tasks#usage).

## Testing

### Running tests

* Tests: `bundle exec rake spec`
* Ruby linter: `bundle exec rake standard`
* Accessibility scan: `./bin/pa11y-scan`
* Dynamic security scan: `./bin/owasp-scan`
* Ruby static security scan: `bundle exec rake brakeman`
* Ruby dependency checks: `bundle exec rake bundler:audit`
* JS dependency checks: `bundle exec rake yarn:audit`

Run everything: `bundle exec rake`

#### Pa11y Scan

When new pages are added to the application, ensure they are added to `./.pa11yci` so that they can be scanned.

### Automatic linting and formatting

Linting and formatting is wired up using [Husky][husky] and [lint-staged][lint-staged]. Running `yarn install` will install a [git pre-commit hook][git-hooks] that will lint and format code in the commit using the following tools:

| Files                    | Formatter / linter   |
| ------------------------ | -------------------- |
| Ruby (.rb)               | [Standard][standard] |
| CSS / SCSS (.css, .scss) | [Prettier][prettier] |
| Javascript (.js, .jsx)   | [Prettier][prettier] |
| Terraform (.tf)          | `terraform fmt`      |

[husky]: https://github.com/typicode/husky
[lint-staged]: https://github.com/okonet/lint-staged
[git-hooks]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
[standard]: https://github.com/testdouble/standard
[prettier]: https://github.com/prettier/prettier

## CI/CD

GitHub actions are used to run all tests and scans as part of pull requests.

Security scans are also run on a scheduled basis. Weekly for static code scans, and daily for dependency scans.

### Deployment

This repository supports automated deployment to <cloud.gov> via Github Actions. Before the app can be deployed, you must create the infrastructure using Terraform. See [documentation in the `terraform`](./terraform/README.md) directory for more information.

Each environment has dependencies on a PostgreSQL RDS instance managed by cloud.gov.
See [cloud.gov docs](https://cloud.gov/docs/services/relational-database/) for information on RDS.
#### Staging

Deploys to staging happen on every push to the `main` branch in Github.

The following secrets must be set within the [actions secrets](https://docs.github.com/en/actions/reference/encrypted-secrets)
to enable a deploy to work:

| Secret Name | Description |
| ----------- | ----------- |
| `CF_USERNAME` | cloud.gov [SpaceDeployer][spacedeployer] username |
| `CF_PASSWORD` | cloud.gov [SpaceDeployer][spacedeployer] password |
| `RAILS_MASTER_KEY` | `config/master.key` |
| `STAGING_RAILS_MASTER_KEY` | `config/credentials/staging.key` |

[spacedeployer]: ./terraform/README.md#spacedeployers

#### Production

Deploys to production are not yet scripted.

The following secrets must be set within the [actions secrets](https://docs.github.com/en/actions/reference/encrypted-secrets)
to enable a deploy to work:

| Secret Name | Description |
| ----------- | ----------- |
| `CF_USERNAME` | cloud.gov SpaceDeployer username |
| `CF_PASSWORD` | cloud.gov SpaceDeployer password |
| `RAILS_MASTER_KEY` | `config/master.key` |
| `PRODUCTION_RAILS_MASTER_KEY` | `config/credentials/production.key` |


### Configuring ENV variables in cloud.gov

All configuration that needs to be added to the deployed application's ENV should be added to
the `env:` block in `manifest.yml`

Items that are both **public** and **consistent** across staging and production can be set directly there.

Otherwise, they are set as a `((variable))` within `manifest.yml` and the variable is defined depending on sensitivity:

#### Credentials and other Secrets

1. Store variables that must be secret using [GitHub Action Secrets](https://docs.github.com/en/actions/reference/encrypted-secrets)
1. Add the secret to the `env:` block of the deploy action [as in this example](https://github.com/OHS-Hosting-Infrastructure/complaint-tracker/blob/a9e8d22aae2023a0afb631a6182251c04f597f7e/.github/workflows/deploy-stage.yml#L20)
1. Add the appropriate `--var` addition to the `push_arguments` line on the deploy action [as in this example](https://github.com/OHS-Hosting-Infrastructure/complaint-tracker/blob/a9e8d22aae2023a0afb631a6182251c04f597f7e/.github/workflows/deploy-stage.yml#L27)

#### Non-secrets

Configuration that changes from staging to production, but is public, should be added to `config/deployment/staging.yml` and `config/deployment/production.yml`

## Documentation

Architectural Decision Records (ADR) are stored in `doc/adr`
To create a new ADR, first install [ADR-tools](https://github.com/npryce/adr-tools) if you don't
already have it installed.
* `brew install adr-tools`

Then create the ADR:
*  `adr new Title Of Architectural Decision`

This will create a new, numbered ADR in the `doc/adr` directory.

Compliance diagrams are stored in `doc/compliance`. See the README there for more information on
generating diagram updates.

## Contributing

*This will continue to evolve as the project moves forward.*

* Pull down the most recent main before checking out a branch
* Write your code
* If a big architectural decision was made, add an ADR
* Submit a PR
  * If you added functionality, please add tests.
  * All tests must pass!
* Ping the other engineers for a review.
* At least one approving review is required for merge.
* Rebase against main before merge to ensure your code is up-to-date!
* Merge after review.
  * Squash commits into meaningful chunks of work and ensure that your commit messages convey meaning.

## Story Acceptance

TBD
