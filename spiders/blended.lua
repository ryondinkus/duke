local uses = {
    {
        key = include("spiders/red").key,
        count = 1
    },
    {
        key = include("spiders/soul").key,
        count = 1
    }
}

return {
    uses = uses,
    heart = DukeHelpers.Hearts.BLENDED,
    count = 1
}
