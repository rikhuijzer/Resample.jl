resampler = Smote(; col=:y)

# Helper; used below.
function adjoin_target(y, X)
    X1 = Tables.columntable(X)
    return merge(X1, (target=y,)) |> Tables.materializer(X)
end

# Based on https://github.com/alan-turing-institute/MLJ.jl/issues/661
X = source()
y = source()
data = @node adjoin_target(y, X)
resampler_mach = machine(resampler)

data_over = MLJ.transform(resampler_mach, data)
yX_over = @node split(data_over)
y_over = @node first(yX_over)
X_over = @node last(yX_over)

# Fit on SMOTEd data.
classifier = LogisticClassifier()
mach = machine(classifier, X_over, y_over)

# Predict on non-SMOTEd data.
yhat = predict(mach, X)

mach = machine(Probabilistic(), X, y; predict=yhat)

@from_network mach begin
    mutable struct ResampledModel
        resampler=Smote(; col=:y)
        classifier=classifier
    end
end

X = (; X1=rand(200), X2=rand(200))
y = categorical(repeat(["a", "a", "a", "b"], 50))

model = ResampledModel(; classifier=LogisticClassifier())
evaluate(model, X, y; check_measure=false, measure=auc)
