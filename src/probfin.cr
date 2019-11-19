require "./dag"

module ProbFin
  alias BlockHash = String

  module Chain
    extend self

    def dag
      @@dag ||= Hash(BlockHash, DAG::Vertex).new
    end

    def dag=(hash : Hash(BlockHash, DAG::Vertex))
      @@dag = hash
    end

    def orphans
      @@orphans ||= Hash(BlockHash, Array(BlockHash)).new(
        ->(hash : Hash(BlockHash, Array(BlockHash)), key : BlockHash) {
          hash[key] = Array(BlockHash).new
        }
      )
    end
  end

  def self.push(block : BlockHash, parent : BlockHash)
    # -- create vertex
    new_vertex = DAG::Vertex.new(name: block)
    # -- add to dag
    ProbFin::Chain.dag[block] = new_vertex
    # -- is block an orphan?
    if !ProbFin::Chain.dag[parent]?
      ProbFin::Chain.orphans[parent] << block
    end

    # -- edge to self from parent
    if ProbFin::Chain.dag[parent]?
      ProbFin::Chain.dag[parent].add edge_to: new_vertex
    end

    # -- block is parent of orphans?
    if orphans = ProbFin::Chain.orphans[block]?
      orphans.each do |orphan|
        ProbFin::Chain.dag[block].add edge_to: ProbFin::Chain.dag[orphan]
      end
      ProbFin::Chain.orphans.delete(block)
    end
  end

  def self.finalize(
    from starting_blockhash : BlockHash,
    chain_length_threshold : Int32 = 6,
    tip_diff_threshold : Int32 = 2
  ) : (BlockHash | Nil)
    tips = DAG.tips from: ProbFin::Chain.dag[starting_blockhash]
    return nil if below_chain_length_threshold? tips: tips, threshold: chain_length_threshold
    return nil if below_tip_diff_threshold? tips: tips, threshold: tip_diff_threshold

    tolb = tips.max_by { |t| t.distance }
    remaining_chain = self.traverse_remaining from: tolb.branch_root
    ProbFin::Chain.orphans.each do |_, orphans|
      orphans.each do |o|
        h = Hash(BlockHash, DAG::Vertex).new
        h[o] = ProbFin::Chain.dag[o]
        remaining_chain = remaining_chain.merge(h)
      end
    end
    ProbFin::Chain.dag = remaining_chain

    tolb.branch_root.as(DAG::Vertex).name
  end

  protected def self.below_tip_diff_threshold?(
    tips : Array(DAG::Tip),
    threshold : Int32
  ) : Bool
    tolb = tips.max_by { |t| t.distance }
    tips = tips.partition { |t| t == tolb }

    tips[1].any? { |t| (tolb.distance - t.distance) <= threshold }
  end

  protected def self.below_chain_length_threshold?(
    tips : Array(DAG::Tip),
    threshold : Int32
  ) : Bool
    long_enough = tips.select! { |t| t.distance >= threshold }
    return false if !long_enough.empty?

    true
  end

  protected def self.traverse_remaining(
    from vertex : DAG::Vertex,
    visited = Hash(String, Bool).new,
    remaining_dag = Hash(BlockHash, DAG::Vertex).new,
    remaining_parents = Hash(BlockHash, Array(BlockHash)).new(
      ->(hash : Hash(BlockHash, Array(BlockHash)), key : BlockHash) {
        hash[key] = Array(BlockHash).new
      }
    )
  ) : Hash(BlockHash, DAG::Vertex)
    visited[vertex.name] = true

    remaining_dag[vertex.name] = vertex
    vertex.children.each do |child|
      if !visited[child.name]?
        traverse_remaining(
          from: child,
          visited: visited,
          remaining_dag: remaining_dag,
          remaining_parents: remaining_parents
        )
      end
    end

    remaining_dag
  end
end
