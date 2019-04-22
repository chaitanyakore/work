*** Settings ***
Documentation     A test suite with single test: create empty project after CS Core installation.
...
...               Test scope: check the default redirection to install.php
...               and the ability to create new empty project. 
Resource          resource.robot

*** Variables ***
${DBSERVER}          localhost
${PROJECT NAME}      RobotizedTest
${DBUSER}            root
${DBPASSWORD}        sqlr00t


*** Test Cases ***
Redirect From Login Page To Install
    Redirect To Install Page

CS Create New Project Test
    Wait Until Element Is Visible    xpath=//*[@id="CSLicenseNewProject:-Name"]
    Capture Page Screenshot    default-install-page-{index}.png
    Input Text    xpath=//*[@id="CSLicenseNewProject:-Name"]      ${PROJECT NAME}
    Input Text    xpath=//*[@id="CSLicenseDatabase:-Host"]        ${DBSERVER}
    Input Text    xpath=//*[@id="CSLicenseDatabase:-User"]        ${DBUSER}
    Input Text    xpath=//*[@id="CSLicenseDatabase:-Password"]    ${DBPASSWORD}
    Focus         xpath=//*[@id="CSGuiDialogContent"]/table/tbody/tr/td/input[1]
    Wait Until Element Is Visible    xpath=//*[@id="CSGuiWindowBody"]/div[3]
    Wait Until Element Is Visible    xpath=//*[contains(@id, 'CSPortalWindow')]/div[2]/iframe
    Select Frame    xpath=//*[contains(@id, 'CSPortalWindow')]/div[2]/iframe
    Wait Until Element Is Visible    xpath=//*[@id="userInput"]
    Input Text    xpath=//*[@id="userInput"]    ${DBPASSWORD}
    Click Element    xpath=//*[@id="CSGUI_MODALDIALOG_OKBUTTON"]
    Unselect Frame
    Click Element    xpath=//*[@id="CSGuiDialogContent"]/table/tbody/tr/td/input[1]
    Wait Until Page Contains    The project has been created successfully    timeout=1m
    [Teardown]    Close Browser
