/* eslint-disable no-undef */
if (typeof jest !== "undefined") {
  Object.defineProperty(URL, "createObjectURL", {
    writable: true,
    value: jest.fn(),
  });
}
