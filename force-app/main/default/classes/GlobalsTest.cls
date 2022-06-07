/**
 * @description       : 
 * @author            : sheredia@omegacrmconsulting.com
 * @group             : 
 * @last modified on  : 06-03-2022
 * @last modified by  : sheredia@omegacrmconsulting.com
**/
@isTest
public with sharing class GlobalsTest {
    @isTest static void test() {
        Object variable = Globals.adminProfileID;
        Object variable1 = Globals.bEcoUser;
        Object variable2 = Globals.leadSources;
    }
}