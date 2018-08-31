use Mix.Config
use Xee.ThemeConfig

# config :xee, Xee.ThemeServer, tags: [
#   {"経済実験", [
#     {"相互作用あり", []},
#     {"相互作用なし", []}
#   ]},
#   {"その他の実験", []}
# ]

theme PublicGoods,
  name: "公共財",
  path: "apps/xee_public_goods",
  host: "host.js",
  participant: "participant.js",
  standing_experiments: %{name: "PublicGoods sample", x_token: "a"},
  tags: ["相互作用あり"]

theme DoubleAuction,
  name: "ダブルオークション",
  path: "apps/xee_double_auction",
  host: "host.js",
  participant: "participant.js",
  standing_experiments: %{name: "Double Auction sample", x_token: "b"},
  tags: ["相互作用あり"]

register_themes()
