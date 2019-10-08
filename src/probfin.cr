require "./dag"

module ProbFin
  alias BlockHash = String

  module Chain
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
  end

  def self.push(block : BlockHash, parent : BlockHash)
    # TODO: this should not be here
    # do the check before
    # return false if ProbFin::Chain.ledger.includes?(block)

    # -- create vertex
    new_vertex = DAG::Vertex.new(name: block)
    # -- add to dag
    ProbFin::Chain.dag[block] = new_vertex
    ProbFin::Chain.parents[parent] << block

    # -- edge to self from parent
    if ProbFin::Chain.dag[parent]?
      ProbFin::Chain.dag[parent].add edge_to: new_vertex
    end

    # -- edge to orphans
    if orphans = ProbFin::Chain.parents[block]?
      orphans.each do |orphan|
        ProbFin::Chain.dag[block].add edge_to: ProbFin::Chain.dag[orphan]
      end
    end
  end

  def self.purge : (Nil | BlockHash)
  end
end
