# frozen_string_literal: true

require "regresso/web_ui"

RSpec.describe Regresso::WebUI::DiffFormatter do
  let(:diffs) do
    [
      { "path" => "$.value", "old_value" => 1, "new_value" => 2, "type" => "changed" }
    ]
  end

  it "formats html" do
    html = described_class.new.format(diffs, mode: :html)
    expect(html).to include("diff-row")
    expect(html).to include("$.value")
  end

  it "formats plain text" do
    text = described_class.new.format(diffs, mode: :plain)
    expect(text).to include("$.value")
  end
end
