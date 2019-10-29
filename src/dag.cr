module DAG
  class Vertex
    alias Name = String

    getter name : Name
    getter edges : Hash(Name, Vertex)

    def initialize(@name, @edges = {} of Name => Vertex)
    end

    def add(edge_to vertex : Vertex) : Void
      @edges[vertex.name] = vertex
    end

    def children : Array(Vertex)
      @edges.values
    end
  end

  extend self

  def distances(
    from vertex : DAG::Vertex,
    visited = Hash(DAG::Vertex::Name, Bool).new(false),
    stack = Hash(DAG::Vertex, Int32).new(0)
  ) : Hash(DAG::Vertex, Int32)

    visited[vertex.name] = true

    sorted_children = vertex.children.sort_by { |c| c.name }
    sorted_children.each do |child|
      if !visited[child.name]
        stack[child] = stack[vertex] + 1
        distances(from: child, visited: visited, stack: stack)
      end
    end

    stack
  end

  def tip_of_longest_branch(from vertex : DAG::Vertex) : Array
    distances = self.distances(from: vertex)

    # Tip of longest branch (chain)
    distances.map { |k, v| [k, v] }.sort_by { |d| d[1].as(Int32) }.last
  end
end
