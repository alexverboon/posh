<#
.Synopsis
   New-Office365User
.DESCRIPTION
   The New-Office365User cmdlet creates a new user within the Office 365 Tenant 
   and assigns a license. 

.EXAMPLE
   New-Office365User -UserprincipalName "Bruce.Dickinson@r2th.onmicrosoft.com" -Displayname "Bruce Dickinson" -firstName "Bruce" -lastName "Dickinson" -Password "pass@word2" -City "London" -country "United Kingdom" -Verbose

.NOTES
   Usage location logic adopted from 
   https://gallery.technet.microsoft.com/office/Setting-Office-365-Usage-4d685175

#>
function New-Office365User
{
    [CmdletBinding()]
    Param
    (
        # UserprincipalName
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $UserprincipalName,
        # Displayname
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $Displayname,
        # firstName
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $firstName,
        # lastName
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $lastName,
        # Password
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $Password,
        # City
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $City,
        # country
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $country
    )

    Begin
    {
        # compose the string for the default license to be applied
        $AccountName = (Get-MsolAccountSku | Select-Object AccountName).AccountName[0]
        $LicenseFlag = "ENTERPRISEWITHSCAL"
        $DefaultLicense = $AccountName + ":" + "$LicenseFlag" 

        # 249 Official country codes from - https://www.iso.org/obp/ui
        # Please also see http://office.microsoft.com/en-001/business/microsoft-office-license-restrictions-FX103037529.aspx for more official Office 365 Licensing restrictions
        $CountryHashTable = @{ `
        "Afghanistan" = "AF"; `
        "Åland Islands" = "AX"; `
        "Albania" = "AL"; `
        "Algeria" = "DZ"; `
        "American Samoa" = "AS"; `
        "Andorra" = "AD"; `
        "Angola" = "AO"; `
        "Anguilla" = "AI"; `
        "Antarctica" = "AQ"; `
        "Antigua and Barbuda" = "AG"; `
        "Argentina" = "AR"; `
        "Armenia" = "AM"; `
        "Aruba" = "AW"; `
        "Australia" = "AU"; `
        "Austria" = "AT"; `
        "Azerbaijan" = "AZ"; `
        "Bahamas" = "BS"; `
        "Bahrain" = "BH"; `
        "Bangladesh" = "BD"; `
        "Barbados" = "BB"; `
        "Belarus" = "BY"; `
        "Belgium" = "BE"; `
        "Belize" = "BZ"; `
        "Benin" = "BJ"; `
        "Bermuda" = "BM"; `
        "Bhutan" = "BT"; `
        "Bolivia" = "BO"; `
        "Bonaire, Sint Eustatius and Saba" = "BQ"; `
        "Bosnia and Herzegovina" = "BA"; `
        "Botswana" = "BW"; `
        "Bouvet Island" = "BV"; `
        "Brazil" = "BR"; `
        "British Indian Ocean Territory" = "IO"; `
        "Brunei Darussalam" = "BN"; `
        "Bulgaria" = "BG"; `
        "Burkina Faso" = "BF"; `
        "Burundi" = "BI"; `
        "Cabo Verde" = "CV"; `
        "Cambodia" = "KH"; `
        "Cameroon" = "CM"; `
        "Canada" = "CA"; `
        "Cayman Islands" = "KY"; `
        "Central African Republic" = "CF"; `
        "Chad" = "TD"; `
        "Chile" = "CL"; `
        "China" = "CN"; `
        "Christmas Island" = "CX"; `
        "Cocos (Keeling) Islands" = "CC"; `
        "Colombia" = "CO"; `
        "Comoros" = "KM"; `
        "Congo" = "CG"; `
        "Congo (DRC)" = "CD"; `
        "Cook Islands" = "CK"; `
        "Costa Rica" = "CR"; `
        "Côte d'Ivoire" = "CI"; `
        "Croatia" = "HR"; `
        "Cuba" = "CU"; `
        "Curaçao" = "CW"; `
        "Cyprus" = "CY"; `
        "Czech Republic" = "CZ"; `
        "Denmark" = "DK"; `
        "Djibouti" = "DJ"; `
        "Dominica" = "DM"; `
        "Dominican Republic" = "DO"; `
        "Ecuador" = "EC"; `
        "Egypt" = "EG"; `
        "El Salvador" = "SV"; `
        "Equatorial Guinea" = "GQ"; `
        "Eritrea" = "ER"; `
        "Estonia" = "EE"; `
        "Ethiopia" = "ET"; `
        "Falkland Islands (Malvinas)" = "FK"; `
        "Faroe Islands" = "FO"; `
        "Fiji" = "FJ"; `
        "Finland" = "FI"; `
        "France" = "FR"; `
        "French Guiana" = "GF"; `
        "French Polynesia" = "PF"; `
        "French Southern Territories" = "TF"; `
        "Gabon" = "GA"; `
        "Gambia" = "GM"; `
        "Georgia" = "GE"; `
        "Germany" = "DE"; `
        "Ghana" = "GH"; `
        "Gibraltar" = "GI"; `
        "Greece" = "GR"; `
        "Greenland" = "GL"; `
        "Grenada" = "GD"; `
        "Guadeloupe" = "GP"; `
        "Guam" = "GU"; `
        "Guatemala" = "GT"; `
        "Guernsey" = "GG"; `
        "Guinea" = "GN"; `
        "Guinea-Bissau" = "GW"; `
        "Guyana" = "GY"; `
        "Haiti" = "HT"; `
        "Heard Island and McDonald Islands" = "HM"; `
        "Holy See (Vatican City State)" = "VA"; `
        "Honduras" = "HN"; `
        "Hong Kong" = "HK"; `
        "Hungary" = "HU"; `
        "Iceland" = "IS"; `
        "India" = "IN"; `
        "Indonesia" = "ID"; `
        ### Not currently available as a usage location in Office 365 ### "Iran (the Islamic Republic of)" = "IR"; `
        "Iraq" = "IQ"; `
        "Ireland" = "IE"; `
        "Isle of Man" = "IM"; `
        "Israel" = "IL"; `
        "Italy" = "IT"; `
        "Jamaica" = "JM"; `
        "Japan" = "JP"; `
        "Jersey" = "JE"; `
        "Jordan" = "JO"; `
        "Kazakhstan" = "KZ"; `
        "Kenya" = "KE"; `
        "Kiribati" = "KI"; `
        ### Not currently available as a usage location in Office 365 ### "Korea (the Democratic People's Republic of)" = "KP"; `
        "Korea, Republic of" = "KR"; `
        "Kuwait" = "KW"; `
        "Kyrgyzstan" = "KG"; `
        "Lao People's Democratic Republic" = "LA"; `
        "Latvia" = "LV"; `
        "Lebanon" = "LB"; `
        "Lesotho" = "LS"; `
        "Liberia" = "LR"; `
        "Libya" = "LY"; `
        "Liechtenstein" = "LI"; `
        "Lithuania" = "LT"; `
        "Luxembourg" = "LU"; `
        "Macao" = "MO"; `
        "Macedonia, the former Yugoslav Republic of" = "MK"; `
        "Madagascar" = "MG"; `
        "Malawi" = "MW"; `
        "Malaysia" = "MY"; `
        "Maldives" = "MV"; `
        "Mali" = "ML"; `
        "Malta" = "MT"; `
        "Marshall Islands" = "MH"; `
        "Martinique" = "MQ"; `
        "Mauritania" = "MR"; `
        "Mauritius" = "MU"; `
        "Mayotte" = "YT"; `
        "Mexico" = "MX"; `
        "Micronesia" = "FM"; `
        "Moldova" = "MD"; `
        "Monaco" = "MC"; `
        "Mongolia" = "MN"; `
        "Montenegro" = "ME"; `
        "Montserrat" = "MS"; `
        "Morocco" = "MA"; `
        "Mozambique" = "MZ"; `
        ### Not currently available as a usage location in Office 365 ### "Myanmar" = "MM"; `
        "Namibia" = "NA"; `
        "Nauru" = "NR"; `
        "Nepal" = "NP"; `
        "Netherlands" = "NL"; `
        "New Caledonia" = "NC"; `
        "New Zealand" = "NZ"; `
        "Nicaragua" = "NI"; `
        "Niger" = "NE"; `
        "Nigeria" = "NG"; `
        "Niue" = "NU"; `
        "Norfolk Island" = "NF"; `
        "Northern Mariana Islands" = "MP"; `
        "Norway" = "NO"; `
        "Oman" = "OM"; `
        "Pakistan" = "PK"; `
        "Palau" = "PW"; `
        "Palestine, State of" = "PS"; `
        "Panama" = "PA"; `
        "Papua New Guinea" = "PG"; `
        "Paraguay" = "PY"; `
        "Peru" = "PE"; `
        "Philippines" = "PH"; `
        "Pitcairn" = "PN"; `
        "Poland" = "PL"; `
        "Portugal" = "PT"; `
        "Puerto Rico" = "PR"; `
        "Qatar" = "QA"; `
        "Réunion" = "RE"; `
        "Romania" = "RO"; `
        "Russian Federation" = "RU"; `
        "Rwanda" = "RW"; `
        "Saint Barthélemy" = "BL"; `
        "Saint Helena, Ascension and Tristan da Cunha" = "SH"; `
        "Saint Kitts and Nevis" = "KN"; `
        "Saint Lucia" = "LC"; `
        "Saint Martin" = "MF"; `
        "Saint Pierre and Miquelon" = "PM"; `
        "Saint Vincent and the Grenadines" = "VC"; `
        "Samoa" = "WS"; `
        "San Marino" = "SM"; `
        "Sao Tome and Principe" = "ST"; `
        "Saudi Arabia" = "SA"; `
        "Senegal" = "SN"; `
        "Serbia" = "RS"; `
        "Seychelles" = "SC"; `
        "Sierra Leone" = "SL"; `
        "Singapore" = "SG"; `
        "Sint Maarten" = "SX"; `
        "Slovakia" = "SK"; `
        "Slovenia" = "SI"; `
        "Solomon Islands" = "SB"; `
        "Somalia" = "SO"; `
        "South Africa" = "ZA"; `
        "South Georgia and the South Sandwich Islands" = "GS"; `
        "South Sudan " = "SS"; `
        "Spain" = "ES"; `
        "Sri Lanka" = "LK"; `
        "Sudan" = "SD"; `
        "Suriname" = "SR"; `
        "Svalbard and Jan Mayen" = "SJ"; `
        "Swaziland" = "SZ"; `
        "Sweden" = "SE"; `
        "Switzerland" = "CH"; `
        "Syrian Arab Republic" = "SY"; `
        "Taiwan" = "TW"; `
        "Tajikistan" = "TJ"; `
        "Tanzania" = "TZ"; `
        "Thailand" = "TH"; `
        "Timor-Leste" = "TL"; `
        "Togo" = "TG"; `
        "Tokelau" = "TK"; `
        "Tonga" = "TO"; `
        "Trinidad and Tobago" = "TT"; `
        "Tunisia" = "TN"; `
        "Turkey" = "TR"; `
        "Turkmenistan" = "TM"; `
        "Turks and Caicos Islands" = "TC"; `
        "Tuvalu" = "TV"; `
        "Uganda" = "UG"; `
        "Ukraine" = "UA"; `
        "United Arab Emirates" = "AE"; `
        "United Kingdom" = "GB"; `
        "United States" = "US"; `
        "United States Minor Outlying Islands" = "UM"; `
        "Uruguay" = "UY"; `
        "Uzbekistan" = "UZ"; `
        "Vanuatu" = "VU"; `
        "Venezuela, Bolivarian Republic of" = "VE"; `
        "Viet Nam" = "VN"; `
        "Virgin Islands, British" = "VG"; `
        "Virgin Islands, U.S." = "VI"; `
        "Wallis and Futuna" = "WF"; `
        "Western Sahara*" = "EH"; `
        "Yemen" = "YE"; `
        "Zambia" = "ZM"; `
        "Zimbabwe" = "ZW"; `
        };

        # trying to match the country value with a two letter code country, skiping the user if no match was found
		if ($CountryHashTable.Item($country))
		{ 
            # setting the value of UsageLocation if a two letter country code was matched
            $UsageLocation = $CountryHashTable.Item($Country)
        }
        Else 
		{
            # set US as the default when no matching country code was found
            $UsageLocation = "US" 
        }

    }
    Process
    {
      New-MsolUser -UserPrincipalName "$UserprincipalName" -DisplayName "$Displayname" -FirstName "$firstName" -LastName "$lastName" -LicenseAssignment $DefaultLicense -Password $Password -City "$City" -Country "$country" -UsageLocation $UsageLocation
    }
    End
    {

    }
}


