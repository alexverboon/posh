
# dump scheduled tasks information


$object = @()
$allTasks = Get-ScheduledTask 

ForEach($Task in $allTasks)
{
    $properties = [ordered] @{
    TaskName = $task.TaskName
    Description = $task.Description
    ActionExecute = $task.Actions[0].Execute
    ActionArg = $task.Actions[0].Arguments
    Trigger = $task.Triggers
    Status = $task.State
    }
    $object += (New-Object -TypeName PSObject -Property $properties)
}



