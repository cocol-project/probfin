require "./spec_helper"
require "../src/dag"

describe DAG do
    v1 = DAG::Vertex.new("aa")
    v2 = DAG::Vertex.new("ba")
    v21 = DAG::Vertex.new("bb")
    v3 = DAG::Vertex.new("ca")
    v31 = DAG::Vertex.new("cb")
    v32 = DAG::Vertex.new("cc")
    v4 = DAG::Vertex.new("da")
    v5 = DAG::Vertex.new("ea")
    v6 = DAG::Vertex.new("fa")

    v1.add edge_to: v2
    v2.add edge_to: v3
    v2.add edge_to: v21
    v3.add edge_to: v31
    v3.add edge_to: v4
    v31.add edge_to: v32
    v4.add edge_to: v5
    v5.add edge_to: v6

    # v1---v2---v3---v4---v5---v6
    #         \    \
    #           v21  v31--v32

  context "Tips of branches" do
    it "finds all tips of branches starting from given vertex" do
      tips = DAG.tips(from: v1)
      tips = tips.map { |t| [t.vertex, t.distance, t.branch_root] }
      expected_tips = [[v21, 2, v2],
                      [v32, 4, v2],
                      [v6, 5, v2]]

      tips.should eq(expected_tips)
    end

    it "finds the tip of the longest branch (chain)" do
      tip = DAG.tip_of_longest_branch(from: v1)
      tip.vertex.should eq(v6)
      tip.distance.should eq(5)
    end
  end
end
