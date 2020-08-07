# functions for PSNonsense

Function New-NonsenseWord {
  [cmdletbinding()]
  [outputtype([System.String])]
  [alias("nnw")]

  Param(
    [Parameter(Position = 0, HelpMessage = "Indicate the word length between 1 and 10.")]
    [ValidateRange(1, 10)]
    [int]$Length = (Get-Random -Minimum 1 -Maximum 10)
  )

  $letters = [Char[]]'abcdefghijklmnopqrstuvwxyz'
  #add some diacritical characters
  $letters += [Char]0x00EB,[Char]0x00E4,[Char]0x00E9

  -join ( $letters | Get-Random -count $Length)

}

Function New-NonsenseSentence {
  [cmdletbinding()]
  [outputtype([System.String])]
  [alias("nns")]
  Param(
    [Parameter(Position = 0, HelpMessage = "Enter the number of words in sentence between 1 and 40.")]
    [ValidateRange(1, 40)]
    [int]$WordCount = (Get-Random -Minimum 1 -Maximum 40)
  )

  function test {
    #is it now some indeterminate and random time?
    #the algorithm should return False most of the time
    $r = Get-Random -Minimum 200 -Maximum 500

    (Get-Date).millisecond -ge $r

  }

  $punct = ", ", "; ", " - ", ": "
  #define a flag to indicate if random punctuation has been inserted.
  $NoPunct = $true

  1..($WordCount - 1) | ForEach-Object -Begin {
    #make sure we start the sentence with a word
    [string]$sentence = New-NonsenseWord
  } -process {
    #insert random punctuation into the sentence, but only once
    if (($WordCount -ge 10) -AND (Test) -AND $NoPunct) {
      $sentence += $punct | Get-Random -Count 1
      $NoPunct = $False
    }
    $sentence += "{0} " -f (New-NonsenseWord)
  }

  #capitalize the first word of the sentence.
  #does the sentence end in a period, exclamation or question mark.
  #The period should be the default most of the time
  $rn = Get-Random -Maximum 100 -Minimum 1
  Switch ($rn) {
    {$_ -ge 90} {$end = "?" ; break}
    {$_ -ge 82} { $end = "!"}
    Default { $end = "."}
  }

  $out = "{0}{1}{2}" -f ([string]$sentence[0]).ToUpper(), $sentence.substring(1).TrimEnd(),$end

  $out

} #end function


Function New-NonsenseParagraph {
  [cmdletbinding()]
  [outputtype([System.String[]])]
  [alias("nnp")]
  Param(
    [Parameter(Position = 0, HelpMessage = "Enter the number of sentences in the paragraph between 1 and 25.")]
    [ValidateRange(1, 25)]
    [int]$SentenceCount = (Get-Random -Minimum 1 -Maximum 25)
  )

  $raw = 1..$SentenceCount | Foreach-object  {New-NonsenseSentence}
  ($raw -join " ").trimend()
}

Function New-NonsenseDocument {
  [cmdletbinding()]
  [outputtype([System.String[]])]
  [alias("nnd")]
  Param(
    [Parameter(Position = 0, HelpMessage = "Enter the number of paragraphs in the document between 3 and 30.")]
    [ValidateRange(3, 30)]
    [int]$ParagraphCount = (Get-Random -Minimum 3 -Maximum 30)
  )

  #insert a return after each paragraph
  1..$ParagraphCount | ForEach-Object {New-NonsenseParagraph;"`r"}

}