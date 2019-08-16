require "./spec_helper"

describe DAG do
  context "Topological Sorting" do
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
    #       \    \
    #       v21  v31---v32

    it "orders alphabetically" do
      # order by name for better readability in case of failure only
      expected_order = [v1, v2, v3, v4, v5, v6, v31, v32, v21].map { |v| v.name }
      result = DAG::Graph.topsort(from: v1).map { |v| v.name }
      result.should eq(expected_order)
    end

    # Since all weights are 1 and we have no vertex with 2 parents
    # we can use the shortest path calculation to find the longest path
    # as well by finding the one with the longest distance value
    it "finds the longest path" do
      distances = DAG::Graph.distances(
        from: v1,
        in: DAG::Graph.topsort(from: v1)
      )
      result_by_name = distances.map { |k, v| [k.name, v] }
      expected_distances = [["aa", 0],
                            ["ba", 1],
                            ["ca", 2],
                            ["bb", 2],
                            ["cb", 3],
                            ["da", 3],
                            ["ea", 4],
                            ["fa", 5],
                            ["cc", 4]]

      result_by_name.should eq(expected_distances)
    end

    it "finds the tip of the longest branch (chain)" do
      tip = DAG::Graph.longest_branch(
        from: v1,
        in: DAG::Graph.topsort(from: v1)
      )
      tip[0].should eq(v6)
      tip[1].should eq(5)
    end
  end
end

describe ProbFin do
  context "DAG Construction" do
    ProbFin::Chain.ledger << "a0"

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
      ["fa", "ea"]
    ].shuffle

    chain.each do |block|
      ProbFin.add(block: block[0], parent: block[1])
    end

    it "built a DAG correctly" do
      result = DAG::Graph.topsort(from: ProbFin::Chain.threshold[0]).map { |v| v.name }
      result.should eq(["aa", "ba", "ca", "da", "ea", "fa", "cb", "cc", "bb"])
    end


  end
end
