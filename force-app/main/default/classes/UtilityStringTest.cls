@isTest
public with sharing class UtilityStringTest {

    @isTest
    static void getSubStringIfMaxCharsExceeded_returnWholeString() {

        Test.startTest();
        String result = UtilityString.getSubStringIfMaxCharsExceeded('Test', 5);
        Test.stopTest();

        Assert.areEqual('Test', result, 'None of the string should have been truncated since it is shorter than the max length.');
    }

    @isTest 
    static void getSubStingIfMaxCharsExceeded_returnPartialString() {

        Test.startTest();
        String result = UtilityString.getSubStringIfMaxCharsExceeded('Test', 2);
        Test.stopTest();

        Assert.areEqual('Te', result, 'The string was not truncated to the expected value.');
    }
}