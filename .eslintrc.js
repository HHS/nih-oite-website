module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    "airbnb",
    "plugin:react-hooks/recommended",
    "plugin:react/recommended",
    "prettier",
  ],
  overrides: [
    {
      files: ["**/*.test.{js,jsx}"],
      env: { "jest/globals": true },
      plugins: ["jest"],
      extends: ["plugin:jest/recommended"],
    },
  ],
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: "latest",
    sourceType: "module",
  },
  plugins: ["jest", "prettier", "react"],
  rules: {},
};
