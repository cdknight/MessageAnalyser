import Pkg; Pkg.activate(".")
using Gtk, JSON, Plots, Pipe
include("merge.jl")

function addSourceChooseBox(widget::GtkBox, filename = "", provider_string = "", identifier_string = "")
    hbox = GtkBox(:h)
    choose = GtkButton("Choose")
    add = GtkButton("Add")
    remove = GtkButton("Remove")

    provider = GtkComboBoxText()
    providerList = [ "Discord", "iMessage" ]
    for item in providerList
        push!(provider, item)
    end
    set_gtk_property!(provider, :active, @pipe findfirst(isequal(provider_string), providerList) |> if isnothing(_) 0 else _ - 1 end)
    
    entry = GtkEntry()
    identifier = GtkEntry()

    set_gtk_property!(entry, :editable, false)
    set_gtk_property!(entry, :width_chars, 100)
    set_gtk_property!(entry, :text, filename)

    set_gtk_property!(identifier, :placeholder_text, "Identifier")
    set_gtk_property!(identifier, :text, identifier_string)

    signal_connect(choose, "clicked") do btn
        item = open_dialog_native("Select dataset: ")
        set_gtk_property!(entry, :text, item)
    end

    signal_connect(add, "clicked") do btn
        nhbox = addSourceChooseBox(widget)
        push!(widget, nhbox)
        showall(widget)
    end

    signal_connect(remove, "clicked") do btn
        # Refuse to delete if there is only one child of the vbox
        if length(widget) > 1
            destroy(hbox)
        end
    end


    push!(hbox, entry)
    push!(hbox, choose)
    push!(hbox, provider)
    push!(hbox, identifier)
    push!(hbox, add)
    push!(hbox, remove)

    return hbox
end

function pushToGtkLabel(label::GtkLabel, item::String)
    GAccessor.text(label, get_gtk_property(label, :label, String) * item * "\n")
end


itembox = GtkBox(:v)
save = GtkButton("Save configuration")
messages = GtkLabel("")
global chatHistory = missing

function getWriteConfig(write = false)

    # Save to JSON
    sourceItems = []
    for item in itembox
        filename = get_gtk_property(item[1], :text, String)
        provider = Gtk.bytestring( GAccessor.active_text(item[3]) )
        identifier = get_gtk_property(item[4], :text, String)

        push!(sourceItems, Dict("filename" => filename, "provider" => provider, "identifier" => identifier))
    end

    if !write
        return sourceItems
    end

    open(CONFIG_LOCATION, "w") do file
        println(file, JSON.json(sourceItems))
    end

end

signal_connect(save, "clicked") do btn
    getWriteConfig(true)
end

analyse = GtkButton("Analyse")
signal_connect(analyse, "clicked") do btn
    GAccessor.text(messages, "")
    pushToGtkLabel(messages, "Loading data...")

    config = getWriteConfig()
    global chatHistory = Analysis.loadChatHistories(config)

    pushToGtkLabel(messages, Analysis.wordRatio(chatHistory))

    # Graphs
    default(reuse=false) # Open in separate windows
    gui(Analysis.graphMessageTimePatterns(chatHistory))
    gui(Analysis.messagesOverTime(chatHistory))

end

exportBtn = GtkButton("Export")
signal_connect(exportBtn, "clicked") do btn
    try
        HTML.makeHTMLFromDF(chatHistory, save_dialog_native("Choose where/what to call your export file: "))
        info_dialog("Exported chat history to the chosen file.")
    catch e
        warn_dialog("Couldn't export chat history. Maybe try clicking 'Analyse' first?")
    end
end

vbox = GtkBox(:v)
win = GtkWindow("Callbacks", 600, 600)
# push!(itembox, addSourceChooseBox(itembox))

signal_connect(win, "destroy") do w exit() end

if !isfile(CONFIG_LOCATION) write(CONFIG_LOCATION, "[]") end # Create config file
open(CONFIG_LOCATION) do config
    sources = JSON.parsefile(CONFIG_LOCATION)
    for source in sources
        push!(itembox, addSourceChooseBox(itembox, source["filename"], source["provider"], source["identifier"]))
    end
    if isempty(sources)
        push!(itembox, addSourceChooseBox(itembox))
    end
end

push!(vbox, itembox)
push!(vbox, save)
push!(vbox, analyse)
push!(vbox, exportBtn)
push!(vbox, messages)
push!(win, vbox)
showall(win)
