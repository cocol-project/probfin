# Cocol Probabilistic Finality

Based on DAGs, it manages chains, sidechains and orphans. Given a threshold of
confirmations it returns the next finalized block.

## Installation

1. Add the dependency to your `shard.yml`:

``` yaml
   dependencies:
     probfin:
       github: cocol-project/probfin
```

2. Run `shards install`

## Usage

``` crystal
require "probfin"
```

``` crystal
# (a0)---aa---ba---ca---da---ea---fa
#              \    \
#               bb   cb---cc

# add blocks (aa, a0 should be block hashes)
ProbFin.push(block: "aa", parent: "a0")
ProbFin.push(block: "ba", parent: "aa")
ProbFin.push(block: "bb", parent: "ba")
...


ProbFin.finalize from: "aa",
    chain_length_threshold: 5, # 5 confirmations (fa being the 5th) 
    tip_diff_threshold: 0 # how many more confirmations should it have compared to sidechains
    
# => ba
```

## How ProbFin works
![Alt Text](https://thepracticaldev.s3.amazonaws.com/i/bfimp8gtxgbiyc5pb480.png)

The data structure above resembles a Directed Acyclic Graph (DAG) and fortunately DAGs allow for an easy way to find the longest chain. This is an important part of achieving probabilistic finality.

A DAG is made up of nodes (also called vertices) and edges. An edge represents a link between 2 vertices (e.g. `3000.1->3001.1`). We can and should traverse a DAG to find out more about its structure, like how far away is vertex `3005.1` from vertex `3000.1`

Additionally a DAG has some unique properties. Find out more about it [here](https://www.youtube.com/watch?v=TXkDpqjDMHA)

**2. How to find the longest chain**

If we look again at the example above, it becomes apparent that `3005.1` is the tip of the longest chain. But how can we find it out programmatically?

We are going to use [Depth First Search](https://www.youtube.com/watch?v=7fujbpJ0LB4) to traverse the graph and mark every vertex with its distance from the starting vertex.
We start at `3000.1` and give it a distance of `0`. Now we traverse through all vertices and give each a distance of `parent distance + 1`. So `3001.1` has a `parent distance` of `0` and `+1` gives a distance of `1`.

![Alt Text](https://thepracticaldev.s3.amazonaws.com/i/qexgjvm9yv8ko8cwv6y2.png)

## Contributing

1. Fork it (<https://github.com/cocol-project/probfin/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [cserb](https://github.com/cserb) - creator and maintainer
