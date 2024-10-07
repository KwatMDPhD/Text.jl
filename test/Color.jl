using Omics

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using Colors: RGB

# ---- #

for st in ("red", "#f00", "#ff0000")

    rg = Omics.Color.pars(st)

    rg === RGB(1, 0, 0)

    Omics.Color.hexify(rg) === "#ff0000"

end

# ---- #

for (al, re) in ((0, "#ff000000"), (0.5, "#ff000080"), (1, "#ff0000ff"))

    @test Omics.Color.fade("#ff0000", al) === Omics.Color.fade("#ff000088", al) === re

end
