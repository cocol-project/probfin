require "./dag"

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

    def self.ledger
      @@ledger ||= Array(BlockHash).new
    end
  end

  def self.add(block : BlockHash, parent : BlockHash) : Bool
    return false if ProbFin::Chain.ledger.includes?(block)

    # TODO: callback to save block
    # -- create vertex
    new_vertex = DAG::Vertex.new(name: block)
    # -- add to dag
    ProbFin::Chain.dag[block] = new_vertex
    ProbFin::Chain.parents[parent] << block

    # -- edge to self for parent
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

    return true
  end
end
