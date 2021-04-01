
# Sender
# Message
# UNIX Timestamp

module iMessage
    using Query, CSV, DataFrames, Dates
    include("types.jl")

    function toStandardDF(fileName::String, theirIdentifier::String)
        csvr = DataFrame(CSV.File(fileName)) # Turns into a Dataframe
        return csvr |>
            @filter(_.To == theirIdentifier || _.From == theirIdentifier) |>
            @map({
                Sender = isna(_.To) ? :me : :them,
                Timestamp = _.Date + _.Time,
                Message = _.Message,
                Source = "iMessage"
            }) |> DataFrame
    end
end
