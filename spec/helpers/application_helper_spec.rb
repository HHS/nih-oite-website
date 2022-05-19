require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#overridden_last_modified_date" do
    let(:updated_at) { 1.week.ago }

    context "no ENV override" do
      around do |example|
        ClimateControl.modify SITEMAP_LAST_MOD_OVERRIDE: "" do
          example.run
        end
      end

      it "returns the given time in iso8601 format" do
        expect(helper.overridden_last_modified_date(updated_at)).to eq updated_at.xmlschema
      end

      it "returns nil if both values are blank" do
        expect(helper.overridden_last_modified_date).to be_nil
      end
    end

    context "last modified overridden" do
      let(:override) { 2.weeks.ago.xmlschema }
      around do |example|
        ClimateControl.modify SITEMAP_LAST_MOD_OVERRIDE: override do
          example.run
        end
      end

      it "returns the override when the given date is before the override" do
        expect(helper.overridden_last_modified_date(3.weeks.ago)).to eq override
      end

      it "returns the given date when the given date is after the override" do
        expect(helper.overridden_last_modified_date(updated_at)).to eq updated_at.xmlschema
      end
    end
  end
end
