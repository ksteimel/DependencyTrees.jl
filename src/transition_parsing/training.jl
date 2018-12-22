abstract type TrainingOracle{T} end

include("static_oracle.jl")
include("dynamic_oracle.jl")

struct OnlineTrainer{O<:TrainingOracle,M,F,U}
    oracle::O
    model::M
    featurize::F
    update_function::U
end

function train!(trainer::OnlineTrainer{<:StaticOracle}, graph::DependencyGraph)
    f = trainer.featurize
    update = trainer.update_function
    model = trainer.model
    for (config, gold_t) in StaticGoldPairs(trainer.oracle, graph)
        features = f(config)
        prediction = model(features)
        if prediction != gold_t
            update(features, prediction, gold_t)
        end
    end
end

function train!(trainer::OnlineTrainer{<:DynamicOracle}, graph::DependencyGraph;
                choose_next = choose_next_amb)
    fx, update, model = trainer.featurize, trainer.update_function, trainer.model
    cfg = initconfig(trainer.oracle.config, graph)
    while !isfinal(cfg)
        features = fx(cfg)
        pred = model(features)
        gold = gold_transitions(trainer.oracle, cfg, graph)
        t = choose_next(pred, gold)
        if !(pred in gold)
            update(features, pred, t)
        end
        cfg = t(cfg)
    end
end