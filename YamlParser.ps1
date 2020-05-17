$YamlText = Get-Content -Path ".\InputYml.Yaml"

Function Get-Node()
{
  param (
      [parameter(Mandatory=$true)]
        [String]
        $Line
       )

 $Node = New-Object -TypeName PSObject

 $index = $Line.IndexOf(":")
 if($index -gt 0 )
 {
     $key = $Line.Substring(0,$index)
     $value = ""
     $value = $line.Substring(($index + 1), ($Line.Length - ($index + 1)))

     $key = $key.Trim().Trim("'").Trim('"')
     $value = $value.Trim().Trim("'").Trim('"')

     $Node | Add-Member -MemberType NoteProperty -Name "Name" -Value $key
     $Node | Add-Member -MemberType NoteProperty -Name "Value"  -Value $value
     #$Node | Add-Member -MemberType NoteProperty -Name $key  -Value $value
 }
 return $Node

}
Function Get-NodeIndent 
{
  param (
      [parameter(Mandatory=$true)]
        [String]
        $Line
       )
  $indent = 0
  $counter = 0;
  foreach($char in $Line.ToCharArray())
  {
    if($char -eq " ")
    {
      $counter++
    }
    else
    {
     break;
    }
  }
  return [int] ($counter / 2 )
}

Function Main
{

   $CurrentIndent = 0
  
   $RootNode = New-Object -TypeName PSObject
   $NodeStack = New-Object System.Collections.Stack
   $ParentStack = New-Object System.Collections.Stack
   $ParentStack.Push($RootNode)
   
   $IsArrayNode = $false
   $ArrayIndentStack = New-Object System.Collections.Stack<int>
   $ArrayStack = New-Object System.Collections.Stack
   $ArrayIndentStack.Push(0)

    ForEach($Line in $YamlText)
    {
      if(-not [string]::IsNullOrWhiteSpace($Line))
      {
       $Node = Get-Node -Line $Line
       $NodeIndent = Get-NodeIndent -Line $Line
       $PropertyName = $Node.Name
       
       if($PropertyName.StartsWith("-"))
       {
        $IsArrayNode = $true
       }
       else
       {
        $IsArrayNode = $false
        $Node.PSObject.Properties.Remove("Name")
       }
       If($IsArrayNode -or ($ArrayStack.Count -gt 0)) # Handle Array-Type & it's Child Type Node here
       {
          $CurrentArrayIndent = $ArrayIndentStack.Peek()
          if($IsArrayNode)  # New Array or Add to Existing array 
          {
              if($NodeIndent -gt $CurrentArrayIndent) # New Array
              {
                $PeekNode = $NodeStack.Peek()
                $PeekNode.PSObject.Properties.Remove("Value")
                $ArrayNode = @()
                $ArrayNode += $Node
                $PeekNode | Add-Member -MemberType  NoteProperty -Name "Value" -Value $ArrayNode
                $ArrayStack.Push($ArrayNode)
                $ArrayIndentStack.push($NodeIndent)
              }
              if($NodeIndent -eq $CurrentArrayIndent) # Add to Exsting array
              {
                 $ArrayNodeObj = $ArrayStack.Peek()
                 $ArrayNodeObj += $Node
                 $ArrayStack.Pop()
                 $ArrayStack.Push($ArrayNodeObj)
                 $PeekNode = $NodeStack.Peek()
                 $PeekNode.PSObject.Properties.Remove("Value")
                 $PeekNode | Add-Member -MemberType  NoteProperty -Name "Value" -Value $ArrayNodeObj

              }
              if($NodeIndent -lt $CurrentArrayIndent) # Parent array
              {
                  ## TO DO :: Child-Parent Array Types Currently Not handle

              } 
          }
          else   # Node is ArrayNode's Properties or New Non-Array Node (Exit Array)
          {
             if($NodeIndent -gt $CurrentArrayIndent) # ArrayNode's Properties
             {
                
                $PeekArray = $ArrayStack.Peek()
                $PeekNode = $PeekArray[$PeekArray.Count -1]
                $PeekNode | Add-Member -MemberType NoteProperty -Name $PropertyName -Value $Node.Value
             }
             else
             {
               $ArrayStack.Pop()
               $ArrayIndentStack.Pop()
               # TO DO:: Add Node to parent here If Child Array exist

             }
          }
 
        }
        if($ArrayStack.Count -eq 0)  # Handle Node here
        {
          if($NodeIndent -eq $CurrentIndent)
           {
            $PeekNode = $ParentStack.peek()
            $PeekNode | Add-Member -MemberType NoteProperty -Name $PropertyName -Value $Node
            $NodeStack.push($Node)
           }
           if($NodeIndent -gt $CurrentIndent)
           {
            $PeekNode =  $NodeStack.Peek()
        
             $PeekNode | Add-Member -MemberType NoteProperty -Name $PropertyName -Value $Node
         
             $ParentStack.push($PeekNode)
             $NodeStack.push($Node)
             $CurrentIndent = $NodeIndent
           }
           if($NodeIndent -lt $CurrentIndent)
           {
            for($i =0; $i -lt ($CurrentIndent-$NodeIndent);$i++)
            {
              $ParentStack.Pop()
            }
            $PeekNode = $ParentStack.Peek()
            $PeekNode | Add-Member -MemberType NoteProperty -Name $PropertyName -Value $Node
            $NodeStack.push($Node)
            $CurrentIndent = $NodeIndent
           }
        }

       }
    }
    $RootNode 
}

Main
