local wisps = {
    include("wisps/red"),
    include("wisps/soul"),
    include("wisps/black"),
    include("wisps/golden"),
    include("wisps/bone"),
    include("wisps/rotten")
}

DukeHelpers.Wisps = {}

for _, wisp in pairs(wisps) do
    wisp.key = wisp.heart.key

    DukeHelpers.Wisps[wisp.key] = wisp
end
