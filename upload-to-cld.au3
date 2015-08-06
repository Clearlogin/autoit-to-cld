;===============================================================================
; Description:   Upload of CSV's to Clearlogin for Directory sync
; Author(s):    Dean Galvin - Clearlogin Inc.
;===============================================================================

;directory the files are located
$fileDir = @ScriptDir

;filenames of the csv
$fileNames = StringSplit('schools.csv students.csv staff.csv classes.csv rosters.csv', ' ')

;log filename
$logFile = FileOpen("Received.txt", 2)

;api-key for clearlogin
$apiKey = ''

;ID of your identitySource
$identitySource = ''

;options for upload
;refer to the CSV upload page in clearlogin for more info
$destroyUsers = '1'
$destroyAttributes = '0'
$requirePasswordReset = '1'
$lockUsers = '0'

;Set files to strings
Dim $files[5]
For $i = 1 to $fileNames[0]
  Local $sFile = FileOpen($fileDir & '/' & $fileNames[$i], 16)
  If $sFile = -1 Then
    FileWrite($logFile, "ERROR")
    FileWrite($logFile, $fileNames[$i])
    FileWrite($logFile, $i)
    FileWrite($logFile, $fileNames)
  EndIf
  $files[$i-1] = BinaryToString(FileRead($sFile))
  FileClose($sFile)
Next

$sBoundary = "48ef36e4f98d200acca333b46054a705b031e1fd550cd077d65fdd17d520672e"

$sPD =  '--' & $sBoundary & @CRLF
$sPD &= 'Content-Disposition: form-data; name="utf8"' & @CRLF
$sPD &= 'Content-Type: text/plain; charset=UTF-8' & @CRLF & @CRLF
$sPD &= 'true' & @CRLF
$sPD &=  '--' & $sBoundary & @CRLF
$sPD &= 'Content-Disposition: form-data; name="api_key"' & @CRLF
$sPD &= 'Content-Type: text/plain; charset=UTF-8' & @CRLF & @CRLF
$sPD &= $apiKey & @CRLF
$sPD &=  '--' & $sBoundary & @CRLF
$sPD &= 'Content-Disposition: form-data; name="options[user_destructive]"' & @CRLF
$sPD &= 'Content-Type: text/plain; charset=UTF-8' & @CRLF & @CRLF
$sPD &= $destroyUsers & @CRLF
$sPD &=  '--' & $sBoundary & @CRLF
$sPD &= 'Content-Disposition: form-data; name="options[attrs_destructive]"' & @CRLF
$sPD &= 'Content-Type: text/plain; charset=UTF-8' & @CRLF & @CRLF
$sPD &= $destroyAttributes & @CRLF
$sPD &=  '--' & $sBoundary & @CRLF
$sPD &= 'Content-Disposition: form-data; name="options[default_password_reset]"' & @CRLF
$sPD &= 'Content-Type: text/plain; charset=UTF-8' & @CRLF & @CRLF
$sPD &= $requirePasswordReset & @CRLF
$sPD &=  '--' & $sBoundary & @CRLF
$sPD &= 'Content-Disposition: form-data; name="options[default_locked]"' & @CRLF
$sPD &= 'Content-Type: text/plain; charset=UTF-8' & @CRLF & @CRLF
$sPD &= $lockUsers & @CRLF
$sPD &=  '--' & $sBoundary & @CRLF
$sPD &= 'Content-Disposition: form-data; name="identity_source"' & @CRLF
$sPD &= 'Content-Type: text/plain; charset=UTF-8' & @CRLF & @CRLF
$sPD &= $identitySource & @CRLF
$sPD &=  '--' & $sBoundary
For $i = 1 to $fileNames[0]
  $sPD &= @CRLF
  $sPD &= 'Content-Disposition: form-data; name="' & StringTrimRight($fileNames[$i], 4) &'"; filename="' & $fileNames[$i] & '"'&@CRLF
  $sPD &= 'Content-Type: text/csv' & @CRLF & @CRLF
  $sPD &= $files[$i-1] & @CRLF
  $sPD &= '--' & $sBoundary
Next
$sPD &= '--' & @CRLF
   ; 'Content-Transfer-Encoding: binary' & @CRLF & @CRLF & _
   ; $sFileRead & @CRLF & '--' & $sBoundary & '--' & @CRLF

$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
$oHTTP.Open("POST", "https://api.clearlogin.com/upload/csv-people", False)
$oHTTP.SetRequestHeader("Content-Type", 'multipart/form-data; boundary="' & $sBoundary & '"')
$oHTTP.SetTimeouts(30000,60000,30000,120000)
$oHTTP.Send(StringToBinary($sPD))
$oReceived = $oHTTP.ResponseText
$oStatusCode = $oHTTP.Status

ConsoleWrite($oStatusCode & @CRLF)
FileWrite($logFile, $oReceived)
FileClose($logFile)
