module HTML
    using DataFrames

    function push(imsg)
        if imsg.Sender == :me
            html = "<div style='background-color: lightblue'>"
        elseif imsg.Sender == :them
            html = "<div style='background-color: orange'>"
        end
        html *= "<b>$(imsg.Source)<b><br>" 
        html *= "<b>$(imsg.Timestamp)<b><br>" 
        html *= "<b>$(titlecase(String(imsg.Sender)))</b><br>"
        html *= "<p>$(imsg.Message)</p>"
        html *= "</div>"
        return html
    end

    function makeHTMLFromDF(history::DataFrame, opath::String)
        totalHTML = ""
        for msg in eachrow(history)
            totalHTML *= push(msg)
        end
        open(opath, "w") do f
            println(f, totalHTML)
        end
    end
end
