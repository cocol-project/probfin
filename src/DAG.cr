module DAG
  class Vertex
    getter name : String
    getter edges : Hash(Vertex, Int32)

    def initialize(@name, @edges = {} of Vertex => Int32)
    end

    def add(edge_to vertex : Vertex, weight : Int32 = 1) : Void
      @edges[vertex] = weight
    end

    def neighbors : Array(Vertex)
      @edges.keys
    end

    def ==(vertex : Vertex) : Bool
      @name == vertex.name
    end

    def !=(vertex : Vertex) : Bool
      @name != vertex.name
    end
  end

  module Graph
    extend self

    # Topological Ordering
    def topsort(
      from vertex : DAG::Vertex,
      visited = {} of String => Bool,
      stack = [] of DAG::Vertex
    ) : Array(DAG::Vertex)
      visited[vertex.name] = true

      sorted_neighbors = vertex.neighbors.sort_by { |n| n.name }
      sorted_neighbors.each do |neighbor|
        if !visited[neighbor.name]?
          topsort(from: neighbor, visited: visited, stack: stack)
        end
      end

      stack.unshift(vertex)
    end

    # Single Source Shortest Path (SSSP)
    def distances(
      from vertex : DAG::Vertex,
      in topsorted_graph : Array(DAG::Vertex)
    ) : Hash(DAG::Vertex, Int32)
      # Creates a new empty Hash that returns a default value on missing key
      # We want to have MAX as default value
      distances = Hash(DAG::Vertex, Int32).new(
        ->(hash : Hash(DAG::Vertex, Int32), key : DAG::Vertex) {
          hash[key] = Int32::MAX
        }
      )
      distances[vertex] = 0

      topsorted_graph.each do |v|
        v.neighbors.each do |n|
          if distances[n] > distances[v] + v.edges[n]
            distances[n] = distances[v] + v.edges[n]
          end
        end
      end

      distances
    end

    def longest_branch(
      from vertex : DAG::Vertex,
      in topsorted_graph : Array(DAG::Vertex)
    ) : Array
      distances = self.distances(from: vertex, in: topsorted_graph)

      # Tip of longest branch (chain)
      distances.map { |k, v| [k, v] }.sort_by { |d| d[1].as(Int32) }.last
    end
  end
end

module ProbFin
  alias BlockHash = String

  module Chain
    def self.threshold
      @@threshold ||= Array(DAG::Vertex).new
    end

    def self.dag
      @@dag ||= Hash(BlockHash, DAG::Vertex).new
    end

    def self.parents
      @@parents ||= Hash(BlockHash, Array(BlockHash)).new(
        ->(hash : Hash(BlockHash, Array(BlockHash)), key : BlockHash) {
          hash[key] = Array(BlockHash).new
        }
      )
    end

    # TODO: remove me; only here for testing/mocking
    def self.ledger
      @@ledger ||= Array(BlockHash).new
    end
  end

  def self.add(block : BlockHash, parent : BlockHash)
    if !ProbFin::Chain.ledger.includes?(block)
      # TODO: callback to save block
      # -- create vertex
      new_vertex = DAG::Vertex.new(name: block)
      # -- add to dag
      ProbFin::Chain.dag[block] = new_vertex
      ProbFin::Chain.parents[parent] << block

      # -- edge to himself for parent
      if ProbFin::Chain.dag[parent]?
        ProbFin::Chain.dag[parent].add edge_to: new_vertex
      end

      # -- edge to children
      if children = ProbFin::Chain.parents[block]?
        children.each do |child|
          ProbFin::Chain.dag[block].add edge_to: ProbFin::Chain.dag[child]
        end
      end

      # -- parent is the last final block -> add to threshold
      if ProbFin::Chain.ledger.last == parent
        ProbFin::Chain.threshold << new_vertex
      end
    end

  end
end
