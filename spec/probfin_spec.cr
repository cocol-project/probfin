require "./spec_helper"
require "../src/probfin"

describe ProbFin do
  context "DAG Construction" do
    # creatings blocks with parent
    chain = [
      ["aa", "a0"],
      ["ba", "aa"],
      ["bb", "ba"],
      ["ca", "ba"],
      ["cb", "ca"],
      ["cc", "cb"],
      ["da", "ca"],
      ["ea", "da"],
      ["fa", "ea"],
    ].shuffle

    # (a0)---aa---ba---ca---da---ea---fa
    #              \    \
    #               bb   cb---cc

    chain.each do |block|
      ProbFin.push(block: block[0], parent: block[1])
    end

    it "built a DAG correctly" do
      result = DAG::Graph.topsort(from: ProbFin::Chain.dag["aa"]).map { |v| v.name }
      result.should eq(["aa", "ba", "ca", "da", "ea", "fa", "cb", "cc", "bb"])
    end
  end
end
