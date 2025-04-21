# Cassette Beasts – Sticker Fusion Upgrade Mod

This mod enhances sticker fusion by upgrading sticker attributes through a merging system, in exchange for a higher markup cost.

### Upgrade Logic

The system compares two values — the `Base` and the `Source` — and selects the higher of the two. 

It merges the lower value using a non-linear growth formula that applies diminishing returns, scaling near the maximum threshold.

```
NewValue = HigherValue + (LowerValue * (1 - HigherValue / MaxValue)) * Rate
```

As the `HigherValue` approaches `MaxValue`, the impact from the `LowerValue` gradually decreases, maintaining balance at later stages.

### Cost Calculation

Increased based on proximity to the `MaxValue` and `Rarity` of the attribute being upgraded.

```
Cost = 100 * (ResultValue / MaxValue) * Rarity
TotalCost += Cost / Interval * 0.5
```

Costs are calculated in 20-unit intervals to provide smoother progression pacing.

### Metadata
- Mod ID: `mod_sticker_fusion_upgrade`
- Save File Tags: `none` (safe to remove)
- Netplay Tags: `none`