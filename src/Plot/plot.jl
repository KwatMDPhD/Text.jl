function plot(data, layout = Dict(), config = Dict(); ht = "")

    axis = Dict("automargin" => true)

    di = "BioinformaticsCore.Plot.plot.$(BioinformaticsCore.Time.stamp())"

    BioinformaticsCore.HTML.make(
        di,
        ("https://cdn.plot.ly/plotly-latest.min.js",),
        """
        Plotly.newPlot(
            \"$di\",
            $(write(data)),
            $(write(BioinformaticsCore.Dict.merge(
                Dict("hovermode" => "closest", "yaxis" => axis, "xaxis" => axis),
                layout,
            ))),
            $(write(BioinformaticsCore.Dict.merge(
                Dict(
                    "modebarbuttonstoremove" => ("select", "lasso", "resetscale"),
                    "displaylogo" => false,
                    "responsive" => true,
                    "editable" => false,
                ),
                config,
            ))),
        )
        """,
        ht,
    )

end
