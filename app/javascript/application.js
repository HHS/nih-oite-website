// Entry point for the build script in your package.json

import "@uswds/uswds";

/**
 * Prevents inputs inside closed accordions from being submitted with the form.
 * @param {HTMLFormElement} form
 */
function disableInputsHiddenInAccordions(form) {
  const inputs = form.querySelectorAll(".usa-accordion__content[hidden] input");
  [].forEach.call(inputs, (input) => {
    // eslint-disable-next-line no-param-reassign
    input.disabled = true;
  });
}

/**
 * @param {HTMLFormElement} form
 */
function preserveFormAccordionState(form) {
  const accordionButtons = form.querySelectorAll(".usa-accordion__button");
  [].forEach.call(accordionButtons, (button) => {
    const inputId = button.getAttribute("data-accordion-state-input");
    if (!inputId) {
      return;
    }
    const input = document.getElementById(inputId);
    if (input) {
      input.value = button.getAttribute("aria-expanded");
    }
  });
}

document.addEventListener("click", (evt) => {
  const { target } = evt;

  if (!(target instanceof HTMLElement)) {
    return;
  }

  if (!target.hasAttribute("data-submit-form-on-click")) {
    return;
  }

  const { form } = target;
  if (!(form instanceof HTMLFormElement)) {
    return;
  }

  disableInputsHiddenInAccordions(form);

  preserveFormAccordionState(form);

  form.submit();
});
