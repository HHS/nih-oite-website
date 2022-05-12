module.exports = {
  syntax: "postcss-scss",
  plugins: [
    require("@csstools/postcss-sass")({
      includePaths: ["./node_modules/@uswds/uswds/packages"],
    }),
    require("autoprefixer"),
    process.env.NODE_ENV === "production" ? require("postcss-minify") : null,
  ],
};
