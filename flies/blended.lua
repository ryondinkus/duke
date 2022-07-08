local uses = {
    {
        key = include("flies/red").key,
        count = 1
    },
    {
        key = include("flies/soul").key,
        count = 1
    }
}

return {
    uses = uses,
    heart = DukeHelpers.Hearts.BLENDED,
    count = 1
}
