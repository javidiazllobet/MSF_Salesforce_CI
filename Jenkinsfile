#!groovy
node {
    def SFDC_USERNAME //Hay que añadir aquí el usuario que tengamos conectado
    def SFDC_HOST
    def CONNECTED_APP_CONSUMER_KEY //Cambiar por el Consumer Key generado en la Parte II
    def JWT_KEY_CRED_ID = env.JWT_KEY_CRED_ID//Cambiar por las credenciales de Jenkins creadas en la Parte II
    def sfdx = tool 'sfdxtool'//Creamos una variable para usar sfdx a partir de la Custom Tool que creamos en la Parte I
    def TEST_CLASS = env.TEST_CLASS
   stage('Check sfdx tools') {
         if (isUnix()) {//Para sistemas Unix el comando varía un poco el formato
                sfdxV = sh returnStatus: true, script: "${sfdx} --version"
                //sfdxUpdate = sh returnStatus: true, script: "${sfdx} update"
                //sfdxDelta = sh returnStatus: true, script: "echo 'y' | ${sfdx} plugins:install sfdx-git-delta"
                
         }else{
                //sfdxV = bat returnStatus: true, script: "\"${sfdx}\" --version"
                //sfdxUpdate = bat returnStatus: true, script: "\"${sfdx}\" update"
                //sfdxDelta = bat returnStatus: true, script: "echo 'y' | \"${sfdx}\" plugins:install sfdx-git-delta"
         }
    }
    

    stage('Check branch name') { // Primer paso para compobar que estamos en la rama correcta
        println env.BRANCH_NAME
        if(env.BRANCH_NAME=="DEV_SF_CI"){// Este nombre es el que le demos al seleccionar el repositorio dentro del Pipeline
            SFDC_USERNAME = env.SFDC_USERNAME_DES
            SFDC_HOST = env.SFDC_HOST_DES
            CONNECTED_APP_CONSUMER_KEY =env.CONNECTED_APP_CONSUMER_KEY_DES
            println env.BUILD_URL
        }else if(env.BRANCH_NAME=="INT_SF"){
            SFDC_USERNAME = env.SFDC_USERNAME_INT
            SFDC_HOST = env.SFDC_HOST_INT
            CONNECTED_APP_CONSUMER_KEY =env.CONNECTED_APP_CONSUMER_KEY_INT
        }else if(env.BRANCH_NAME=="UAT_SF"){
            SFDC_USERNAME = env.SFDC_USERNAME_UAT
            SFDC_HOST = env.SFDC_HOST_UAT
            CONNECTED_APP_CONSUMER_KEY =env.CONNECTED_APP_CONSUMER_KEY_UAT
        }else if(env.BRANCH_NAME=="PRO_SF"){
            SFDC_USERNAME = env.SFDC_USERNAME_PRO
            SFDC_HOST = env.SFDC_HOST_PRO
            CONNECTED_APP_CONSUMER_KEY =env.CONNECTED_APP_CONSUMER_KEY_PRO
        }else{
            println sfdx
            error 'Incorrect branch' 
        }
        checkout scm
    }

        stage('generateDiffPackage') {
        if(isUnix()){
            if(env.BRANCH_NAME == "INT_SF"){
                gitDiff = sh returnStatus: true, script: "${sfdx} sgd:source:delta --to HEAD --from HEAD^ --output . "
            }

        }else{
            gitDiff = bat returnStatus: true, script: "\"${sfdx}\" sgd:source:delta --to \"HEAD\" --from \"HEAD^\" --output ."
            println gitDiff
        }
    }
        withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {        
            println "${SFDC_USERNAME}"
            println "${CONNECTED_APP_CONSUMER_KEY}"
            println "${SFDC_HOST}"
            println "${jwt_key_file}"
            stage('Deployment') {
                if (isUnix()) {//Para sistemas Unix el comando varía un poco el formato
                    rc = sh returnStatus: true, script: "${sfdx} force:auth:logout --targetusername ${SFDC_USERNAME} -p" //Hacemos logout para evitar un error
                    // Autorizamos la dev hub org
                    rc = sh returnStatus: true, script: "${sfdx} force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${SFDC_USERNAME} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
                    rc = sh returnStatus: true, script: "${sfdx} config:set defaultusername=${SFDC_USERNAME}"
                }else{//ejecutamos lo mismo para sistemas Windows
                    rc = bat returnStatus: true, script:"\"${sfdx}\" force:auth:logout --targetusername ${SFDC_USERNAME} -p"
                    rc = bat returnStatus: true, script: "\"${sfdx}\" force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${SFDC_USERNAME} --jwtkeyfile \"${jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
                    rc = bat returnStatus: true, script: "\"${sfdx}\" config:set defaultusername=${SFDC_USERNAME}"
                }
                if (rc != 0) { error 'Org authorization has failed' }

                //Realizamos el despliegue de releasePackage
                if (isUnix()) {
                    if(env.BRANCH_NAME == "INT_SF"){
                        try{
                            rmsg = sh returnStdout: true, script: "${sfdx} force:source:deploy -c -x ./package/package.xml -u ${SFDC_USERNAME} -w 300"
                            printf rmsg
                            println(rmsg)
                            rmsgDeploy = sh returnStdout: true, script: "${sfdx} force:source:deploy -x ./package/package.xml -u ${SFDC_USERNAME} -w 300"
                        }catch(Exception e){
                            error 'Validate error/deploy error'+ e.toString()    
                            }
                    }else if(env.BRANCH_NAME == "UAT_SF" || env.BRANCH_NAME == "PRO_SF"){
                        try{
                            println(env.CHECK_VALIDATION)
                        if(env.CHECK_VALIDATION == "true"){
                          rmsg =  sh returnStdout: true, script: "${sfdx} force:source:deploy -c -x ./manifest/deploy/releasePackage.xml -u ${SFDC_USERNAME} -l RunLocalTests -w 400"
                        }else{
                          if(env.BRANCH_NAME == "UAT_SF"){
                            rmsg =  sh returnStdout: true, script: "${sfdx} force:source:deploy -c -x ./manifest/deploy/releasePackage.xml -u ${SFDC_USERNAME} -w 400"
                            rmsg =  sh returnStdout: true, script: "${sfdx} force:source:deploy -x ./manifest/deploy/releasePackage.xml -u ${SFDC_USERNAME} -w 400"
                          }else if(env.BRANCH_NAME == "PRO_SF"){
                            rmsg =  sh returnStdout: true, script: "${sfdx} force:source:deploy -c -x ./manifest/deploy/releasePackage.xml -u ${SFDC_USERNAME} -l RunSpecifiedTests -r ${TEST_CLASS} -w 400"
                          }
                        }
                        }catch(Exception e){
                            error 'Validate error/deploy error'+ e.toString()   
                        }
                    }
                    
                }else{
                    try{
                        rmsg = bat returnStdout: true, script: "\"${sfdx}\" force:source:deploy -c -x ./package/package.xml -u ${SFDC_USERNAME} -w 300"
                        printf rmsg
                        println(rmsg)
                        rmsgDeploy = bat returnStdout: true, script: "\"${sfdx}\" force:source:deploy -x ./package/package.xml -u ${SFDC_USERNAME} -w 300"
                    }catch(Exception e){
                        error 'Validate error/deploy error'+ e.toString()
                    }
                }
            }
        }
}