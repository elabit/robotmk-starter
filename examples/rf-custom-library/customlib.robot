*** Settings ***
Documentation  This suite demonstrates the use of a custom library, written with a simple Python class.
Library  CustomLibrary.py

*** Test Cases ***

Test Hello 
    Say Hello  Robots

Test Addition
    ${result}=  Add Numbers  44  11
    Log  ${result}