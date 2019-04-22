*** Settings ***
Documentation     A resource file with reusable keywords and variables.
...
...               The system specific keywords created here form our own
...               domain specific language. They utilize keywords provided
...               by the imported Selenium2Library.
Library           Selenium2Library

*** Variables ***
${SERVER}               localhost
${BROWSER}              Firefox
${DELAY}                .5s
${VALID USER}           admin
${VALID PASSWORD}       admin
${LOGIN URL}            http://${SERVER}/admin/portal.php?login=now
${PORTAL URL}           http://${SERVER}/admin/
${CREATE PROJECT URL}   http://${SERVER}/admin/install.php?CreateProject=1&simple=1

*** Keywords ***
Open Browser To Login Page
    Open Browser    about:    ${BROWSER}
    Delete All Cookies
    Maximize Browser Window
    Go To    ${LOGIN URL}
    Set Selenium Speed    ${DELAY}
    Login Page Should Be Open

Redirect To Install Page
    Open Browser    about:    ${BROWSER}
    Delete All Cookies
    Maximize Browser Window
    Go To    ${LOGIN URL}
    Set Selenium Speed    ${DELAY}
    Sleep    2s
    Install Page Should Be Open

Install Page Should Be Open
    Title Should Be    Create new project

Login Page Should Be Open
    Element Should Be Visible     id=CSPortalLoginUserID

Go To Login Page
    Go To    ${LOGIN URL}
    Login Page Should Be Open

Input Username
    [Arguments]    ${username}
    Input Text    CSPortalLoginUserID    ${username}

Input Password
    [Arguments]    ${password}
    Input Text    CSPortalLoginPassword   ${password}

Select First Project And Login
    Click Button    id=login
    Select From List By Value    id=CSPortalLoginSelect    1
    Click Button    id=login

Portal Page Should Be Open
    Location Should Be    ${PORTAL URL}
    Title Should Be    Welcome Page

Open Create Project Simple
    Go To   ${CREATE PROJECT URL}
    Element Should Be Visible   xpath=//*[@id="CSGuiDialogContent"]/table/tbody/tr/td/input[2]  timeout=5s

Open Create Project Extended
    Open Create Project Simple
    Click Element   xpath=//*[@id="CSGuiDialogContent"]/table/tbody/tr/td/input[2]
    Wait Until Element Is Visible   xpath=//*[@id="title_::License Details_section"]    timeout=10s
    Element Should Not Be Visible   xpath=//*[@id="CSGuiDialogContent"]/table/tbody/tr/td/input[2]

Expand Database Section
    Element Should Be Visible   xpath=//*[@id="title_::Database_section"]
    Click Element   xpath=//*[@id="title_::Database_section"]
    Wait Until Element Is Visible   xpath=//*[@id="DatabaseConnectionButton"]

Expand Webserver Section
    Element Should Be Visible   xpath=//*[@id="title_::Webserver_section"]
    Click Element   xpath=//*[@id="title_::Webserver_section"]
    Wait Until Element Is Visible   xpath=//*[@id="WebserverConnectionButton"]

Expand License Section
    Element Should Be Visible   xpath=//*[@id="title_::License Details_section"]
    Click Element   xpath=//*[@id="title_::License Details_section"]
    Wait Until Element Is Visible  xpath=//*[@id="CSLicensecore:-OrderedLicenseID"]

Create Project Expand All Sections
    ${ret_status} =   Run Keyword And Return Status   Element Should Not Be Visible    xpath=//*[@id="DatabaseConnectionButton"]
    Run Keyword If      ${ret_status}       Expand Database Section
    ${ret_status} =   Run Keyword And Return Status   Element Should Not Be Visible    xpath=//*[@id="WebserverConnectionButton"]
    Run Keyword If      ${ret_status}       Expand Webserver Section
    ${ret_status} =   Run Keyword And Return Status   Element Should Not Be Visible    xpath=//*[@id="CSLicensecore:-OrderedLicenseID"]
    Run Keyword If      ${ret_status}       Expand License Section

