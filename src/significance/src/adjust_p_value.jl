function adjust_p_value(
    pv_::Vector{Float64},
    n_te::Int64 = length(pv_);
    me::String = "benjamini_hochberg",
)::Vector{Float64}

    if me == "bonferroni"

        pv_ *= n_te

    elseif me == "benjamini_hochberg"

        so_ = sortperm(pv_)

        pv_ = pv_[so_]

        pv_ .*= n_te ./ (1:length(pv_))

        pv_ = TensorExtension.make_increasing_by_stepping_up!(pv_)[so_]

    else

        error("method is invalid.")

    end

    return clamp.(pv_, 0, 1)

end
