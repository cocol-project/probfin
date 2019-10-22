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

    it "builds a DAG correctly" do
      result = Helper.topsort(from: ProbFin::Chain.dag["aa"]).map { |v| v.name }
      result.should eq(["aa", "ba", "ca", "da", "ea", "fa", "cb", "cc", "bb"])
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
