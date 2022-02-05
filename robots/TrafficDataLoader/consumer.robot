*** Settings ***
Documentation     Inhuman Insurance, Inc. Artificial Intelligence System robot.
...               Consumes traffic data work items.
Resource          shared.robot

*** Tasks ***
Consume traffic data work items
    For Each Input Work Item    Process traffic data

*** Keywords ***
Process traffic data
    ${payload}=    Get Work Item Payload
    Create Output Work Item
    ${traffic_data}=    Set Variable    ${payload}[${WORK_ITEM_NAME}]
    ${valid}=    Validate traffic data    ${traffic_data}
    IF    ${valid}
        Post traffic data to sales system    ${traffic_data}
    ELSE
        Handle invalid traffic data    ${traffic_data}
    END
    Save Work Item

Validate traffic data
    [Arguments]    ${traffic_data}
    ${country}=    Get Value From Json    ${traffic_data}    $.country
    ${valid}=    Evaluate    len("${country}") == 3
    [Return]    ${valid}

Post traffic data to sales system
    [Arguments]    ${traffic_data}
    TRY
        POST
        ...    https://robocorp.com/inhuman-insurance-inc/sales-system-api
        ...    json=${traffic_data}
        Handle traffic API OK response
    EXCEPT    AS    ${return}
        Handle traffic API error response    ${return}    ${traffic_data}
    END

Handle traffic API OK response
    Set Work Item Variable    status    DONE

Handle traffic API error response
    [Arguments]    ${return}    ${traffic_data}
    Log
    ...    Traffic data posting failed: ${traffic_data} ${return}
    ...    ERROR
    Set Work Item Variable    status    API_ERROR

Handle invalid traffic data
    [Arguments]    ${traffic_data}
    ${message}=    Set Variable    Invalid traffic data: ${traffic_data}
    Log    ${message}    WARN
    Set Work Item Variable    status    INVALID_DATA
