require 'spec_helper'


def compare_xml_docs(doc1, doc2)
  strip_text_nodes(doc1).canonicalize == strip_text_nodes(doc2).canonicalize
end

class Nokogiri::XML::Document
  # Our documents don't contain text nodes of significance.  This
  # facilitates comparing ignoring whitespace text nodes.
  def strip_blank_text_nodes
    xpath("//text()").each do |node|
      if node.text.strip == ''
        node.remove
      end
    end
    self
  end
end


RSpec.describe "Api::CsvHandler" do

  let(:ob) { (Class.new { include Api::CsvHandler }).new }

  let(:valid_data_doc) { File.open(Rails.root.join "spec/fixtures/files/api/beta/valid-test-data.csv").read }

  let(:expected_output) {
    doc_as_string = %q(
      <trait-data-set>
        <trait mean="1.4" access_level="4">
          <site sitename="Aliartos, Greece"/>
          <species scientificname="Abarema jupunba"/>
          <treatment name="observational"></treatment>
          <method name="test"></method>
          <notes>This was from a Mediteranean site</notes>
          <citation author="Adams" year="1986"/>
          <stat name="SE" sample_size="100" value="3.7"/>
          <variable name="SLA"/>
          <covariates>
            <covariate level="8">
              <variable id="80"/>
            </covariate>
          </covariates>
          <entity name="Photo 12"/>
        </trait>
        <trait mean="2.1" access_level="1">
          <site sitename="Macknade Research Station"/>
          <species scientificname="Saccharum officinarum">
            <cultivar name="s5-14"/>
          </species>
          <treatment name="observational"></treatment>
          <method name="test"></method>
          <notes/>
          <citation author="Wood" year="1996"/>
          <stat name="SE" sample_size="230" value="6.3"/>
          <variable name="SLA"/>
          <covariates>
            <covariate level="9">
              <variable id="80"/>
            </covariate>
          </covariates>
          <entity name="Photo 12"/>
        </trait>
      </trait-data-set>
    )
    doc = Nokogiri.parse(doc_as_string, nil, nil, Nokogiri::XML::ParseOptions.new.strict)
  }

  it "should do a correct transformation from CSV to XML" do
    expect(ob.send(:csv_2_xml_doc, valid_data_doc).strip_blank_text_nodes.canonicalize).to eq(expected_output.strip_blank_text_nodes.canonicalize)
  end
end

