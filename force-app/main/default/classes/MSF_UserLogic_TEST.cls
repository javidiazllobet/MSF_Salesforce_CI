/**
* @author       Deloitte
* @date         01-2019
* @group        Campaign
* @description  test class for the MSF_PaymentScheduleLogic_TDTM class.
*/
@isTest
private class MSF_UserLogic_TEST {
	 @testSetup static void setup(){
        //Create Trigger
        npsp__Trigger_Handler__c thCon = new npsp__Trigger_Handler__c(
            Name = 'test',
            npsp__Class__c = 'MSF_UserLogic_TDTM',
            npsp__Object__c = 'User',
            npsp__Trigger_Action__c = 'BeforeUpdate;BeforeInsert',
            npsp__Active__c = true,
            npsp__Load_Order__c = 1,
            npsp__User_Managed__c = true,
            npsp__Asynchronous__c = false,
            npsp__Usernames_to_Exclude__c = ''
        );        
        insert thCon; 
     }
    
    @isTest
    static void testInvalidUser() {
     
        String canvasID = [SELECT Id FROM Profile WHERE Name = 'Canvasser' LIMIT 1].Id;
        String f2fID = [SELECT Id FROM Profile WHERE Name = 'F2F Assistant' LIMIT 1].Id;

        User u = DataFactory.getUser('mail@mail.com', 'Userlogic@mail.com', 'Test', 'Last', 'TEST', canvasID);
        User u2 = DataFactory.getUser('mail@mail.com', 'Userlogic2@mail.com', 'Test', 'Last', 'TEST', f2fID);
        insert u;

        System.runAs(u){
            try{
                insert u2;
                System.assert(false, 'Debe de saltar un error por perfil incorrecto');
            }catch(Exception e){
                System.debug('Ha saltado un error porque el perfil es incorrecto, como debe ser');
            }
        }        
    }

    
    @isTest static void testValidUser() {
        String integrationID = [SELECT Id FROM Profile WHERE Name = 'Integration profile' LIMIT 1].Id;
        String canvasID = [SELECT Id FROM Profile WHERE Name = 'Canvasser' LIMIT 1].Id;

        User u = [SELECT Id FROM USER WHERE ProfileId =: integrationID AND isActive = true LIMIT 1];

        System.runAs(u){            
            try{
                User u1 = DataFactory.getUser('mail@mail.com', 'Userlogic2@mail.com', 'Test', 'Last', 'TEST', canvasID);
                insert u1;
            }catch(Exception e){                
                System.assert(false, 'Error: ' + e);
            }
        }
    }

    @isTest static void testCannotChangeProfile() {
        String integrationID = [SELECT Id FROM Profile WHERE Name = 'Integration profile' LIMIT 1].Id;
        String canvasID = [SELECT Id FROM Profile WHERE Name = 'Canvasser' LIMIT 1].Id;

        User u = [SELECT Id FROM USER WHERE ProfileId =: integrationID AND isActive = true LIMIT 1];
        User u1 = DataFactory.getUser('mail@mail.com', 'Userlogic2@mail.com', 'Test', 'Last', 'TEST', canvasID);

        insert u1;
        u1.ProfileId = integrationID;

        System.runAs(u){
            try{
                System.debug('NewUser profile ' + u1.ProfileId);
                update u1;
                System.assert(false, 'Debe saltar error porque no soy admin y estoy modificando un canvas user');
            }catch(Exception e){      
                if (e.getMessage().contains('No puedes modificar el perfil de un usuario.')){
                    System.debug('Error: ' + e);
                }else{
                    System.assert(false, 'Error: ' + e);
                }
            }
        }
    }

}