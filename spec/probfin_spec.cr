require "./spec_helper"
require "../src/probfin"

describe ProbFin do
  context "DAG Construction" do
    Spec.before_each do
      # creating blocks with parent
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

      ProbFin::Chain.dag.clear
      ProbFin::Chain.orphans.clear
      chain.each do |block|
        ProbFin.push(block: block[0], parent: block[1])
      end
    end

    it "builds a DAG correctly" do
      result = Helper.topsort(from: ProbFin::Chain.dag["aa"]).map { |v| v.name }
      result.should eq(["aa", "ba", "ca", "da", "ea", "fa", "cb", "cc", "bb"])
    end

    it "does not finalize because of branch length threshold" do
      finalized = ProbFin.finalize from: "aa"
      finalized.should be_nil
    end

    it "does not finalize because of tip difference threshold" do
      finalized = ProbFin.finalize from: "aa", chain_length_threshold: 1
      finalized.should be_nil
    end

    it "finalizes from aa" do
      finalized = ProbFin.finalize from: "aa",
        chain_length_threshold: 1,
        tip_diff_threshold: 0
      finalized.should eq("ba")
    end

    it "finalizes from ca" do
      finalized = ProbFin.finalize from: "ca",
        chain_length_threshold: 1,
        tip_diff_threshold: 0
      finalized.should eq("da")
    end

    context "purging" do
      it "purges from ca on" do
        ProbFin.finalize from: "ca",
          chain_length_threshold: 1,
          tip_diff_threshold: 0
        ProbFin::Chain.dag["ca"]?.should be_nil
        ProbFin::Chain.dag.size.should eq(4)
      end

      it "purges from ca on leaving orphans" do
        orphan = "orphan"
        parent = "noparent"
        ProbFin.push block: orphan, parent: parent

        ProbFin.finalize from: "ca",
                         chain_length_threshold: 1,
                         tip_diff_threshold: 0
        ProbFin::Chain.dag[orphan]?.should be_truthy

        ProbFin::Chain.orphans[parent].should eq([orphan])
        ProbFin::Chain.orphans.size.should eq(2)
      end
    end
  end
end

module Helper
  extend self

  def topsort(
    from vertex : DAG::Vertex,
    visited = Hash(String, Bool).new,
    stack = Array(DAG::Vertex).new
  ) : Array(DAG::Vertex)
    visited[vertex.name] = true

    sorted_children = vertex.children.sort_by { |c| c.name }
    sorted_children.each do |child|
      if !visited[child.name]?
        topsort(from: child, visited: visited, stack: stack)
      end
    end

    stack.unshift(vertex)
  end
end
