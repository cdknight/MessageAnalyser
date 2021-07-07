

module Analysis
    using Plots, Printf, Pipe, Query, DataFrames, Dates, JSON, DataStructures
    
    include("constants.jl")
    include("imessage.jl")
    include("discord.jl")
    include("telegram.jl")
    include("hangouts.jl")

    Plots.theme(:dark)
    pyplot()

    function loadChatHistories(sources = JSON.parsefile(CONFIG_LOCATION))
        # From config.json (yes, it's more inefficient, but not by a lot...

        println("Loading chat histories...")

        try
            return vcat([getfield(Analysis, Symbol(source["provider"])).toStandardDF(source["filename"], source["identifier"]) for source in sources]...) |>
            @orderby(_.Timestamp) |> DataFrame
        catch e
            println(e)
        end

    end

    function getWordList(history::DataFrame, ignoreCase::Bool = true)

        words = []
        for line in eachrow(history)
            # The flag is included since sometimes lowercase and uppercase words can have
            # very different meanings in texting, at least in my experience
            words = vcat(words, split(line.Message, " ") |>
                @map(strip(_)) |>
                @map(strip(_, [','])) |>
                @map(ignoreCase ? lowercase(_) : _) |>
                collect)
        end
        words_map = counter(words)

        return DataFrame(
            Word = [i[1] for i in words_map],
            Occurrences = [i[2] for i in words_map]
        ) 

    end

    # TODO Most used words (emojis?) (excluding commonly used English words like pronouns and articles)/least used words

    function getWordCounts(history::DataFrame)
    # you

        youCount = 0
        themCount = 0

        for line in eachrow(history)
            if !ismissing(line.Message)
                if line.Sender == :me
                    youCount += length(split(line.Message, " "))
                else
                    themCount += length(split(line.Message, " "))
                end
            end
        end

        return youCount, themCount

    end

    function graphMessageTimePatterns(history::DataFrame)

        history = history |> @map(_.Timestamp) |> collect
        historyAlpha = []
        #  add breaks to the dataframe

        for (i, item) in enumerate(history)
            if i != length(history)
                # Not first or last
                if Dates.Date(history[i + 1]) != Dates.Date(history[i])
                    push!(historyAlpha, 0) # Force discontinuity
                    continue
                end
            end
            push!(historyAlpha, 1)
        end
        println(
        "Length of history $(length(history))\nand length of historyAlpha is $(length(historyAlpha))"
        )


        # y-axis: time of message
        y = history |> @map(Dates.Time(_)) |> collect
        plot(y,
            #y,
            # yticks=Dates.value.(y),
            title = "Time-of-day over quantity of messages sent",
            ylabel = "Time of day (between 00:00 and 23:59)",
            hover = history,
            alpha = historyAlpha,
            grid=:hide)
    end

    function wordRatio(history::DataFrame)
        ratio = @pipe getWordCounts(history) |> _[1] / _[2]

        return @sprintf("You send %.3f times as much content compared to them.", ratio)
    end

    function messagesOverTime(history::DataFrame)
        dateRange = Date(history.Timestamp[1]):Day(1):Date(last(history.Timestamp))
        qtyDays = [] # Get number of messages per day
        for date in dateRange
            push!(qtyDays, nrow(history |> @filter(Date(_.Timestamp) == date) |> DataFrame))
        end
        plot(dateRange, qtyDays, title="Number of messages per day")
    end

    function messageDifferencesOverTime(history::DataFrame)
        rowSub = nrow(history)÷2
        plot(history.Timestamp[2:2:end][1:rowSub] - history.Timestamp[1:2:end][1:rowSub] |> @map(Second(_)) |> collect)
    end

    function reactions(history::DataFrame)
        # Only iMessage at the moment. We should probably add a reactions column to the DF in the future.
        return history |>
            @filter(occursin(r"(Liked|Loved|Disliked|Laughed|Emphasized|Questioned) ", string(_.Message))) |>
            DataFrame
    end

end
