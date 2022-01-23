
# Sender
# Message
# UNIX Timestamp

module SMS
    using Query, EzXML, DataFrames, Dates, XML2_jll

# The following constant and macro are copied from src/macro.jl in the EzXML.jl library.
const XML_GLOBAL_ERROR_STACK = EzXML.XMLError[]
macro check(ex)
    ccallex = ex.args[2]
    ex.args[2] = :ret
    quote
        @assert isempty(XML_GLOBAL_ERROR_STACK)
        ret = $(esc(ccallex))
        if !$(ex)
            throw_xml_error()
        end
        ret
    end
end

# If your XML files are massive, then the default "readxml" is broken
# This is copied from src/document.jl of the EzXML library, with fixes
function readhugexml(filename::AbstractString)
    encoding = C_NULL
    options = 1 << 12 | 1 << 19 # XML_PARSE_NODICT | XML_PARSE_HUGE
    doc_ptr = @check ccall(
        (:xmlReadFile, libxml2),
        Ptr{EzXML._Node},
        (Cstring, Ptr{UInt8}, Cint),
        filename, encoding, options) != C_NULL
    return EzXML.Document(doc_ptr)
end

function toStandardDF(fileName::String, theirIdentifier::String)
    xmlr = readhugexml(fileName) # this won't be a DataFrame
    df = DataFrame(
        Sender = Symbol[],
        Timestamp = DateTime[],
        Message = String[],
        Source = String[],
    )

    # If the XML property "type" is equal to "1" then they sent it
    # If the XML property "type" is equal to "2" then you sent it

    for msg in findall("//sms[contains(@address, \"$theirIdentifier\")]", xmlr)
        push!(df, [
            msg["type"] == "1" ? :them : :me, # Sender
            Dates.unix2datetime(parse(Int64, msg["date"]) / 1000), # Timestamp, in ms so we divide by 1000
            msg["body"], # Message
            "SMS" # Source
        ], )
    end

    return df

end
end
