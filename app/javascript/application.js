// Entry point for the build script in your package.json

import "@uswds/uswds";

// Auto-submit forms on element clicks
document.addEventListener("click", (evt) => {
  if (
    evt.target instanceof HTMLElement &&
    evt.target.hasAttribute("data-submit-form-on-click")
  ) {
    evt.target.form.submit();
  }
});
