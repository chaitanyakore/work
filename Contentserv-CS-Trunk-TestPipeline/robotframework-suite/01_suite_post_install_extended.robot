*** Settings ***
Documentation     A test suite with single test: create empty project after CS Core installation.
...
...               Test scope: check the default redirection to install.php
...               and the ability to create new empty project. 
Resource          cs-resource.robot

*** Variables ***
${DBSERVER}          localhost
${PROJECT NAME}      RobotizedTest
${DBUSER}            root
${DBPASSWORD}        sqlr00t
${DBNAME}            RobotizedTest
${DBTABLE PREFIX}    rbtest_
${CSNET USER}        qa_robot
${CSNET LICENSEID}   2017-935-571
${CSNET PASSWORD}    CSQAP@ss
${VALID LOGIN}       admin
${VALID PASSWORD}    admin


*** Test Cases ***
Redirect From Login Page To Install
    Redirect To Install Page

CS Create New Project Extended Test
    Open Create Project Extended
    Create Project Expand All Sections
    Fill Project Details    ${PROJECT NAME}
    Fill Create Project DB Credentials    ${DBSERVER}    ${DBNAME}    ${DBUSER}    ${DBPASSWORD}    ${DBTABLE PREFIX}
    Create Project Create DB
    Fill License Details    ${CSNET USER}    ${CSNET LICENSEID}
    Proceed To Project Creation   ${CSNET PASSWORD}
    Switch Server Type    prod    ${CSNET PASSWORD}
    Sleep   10s
    [Teardown]    Close All Browsers
