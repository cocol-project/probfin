module DAG
  class Vertex
    getter name : String
    getter edges : Hash(Vertex, Int32)

    def initialize(@name, @edges = {} of Vertex => Int32)
    end

    def add(edge_to vertex : Vertex, weight : Int32 = 1) : Void
      @edges[vertex] = weight
    end

    def children : Array(Vertex)
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

      sorted_children = vertex.children.sort_by { |c| c.name }
      sorted_children.each do |child|
        if !visited[child.name]?
          topsort(from: child, visited: visited, stack: stack)
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
        v.children.each do |c|
          if distances[c] > distances[v] + v.edges[c]
            distances[c] = distances[v] + v.edges[c]
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
