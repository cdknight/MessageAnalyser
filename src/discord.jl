# Df schema

# Sender
# Message
# UNIX Timestamp

module Discord
    using Query, CSV, DataFrames, Dates
    include("types.jl")

    function toStandardDF(fileName::String, myUsername::String)
        csvr = DataFrame(CSV.File(fileName)) # Turns into a Dataframe

        # Individual, no filtering required

        return csvr |>
            @map({
                Sender=_.Author == myUsername ? :me : :them,
                Timestamp = DateTime(_.Date, dateformat"dd-u-yy HH:MM:SS p") + Dates.Year(2000),
                Message = _.Content,
                Source = "Discord"
            }) |>
            DataFrame

    end
end
