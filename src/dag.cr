module DAG
  record Tip,
    vertex : DAG::Vertex,
    distance : Int32,
    branch_root : (DAG::Vertex | Nil)

  class Vertex
    alias Name = String

    getter name : Name
    getter edges : Hash(Name, Vertex)

    def initialize(@name, @edges = {} of Name => Vertex)
    end

    def add(edge_to vertex : Vertex) : Nil
      @edges[vertex.name] = vertex
    end

    def children : Array(Vertex)
      @edges.values
    end
  end

  extend self

  def tips(
    from vertex : Vertex,
    visited = Hash(Vertex::Name, Bool).new(false),
    distance = Hash(Vertex, Int32).new(0),
    tips = Array(DAG::Tip).new,
    start : (Vertex | Nil) = nil,
    current_branch_root : (Vertex | Nil) = nil
  ) : Array(DAG::Tip)
    # remember the starting vertex
    start = vertex if distance.empty?

    # mark current vertex as visited
    visited[vertex.name] = true

    # sort children just to make it easier to test
    sorted_children = vertex.children.sort_by { |c| c.name }
    # if it has no children it's the tip of a branch
    if sorted_children.empty?
      tips << DAG::Tip.new(
        vertex: vertex,
        distance: distance[vertex],
        branch_root: current_branch_root
      )
    else
      # it has children so let's continue the traverse
      sorted_children.each do |child|
        if !visited[child.name]
          # we mark the child of the starting vertex as the current root
          # of the branch we are exploring
          if start == vertex
            current_branch_root = child
          end
          # we calculate the distance of the child
          distance[child] = distance[vertex] + 1

          tips(
            from: child,
            visited: visited,
            distance: distance,
            tips: tips,
            start: start,
            current_branch_root: current_branch_root
          )
        end
      end
    end

    tips
  end

  def tip_of_longest_branch(from vertex : DAG::Vertex) : DAG::Tip
    tips = self.tips(from: vertex)

    tip_of_longest_branch from: tips
  end

  def tip_of_longest_branch(from tips : Array(DAG::Tip)) : DAG::Tip
    # Tip of longest branch (chain)
    tips.max_by { |t| t.distance }
  end
end
