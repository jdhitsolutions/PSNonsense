# PSNonsense

![Iron Scripter](images/IronScripterLogo.png)

This module contains my solution to the Iron Scripter PowerShell challenge described at https://ironscripter.us/a-powershell-nonsense-challenge/. The point of these challenges isn't the final result. That's certainly the case with this challenge. Rather the value is learning how to use PowerShell, and maybe discovering a new technique or command. The hope is that during the course of working on the challenge, you'll improve your PowerShell scripting skills. And who knows, maybe even have a little fun along the way.

> *This was never intended as a production level module, so even though there is help documentation, it has not been completed.*

## Answering the Challenge

These were some of the specific challenge requirements.

### Create a random, nonsense word of a user specified length

```powershell
New-NonsenseWord -Length 7
```

### Create a sentence of random words of a user specified length.

Words should be of varying lengths.

```powershell
New-NonsenseSentence -WordCount 11
```

### Create a paragraph of random sentences of user specified length

Sentences should be of varying lengths.

```powershell
New-NonsenseParagraph -SentenceCount 7
```

### Create 10 sample document files of varying paragraph length

```powershell
1..10 | ForEach-Object {
    $filename = [System.IO.Path]::GetRandomFileName()
    #replace the extension
    $filename = $filename -replace "\.\w+", ".txt"
    #build the path
    $path = Join-Path -path $env:TEMP -ChildPath $filename
    #create the document
    #encode as UTF8 to save the diacritical characters
    New-NonsenseDocument -ParagraphCount (Get-Random -Minimum 3 -Maximum 10) | Out-File -FilePath $path -Encoding utf8
    #view the result
    Get-Item $path
}
```

### Create a command to create a nonsense markdown document

I created these helper, or cheater, functions to simplify the process. I could have included them in this module but decided not. All of this code could be wrapped up in a single script file. The spacings are important to create a proper markdown document.

```powershell
#cheater functions
function New-Heading {
    (New-NonsenseSentence -WordCount (Get-Random -Minimum 1 -Maximum 5)) -replace "[.!?]", ""
}

function New-CodeFence {
    $cmd = "$((New-NonsenseSentence -WordCount (Get-Random -Minimum 2 -Maximum 6)) -replace "[.!?]",'')"

    #the backtick needs to be escaped so that end result is a proper markdown code fence.
    #there should be 6 backticks.
    $cf = @"
$('`'*6)powershell
PS C:\> $cmd
$('`'*6)
"@
    $cf
}

function New-SubHead {
    Param(
        [int]$Level = 2
    )

    $h = "#"*$level
    $head = "{0} {1}" -f $h, (New-Heading)
    #write-host $head -ForegroundColor red
    $out = @"
$head


"@

    1..(Get-Random -Maximum 4) | ForEach-Object {

        $p = (New-NonsenseParagraph -SentenceCount (Get-Random -Minimum 4 -Maximum 10) -outvariable pv)

        if ((Get-Random)%3) {
            #randomly format a string
            $wds = ($p.split()).where( {$_ -match "\w+"})
            $hl = $wds | Select-Object -skip (Get-Random -Minimum 7 -Maximum ($wds.count - 20)) -First (Get-Random -Minimum 1 -Maximum 7)

            #randomly decide how to format
            Switch ((Get-Random)) {
                {$_%3} {$f = "*$($hl -join " ")*" }
                {$_%5} {$f = "__$($hl -join " ")__"}
                {$_%7} {$f = "__*$($hl -join " ")*__" }
                {$_%4} {$f = "``$($hl -join " ")``" }
                {$_%2} {$f = "[$($hl -join " ")](https://www.$(New-NonsenseWord).com)"}
            }
            #left justify to send to the here string to avoid extra spaces
            $out += ($p -replace ($hl -join " "), $f)
        } #if %3
        else {
            $out += $p
        }

        $out += "`n`n"

        <#
        the out variable is itself an array. I want to get the first item in that array,
        which will be a string and then the first character in that string.
        #>
        if ($pv[0][0] -match "[aeifuylm]") {
            #$out+="`n"
            #increment if the next level is 4 or less
            if ($level + 1 -le 4) {
                $out += New-SubHead -level ($level + 1)
            }
            else {
                #repeat the level
                $out += New-SubHead -level $level
            }
        }
        elseif ($pv[0][0] -match "[pjqrst]" ) {

            $out += New-CodeFence
            $out += "`n`n"
            #add a bit more verbiage
            $out += New-NonsenseParagraph -SentenceCount (Get-Random -Minimum 1 -Maximum 4)
        }
    } #foreach object

    $out

} #New-SubHead
```

With these functions, and assuming this module is loaded, I can build a here-string of a markdown document and save it to a file.

```powershell
$md = @"
# $(New-Heading)

$((New-SubHead).trimend())

__My additional New-Headings follow.__


"@

1..(Get-Random -maximum 5) | ForEach-Object {
    $md += New-SubHead
}

$md += "Updated *$(Get-Date)*."

$md
#encode as UTF8 to save the diacritical characters
$md | Out-File -FilePath c:\work\nonsense.md -Encoding utf8
```

Encoding the file at `UTF8` is important if you are using diacritic characters. If you open the file in VS Code, the editor will show the correct text. But the markdown preview does not.

Last updated *2020-08-07 14:53:15Z UTC*.
