<p align="center">
  <img src="https://www.cassettebeasts.com/wp-content/uploads/2021/10/CassetteBeasts_Logo.png" alt="Cassette Beasts Official Logo" width="330" height="200">
</p>

<h3 align="center">Cassette Beasts – Sticker Fusion Plus Mod</h3>

<p align="center">
  <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3467880204" target="_blank">
    <img src="https://steamcommunity.com/favicon.ico" width="16" style="vertical-align:middle;"> <span>Steam Workshop</span>
  </a> 
  • 
  <a href="https://modworkshop.net/mod/51803" target="_blank">
    <img src="https://modworkshop.net/favicon.ico" width="16" style="vertical-align:middle;"> <span>ModWorkshop</span>
  </a>
</p>

<p align="center">
  <strong>Merge</strong> sticker attributes instead, upgrading them in exchange for a higher markup cost.
</p>

---

## Features

- **Merge Attributes**  

  The system compares two values—`Base` and `Source` Stickers—and selects the `higher` one. 
  
  Before adding the `lower`, a diminishing returns formula is applied based on how close the `higher` is to the attribute’s `max`, scaled non-linearly and multiplied by a `rate`.
  
  ```Python
  Result = Higher + (Lower * (1 - Higher / Max)) * Rate
  ```

  The `lower` gradually decreases as the `higher` approaches the attribute's `max` to maintain balance at later stages.

- **Scaling Cost**  
  
  `cost` scales with the `result` proximity to the attribute's `max` and is adjusted by the attribute's `rarity`.

  ```Python
  Cost = 100 * (Result / Max) * Rarity
  ```

  It is then divided into 20-unit `interval` and halved to ensure smoother progression.

  ```Python
  Total += Cost / Interval * 0.5
  ```

- **Non-intrusive**  
  Does not modify core gameplay or existing save data.

## Metadata

- **Mod ID:** `mod_sticker_fusion_plus`
- **Save File Tags:** `none`
- **Netplay Tags:** `none`
