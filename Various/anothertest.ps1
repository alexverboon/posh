

ForEach ($Event in $events) {            
    # Convert the event to XML            
    $eventXML = [xml]$Event.ToXml()            
    # Iterate through each one of the XML message properties            
    For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {            
        # Append these as object properties    
        
        write-host $eventXML.Event.EventData.Data[$i].name 
        write-host $eventXML.Event.EventData.Data[$i].'#text' 

        
                
        #Add-Member -InputObject $Event -MemberType NoteProperty -Name  $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text' -Force
    }            
} 