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

## Contributing

1. Fork it (<https://github.com/cocol-project/probfin/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [cserb](https://github.com/cserb) - creator and maintainer
