*** Settings ***
Documentation     A test suite with a couple of tests for valid login and default language list.
...
...               Test scope: check the default CS login ability after initial setup with blank
...               project. If succeed, check the available language list, default
...               install should contain two entries only: English and German (Deutsch)
Resource          cs-resource.robot

*** Test Cases ***
Login Page
    Open Browser To Login Page
    Input Username    admin
    Input Password    admin
    Select First Project And Login
    Element Should Contain   xpath=/html/head/title    CS Studio

CS Studio Preferences Default Languages Test

    Select Frame    xpath=/html/body/iframe
    Select Frame    xpath=//*[@id="frame_1"]
    Wait Until Element Is Visible    xpath=//*[@id="StudioWidgetPane_e20aa82bb06b2cd4551ff728f5d58a2e_Title"]/div[1]
    Click Element    xpath=//*[@id="StudioWidgetPane_e20aa82bb06b2cd4551ff728f5d58a2e_Title"]/div[1]
    Wait Until Element Is Visible    id=StudioWidgetPane_e20aa82bb06b2cd4551ff728f5d58a2e_Content
    Select Frame    id=StudioWidgetPane_e20aa82bb06b2cd4551ff728f5d58a2e_Content
    Wait Until Element Is Visible    xpath=//*[@id="CSGuiWindowBody"]
    Wait Until Element Is Visible    xpath=//*[@id="effb153bsplitareacontentleft"]
    Wait Until Element Is Visible    xpath=//*[@id="CSStudioToolbarTitle"]
    Select Frame    name=frmTree
    Wait Until Element Is Visible    xpath=//*[@id="CS_Languages@0_ANCHOR"]
    Click Element    xpath=//*[@id="CS_Languages@0_ANCHOR"]
    Click Element    xpath=//*[@id="CS_Languages@0_ANCHOR"]
    Click Element    xpath=//*[@id="CS_Languages@0_ANCHOR"]
    Unselect Frame
    Select Frame     xpath=/html/body/iframe
    Select Frame     xpath=//*[@id="frame_1"]
    Select Frame     id=StudioWidgetPane_e20aa82bb06b2cd4551ff728f5d58a2e_Content
    Select Frame     id=main
    Wait Until Element Is Visible    xpath=//*[@id="b5753cddsplitareacontentcenter"]
    Select Frame     id=main
    Wait Until Element Is Visible    xpath=//*[@id="CSGuiListbuilderTable"]/table
    Table Should Contain    xpath=//*[@id="CSGuiListbuilderTable"]/table    English
    Table Should Contain    xpath=//*[@id="CSGuiListbuilderTable"]/table    Deutsch
    Unselect Frame
    [Teardown]    Close All Browsers
