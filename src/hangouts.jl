

module Hangouts
    using Query, JSON, DataFrames, Dates
    include("types.jl")

    # Identifier is the name of the conversation
    # This file must be created with the "simplified JSON" function that is part of Hangons (https://github.com/David-Byrne/Hangons)
    function toStandardDF(fileName::String, identifier)  
        csvr = JSON.parsefile(fileName) |>
            @filter(_["chatName"] == identifier) |>
            @map(_["messages"]) |> collect
        return csvr[1] |> @map({
                 Sender = _["sender"]["name"] == identifier ? :them : :me,
                 Timestamp = Dates.unix2datetime(_["unixtime"]),
                 Message = _["content"],
                 Source = "Hangouts"
            }) |> DataFrame 


    end
end
