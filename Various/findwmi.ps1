
# search wmi for property name specified

$SearchString = "onedrive"


foreach($class in gwmi -namespace "root\cimv2" -list)
{
    foreach($property in $class.Properties)
    {
        if($property.Name.Contains("$SearchString"))
        {
            $class.Name  + ' --- ' + $property.Name
        }
    }
}