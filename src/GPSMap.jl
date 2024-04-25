module GPSMap

using DelaunayTriangulation: get_edges, triangulate

using ..Nucleus

function plot(
    ht,
    no_,
    di_x_no_x_co,
    po_,
    di_x_po_x_co;
    triangulation_line_color = "#171412",
    node_marker_size = 32,
    node_marker_opacity = 0.96,
    node_marker_color = triangulation_line_color,
    node_marker_line_width = 2,
    node_marker_line_color = Nucleus.Color.HEFA,
    node_annotation_font_size = 16,
    node_annotation_font_color = node_marker_color,
    node_annotation_bgcolor = "#ffffff",
    node_annotation_borderpad = 2,
    node_annotation_borderwidth = node_marker_line_width,
    node_annotation_bordercolor = node_marker_line_color,
    node_annotation_arrowwidth = 1.6,
    node_annotation_arrowcolor = node_marker_line_color,
    n_gr = 64,
    ncontours = 32,
    point_marker_size = 16,
    point_marker_opacity = 0.64,
    point_marker_color = Nucleus.Color.HEGE,
    point_marker_line_width = 0.8,
    point_marker_line_color = "#000000",
    sc_ = nothing,
    sc_na = Dict{Int, String}(),
    layout = Dict{String, Any}(),
)

    data = Dict{String, Any}[]

    tr = triangulate(eachcol(di_x_no_x_co))

    for ie_ in get_edges(tr)

        if any(==(-1), ie_)

            continue

        end

        ve = collect(ie_)

        push!(
            data,
            Dict(
                "legendgroup" => "Node",
                "showlegend" => false,
                "y" => view(di_x_no_x_co, 1, ve),
                "x" => view(di_x_no_x_co, 2, ve),
                "mode" => "lines",
                "line" => Dict("color" => triangulation_line_color),
                "hoverinfo" => "skip",
            ),
        )

    end

    font = Dict("family" => "Gravitas One, monospace", "size" => node_annotation_font_size)

    push!(
        data,
        Dict(
            "legendgroup" => "Node",
            "name" => "Node ($(lastindex(no_)))",
            "y" => view(di_x_no_x_co, 1, :),
            "x" => view(di_x_no_x_co, 2, :),
            "text" => no_,
            "mode" => "markers+text",
            "marker" => Dict(
                "size" => node_marker_size,
                "opacity" => node_marker_opacity,
                "color" => node_marker_color,
                "line" =>
                    Dict("width" => node_marker_line_width, "color" => node_marker_line_color),
            ),
            "textfont" => merge(font, Dict("color" => "#ffffff")),
            "hoverinfo" => "text",
        ),
    )

    annotations = [
        Dict(
            "y" => co1,
            "x" => co2,
            "text" => "<b>$no</b>",
            "font" => merge(font, Dict("color" => node_annotation_font_color)),
            "bgcolor" => node_annotation_bgcolor,
            "borderpad" => node_annotation_borderpad,
            "borderwidth" => node_annotation_borderwidth,
            "bordercolor" => node_annotation_bordercolor,
            "arrowwidth" => node_annotation_arrowwidth,
            "arrowcolor" => node_annotation_arrowcolor,
        ) for (no, (co1, co2)) in zip(no_, eachcol(di_x_no_x_co))
    ]

    range1 = Nucleus.Collection.get_minimum_maximum(di_x_no_x_co[1, :])

    range2 = Nucleus.Collection.get_minimum_maximum(di_x_no_x_co[2, :])

    fa = 1.39

    ke_ar = (
        boundary = (range1 .* fa, range2 .* fa),
        npoints = (n_gr, n_gr),
        bandwidth = (
            Nucleus.Density.get_bandwidth(di_x_po_x_co[1, :]),
            Nucleus.Density.get_bandwidth(di_x_po_x_co[2, :]),
        ),
    )

    ro_, co_, de = Nucleus.Density.estimate((di_x_po_x_co[1, :], di_x_po_x_co[2, :]); ke_ar...)

    vp = Nucleus.Coordinate.wall(tr)

    is = [!Nucleus.Coordinate.is_in([ro, co], vp) for ro in ro_, co in co_]

    de[is] .= NaN

    push!(
        data,
        Dict(
            "type" => "contour",
            "legendgroup" => "Point",
            "showlegend" => false,
            "y" => ro_,
            "x" => co_,
            "z" => de,
            "transpose" => true,
            "ncontours" => ncontours,
            "contours" => Dict("coloring" => "none"),
            "hoverinfo" => "skip",
        ),
    )

    point = Dict(
        "legendgroup" => "Point",
        "name" => "Point ($(lastindex(po_)))",
        "y" => view(di_x_po_x_co, 1, :),
        "x" => view(di_x_po_x_co, 2, :),
        "text" => po_,
        "mode" => "markers",
        "marker" => Dict(
            "size" => point_marker_size,
            "opacity" => point_marker_opacity,
            "color" => point_marker_color,
            "line" => Dict("width" => point_marker_line_width, "color" => point_marker_line_color),
        ),
        "hoverinfo" => "text",
    )

    if isnothing(sc_)

        push!(data, point)

    elseif sc_ isa AbstractVector{<:AbstractFloat}

        push!(
            data,
            Nucleus.Dict.merge(
                point,
                Dict("marker" => Dict("color" => Nucleus.Color.color(sc_, Nucleus.Color.COBW))),
            ),
        )

    elseif sc_ isa AbstractVector{<:Integer}

        un_ = unique(sc_)

        gr_x_gr_x_un_x_pr = Array{Float64, 3}(undef, n_gr, n_gr, lastindex(un_))

        for (i3, un) in enumerate(un_)

            i2_ = findall(==(un), sc_)

            _ro_, _co_, de =
                Nucleus.Density.estimate((di_x_po_x_co[1, i2_], di_x_po_x_co[2, i2_]); ke_ar...)

            de[is] .= NaN

            gr_x_gr_x_un_x_pr[:, :, i3] = de

        end

        # TODO: Benchmark iteration order.
        for i2 in 1:n_gr, i1 in 1:n_gr

            pr_ = view(gr_x_gr_x_un_x_pr, i1, i2, :)

            if all(isnan, pr_)

                continue

            end

            ma = argmax(pr_)

            for i3 in eachindex(pr_)

                if i3 != ma

                    pr_[i3] = NaN

                end

            end

        end

        for (i3, (un, he)) in enumerate(zip(un_, Nucleus.Color.color(un_)))

            i2_ = findall(==(un), sc_)

            push!(
                data,
                Dict(
                    "type" => "heatmap",
                    "y" => ro_,
                    "x" => co_,
                    "z" => view(gr_x_gr_x_un_x_pr, :, :, i3),
                    "transpose" => true,
                    "colorscale" => Nucleus.Color.fractionate(
                        Nucleus.Color._make_color_scheme(["#ffffff", he]),
                    ),
                    "showscale" => false,
                    "hoverinfo" => "skip",
                ),
            )

            na = get(sc_na, un, un)

            push!(
                data,
                Nucleus.Dict.merge(
                    point,
                    Dict(
                        "legendgroup" => na,
                        "name" => "$na ($(lastindex(i2_)))",
                        "y" => view(di_x_po_x_co, 1, i2_),
                        "x" => view(di_x_po_x_co, 2, i2_),
                        "text" => view(po_, i2_),
                        "marker" => Dict("color" => he),
                    ),
                ),
            )

        end

    end

    axis = Dict("showgrid" => false, "zeroline" => false, "ticks" => "", "showticklabels" => false)

    Nucleus.Plot.plot(
        ht,
        data,
        Nucleus.Dict.merge(
            Dict(
                "height" => 800,
                "width" => 800,
                "title" => Dict(
                    "x" => 0.02,
                    "text" => "GPS Map",
                    "font" =>
                        Dict("family" => "Gravitas One", "size" => 32, "color" => "#000000"),
                ),
                "yaxis" => merge(axis, Dict("range" => range1, "autorange" => "reversed")),
                "xaxis" => merge(axis, Dict("range" => range2 .* 1.08)),
                #"annotations" => annotations,
            ),
            layout,
        ),
    )

end

end
