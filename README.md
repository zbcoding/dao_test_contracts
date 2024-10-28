Test contracts for a dao where members stake tokens in order to hold a nft representing membership. Written by Pillar team, I've made edits to these contracts for compatibility and relaunched these replica test contracts on Polygon Amoy.

```
---Polygon Amoy Test Contracts---
test dao contract: 0xf1a8685519D456f47a9F3505035F4Bad5d9a9ce0
test tokens (airdrop): 0x3cb29AAC77693A0784380Fb664Ec443Ce1079882
required test stake amount: 10*10**18 = 10000000000000000000 (10 tokens)
required test stake time: 0.1 min (6 seconds)
test nft contract: 0x0901f5aBd34A9080Dded6dad72188aAbee8a976F
```

Uses Solidity 8.1.8.

Staking and nft contracts use Openzeppelin contract utils as exact versions compatible with Solidity 8.1.8 (MIT license).
