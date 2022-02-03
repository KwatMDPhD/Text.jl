function try_method(
    fe_::Vector{String},
    sc_::Vector{Float64},
    fe1_::Vector{String};
    so::Bool = true,
    plp::Bool = true,
    pl::Bool = true,
)::OrderedDict{String,Float64}

    if so

        sc_, fe_ = VectorExtension.sort_like([sc_, fe_])

    end

    in_ = VectorExtension.is_in(fe_, fe1_)

    ab_ = abs.(sc_)

    ina_ = in_ .* ab_

    ou_ = 1.0 .- in_

    oua_ = ou_ .* ab_

    abp_, abpr_, abpl_ = get_probability_and_cumulate(ab_)

    inap_, inapr_, inapl_ = get_probability_and_cumulate(ina_)

    oup_, oupr_, oupl_ = get_probability_and_cumulate(ou_)

    ouap_, ouapr_, ouapl_ = get_probability_and_cumulate(oua_)

    if plp

        la = Layout(xaxis_title_text = "Feature")

        if length(fe_) < 100

            la = merge(la, Layout(xaxis_tickvals = 1:length(fe_), xaxis_ticktext = fe_))

        end

        FinalFigure.plot_x_y(
            [sc_, in_];
            name_ = ["Score", "In"],
            la = merge(la, Layout(title_text = "Input")),
        )

        FinalFigure.plot_x_y(
            [ab_, abp_, abpr_, abpl_];
            name_ = ["v", "P", "Cr", "Cl"],
            la = merge(la, Layout(title_text = "Absolute")),
        )

        FinalFigure.plot_x_y(
            [ina_, inap_, inapr_, inapl_];
            name_ = ["v", "P", "Cr", "Cl"],
            la = merge(la, Layout(title_text = "In * Absolute")),
        )

        FinalFigure.plot_x_y(
            [ou_, oup_, oupr_, oupl_];
            name_ = ["v", "P", "Cr", "Cl"],
            la = merge(la, Layout(title_text = "Out")),
        )

        FinalFigure.plot_x_y(
            [oua_, ouap_, ouapr_, ouapl_];
            name_ = ["v", "P", "Cr", "Cl"],
            la = merge(la, Layout(title_text = "Out * Absolute")),
        )

    end

    me_en = OrderedDict{String,Float64}()

    for (me1, our_, oul_) in [["ou", oupr_, oupl_], ["oua", ouapr_, ouapl_]]

        for (me2, fu1) in [
            ["ks", InformationMetric.get_kolmogorov_smirnov_statistic],
            ["ris", InformationMetric.get_relative_information_sum],
            ["risw", InformationMetric.get_relative_information_sum],
            ["rid", InformationMetric.get_relative_information_difference],
            ["ridw", InformationMetric.get_relative_information_difference],
            ["sis", InformationMetric.get_symmetric_information_sum],
            ["sid", InformationMetric.get_symmetric_information_difference],
        ]

            if endswith(me2, 'w')

                arl = [abpl_]

                arr = [abpr_]

            else

                arl = []

                arr = []

            end

            fr_ = fu1(inapr_, our_, arr...)

            fl_ = fu1(inapl_, oul_, arl...)

            for (me3, en_) in [[">", fr_], ["<", fl_], ["<>", fl_ - fr_]]

                for (me4, fu2) in [
                    ["area", TensorExtension.get_area],
                    ["extreme", TensorExtension.get_extreme],
                ]

                    me = join([me1, me3, me2, me4], " ")

                    en = fu2(en_)

                    me_en[me] = en

                    if plp


                        FinalFigure.plot_x_y(
                            [fl_, fr_, en_];
                            name_ = ["Fl", "Fr", "Enrichment"],
                            la = merge(la, Layout(title_text = "Enrichment")),
                        )

                    end

                    if pl

                        plot_mountain(fe_, sc_, in_, en_, en; title_text = me)

                    end

                end

            end

        end

    end

    return me_en

end


function try_method(
    fe_::Vector{String},
    sc_::Vector{Float64},
    se_fe_::Dict{String,Vector{String}};
    so::Bool = true,
)::Dict{String,OrderedDict{String,Float64}}

    if so

        sc_, fe_ = VectorExtension.sort_like([sc_, fe_])

    end

    se_me_en = Dict{String,OrderedDict{String,Float64}}()

    for (se, fe1_) in se_fe_

        se_me_en[se] = try_method(fe_, sc_, fe1_; so = false, plp = false, pl = false)

    end

    return se_me_en

end
