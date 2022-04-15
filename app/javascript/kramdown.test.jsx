import createKramdownExtensionEditorComponent from "./kramdown";

describe("#createKramdownExtensionEditorComponent", () => {
  let component;

  beforeEach(() => {
    component = createKramdownExtensionEditorComponent({
      id: "test",
    });
  });

  it("returns a component", () => {
    expect(component).toBeTruthy();
  });
});