Fill Create Project DB Credentials
    [Arguments]     ${dbhost}    ${dbname}     ${dbuser}     ${dbpass}    ${tblprefix}
    Input Text      xpath=//*[@id="CSLicenseDatabase:-Host"]    ${dbhost}
    Input Text      xpath=//*[@id="CSLicenseDatabase:-Name"]    ${dbname}
    Input Text      xpath=//*[@id="CSLicenseDatabase:-User"]    ${dbuser}
    Input Text      xpath=//*[@id="CSLicenseDatabase:-Password"]    ${dbpass}
    Focus           xpath=//*[@id="CSLicenseDatabase:-ContentTable"]
    Wait Until Element Is Visible    xpath=//*[@id="CSGuiWindowBody"]/div[3]
    Wait Until Element Is Visible    xpath=//*[contains(@id, 'CSPortalWindow')]/div[2]/iframe
    Select Frame                     xpath=//*[contains(@id, 'CSPortalWindow')]/div[2]/iframe
    Wait Until Element Is Visible    xpath=//*[@id="userInput"]
    Input Text                       xpath=//*[@id="userInput"]    ${dbpass}
    Click Element                    xpath=//*[@id="CSGUI_MODALDIALOG_OKBUTTON"]
    Unselect Frame
    Input Text      xpath=//*[@id="CSLicenseDatabase:-ContentTable"]    ${tblprefix}

Create Project Create DB
    Click Element   xpath=//*[@id="DatabaseCreationButton"]
    Wait Until Element Contains     xpath=//*[@id="connectionState"]    CONTENTSERV is not installed    timeout=10s

Fill Project Details
    [Arguments]    ${project_name}
    Input Text    xpath=//*[@id="CSLicenseNewProject:-Name"]    ${project_name}

Fill License Details
    [Arguments]    ${csnet_username}    ${csnet_license_id}
    Click Element    xpath=//*[@id="CSLicensecore:EULA_GUI"]
    Input Text    xpath=//*[@id="CSLicensecore:-CSNetUser"]    ${csnet_username}
    Input Text    xpath=//*[@id="CSLicensecore:-OrderedLicenseID"]    ${csnet_license_id}

Proceed To Project Creation
    [Arguments]    ${csnet_password}
    Click Button    Create New Project
    Wait Until Element Is Visible    xpath=//*[@id="CSGuiWindowBody"]
    Wait Until Element Is Visible    xpath=//*[contains(@id, 'CSPortalWindow')]/div[2]/iframe
    Select Frame                     xpath=//*[contains(@id, 'CSPortalWindow')]/div[2]/iframe
    Wait Until Element Is Visible    xpath=//*[@id="userInput"]
    Input Text                       xpath=//*[@id="userInput"]    ${csnet_password}
    Click Element                    xpath=//*[@id="CSGUI_MODALDIALOG_OKBUTTON"]
    Unselect Frame
    Wait Until Page Contains    The license request has been accepted    timeout=1m
    Wait Until Page Contains    The project has been created successfully    timeout=1m
    Click Element   xpath=//a[contains(@href, 'install.php?showLicense=true')]
    Wait Until Element Is Visible    xpath=//*[@id="frm_794df3791a8c800841516007427a2aa3"]

Switch Server Type
    [Arguments]    ${server_type}    ${csnet_password}
    Select Frame    xpath=//*[@id="frm_794df3791a8c800841516007427a2aa3"]
    Select From List By Value    xpath=//*[@id="CSLicensecore:ServerType"]    ${server_type}
    Click Button    Request online
    Unselect Frame
    Wait Until Element Is Visible    xpath=//*[@id="CSGuiWindowBody"]
    Wait Until Element Is Visible    xpath=//*[contains(@id, 'CSPortalWindow')]/div[2]/iframe
    Select Frame                     xpath=//*[contains(@id, 'CSPortalWindow')]/div[2]/iframe
    Wait Until Element Is Visible    xpath=//*[@id="userInput"]
    Input Text                       xpath=//*[@id="userInput"]    ${csnet_password}
    Click Element                    xpath=//*[@id="CSGUI_MODALDIALOG_OKBUTTON"]
    Sleep   5s
    Unselect Frame
    Select Frame    xpath=//*[@id="frm_794df3791a8c800841516007427a2aa3"]
    Wait Until Page Contains    The license request has been accepted    timeout=1m
    Click Element    xpath=//*[@id="content_::GLOBAL_section"]/input[2]
    Unselect Frame
