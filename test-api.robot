*** Settings ***
Documentation
...  Hello!
...  This is an example test suite for testing the requests library keywords along with built-in library keywords
Suite Setup    Setup suite
Suite Teardown    Teardown suite
Library  DateTime
Library  RequestsLibrary
Library  JSONLibrary
Library    ../library/ip_detector.py
Test Timeout    2 minutes

*** Variables ***
${LOCATEAPI}  https://ipinfo.io
${CONVERTYODA}  https://api.funtranslations.com

*** Test Cases ***
Check geolocation of connection
    Locate my ip

Convert message to yoda version
    Convert to yoda speech  ${location}

*** Keywords ***
Setup suite
    Log datetime information
    Log  Starting the test

Teardown suite
    Log datetime information
    Log  Test execution completed

Log datetime information
    ${date}=  Get Current Date
    log  ${date}

Locate my ip
    ${IP}=  detect my public ip
    Create Session  mysession  ${LOCATEAPI}  verify=true
    ${response}=  GET On Session  mysession  /${IP}/geo
    Status Should Be  200  ${response}
    Run keyword if   "${response}" != "${EMPTY}"  Check Geolocation  ${response.json()}

Check Geolocation
    [Arguments]        ${json}
    ${location}  Get Value From Json ${json}  $.city  fail_on_empty=${True}
    ${coordinates}=  Get Value From Json    ${json}  $.loc   fail_on_empty=${True}
    Log  ${coordinates}
    Set Suite Variable    ${location}

Convert to Yoda Speech
    [Arguments]    ${location}
    ${body}=    Create Dictionary    text=Hello Padawan, you are connecting from ${location[0]}
    Create Session  yodasession  ${CONVERTYODA}
    ${response}=  POST On Session  yodasession  /translate/yoda.json?  data=${body}
    ${Yodish}  Get Value From Json ${response.json()}  $.contents.translated  fail_on_empty=${True}
    ${Normal}  Get Value From Json ${response.json()}  $.contents.text  fail_on_empty=${True}
    Should Not Be Equal As Strings    ${Normal}  ${Yodish}
