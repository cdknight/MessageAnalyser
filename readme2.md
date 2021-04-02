# MessageAnalyser

No, it isn\'t that easy to set up, but it\'s quite interesting to view
the results (screenshots and more documentation coming soon). Also,
it\'s really slow.

Right now, MessageAnalyser can analyse data from

-   Discord
-   Telegram
-   iMessage

Hangouts support and perhaps Matrix support will be added in the future.

I\'m lazy, so I didn\'t actually write any chat exporters. You have to
do this manually with separate tools.

## Exporting

### Discord

To get a CSV file for Discord, use the wonderful [DiscordChatExporter
from Tyrrz](https://github.com/Tyrrz/DiscordChatExporter). If you\'re
using the GUI version (as I am, even under Linux---by using `wine`),
make sure to set the date format to `dd-MMM-yy hh:mm:ss tt`.

### iMessage

Use this tool: <https://github.com/aaronpk/iMessage-Export>.

### Telegram

This one is really easy. Just go to your DM, click the three dots, and
click \"Export chat history.\" Uncheck any media attachements (this
program only analyzes text), and then max out the \"Size limit\" slider.
Make sure you export the entire chat history, but you can change it to
whatever you want and MessageAnalyser will only analyse whatever you
supply it with.

## Usage

1.  Get into the Julia REPL and install all the required packages. You
    can simply do `julia -q --project` and then paste this in:
    `import Pkg; Pkg.instantiate()`. It might take a while to install
    everything since there are plenty of dependencies. Once this is
    done, simply type in `exit()` to exit the REPL.
2.  Once this is done, you can just run `julia src/MessageAnalyser.jl`,
    which will open up a GUI. Load in all your message histories---you
    can load in messages from multiple different sources and platforms
    and MessageAnalyser will stitch them together for you. Once this is
    done, click `Analyse` to view the graphs and the word count ratio
    for your overall message history. You can also click `Save` to save
    your entire (stitched-together) chat history as an HTML file. The
    HTML file does not have a lot of CSS, so it doesn\'t take *that*
    long to load even if the chat history is long (compared to Hangons
    Backup or the DiscordChatExporter HTML).

## Future Tasks

-   [ ] Explain the graphs
-   [ ] Add frequently/infrequently used words
-   [ ] Add Hangouts support
-   [ ] Detect conversation starting