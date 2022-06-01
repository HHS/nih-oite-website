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
  let accordionStateInput = form.querySelector("[name=acc]");
  if (!accordionStateInput) {
    accordionStateInput = document.createElement("input");
    accordionStateInput.type = "hidden";
    accordionStateInput.name = "acc";
    form.appendChild(accordionStateInput);
  }

  const accordionButtons = form.querySelectorAll(".usa-accordion__button");
  accordionStateInput.value = [].map
    .call(accordionButtons, (button) => {
      const name = button.getAttribute("data-accordion-name");
      if (!name) {
        return undefined;
      }

      const isExpanded = button.getAttribute("aria-expanded") === "true";
      return isExpanded ? name : undefined;
    })
    .filter((x) => !!x)
    .join(",");
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
