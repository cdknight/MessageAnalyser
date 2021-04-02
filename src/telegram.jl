module Telegram

using Query, JSON, DataFrames, Dates

function toStandardDF(fileName::String, identifier)

    csvr = JSON.parsefile(fileName)["messages"]
    identifier = parse(Int, identifier)

    return csvr |>
        @filter(haskey(_, "from_id")) |>
        @map({
            Sender = _["from_id"] == identifier ? :me : :them,
            Timestamp = parse(DateTime, _["date"]),
            Message = handleTelegramsAwfulMessageContentSystem(_["text"]),
            Source = "Telegram"
        }) |> DataFrame

end

function handleTelegramsAwfulMessageContentSystem(item)::String
    # Two ways this works

    if typeof(item) == String return item end

    # An array

    totalAggregate = ""
    for subitem in item # No, this is not recursive.
        if typeof(subitem) == String
            totalAggregate *= subitem
        else
            totalAggregate *= subitem["text"]
        end
    end
    return totalAggregate
end

end
