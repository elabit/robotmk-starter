*** Settings ***
Documentation       TODO

Library     CryptoLibrary
...             key_path=${CURDIR}/keys
...             password=%{RMKCRYPTPW=secret}


*** Variables ***

${PASSWORD_CRYPT}   crypt:CorBEZOtizedq5WviZc7nTGiIPle6Bwd5r222Er0sUIS/7jTrkTkxmkiSwBplRa/w7wVi57itfjoPcWJZqc=

*** Test Cases ***
Test Password Equality
    [Documentation]    TODO
    ${pass}   Get Decrypted Text  ${PASSWORD_CRYPT}
    Should Be Equal As Strings  ${pass}  password123456
