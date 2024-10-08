using Omics

using Test: @test

# ----------------------------------------------------------------------------------------------- #

# ---- #

const HT = Omics.HTM.writ(
    joinpath(tempdir(), "name.html"),
    ("SRC 1", "SRC 2"),
    "SCRIPT";
    ba = "#ff0000",
)

const ST = read(HT, String)

println(ST)

@test count(==('\n'), ST) === 11

run(`open --background $HT`)
