FULL_JOB_NAME=$1
JOB_NAME=`echo $FULL_JOB_NAME | awk -F "/" '{print $NF}' |sed 's/_0.1.item//g'`
MY_HOME=/home/bitwise1/utility/script
MODULE_DIR=/home/bitwise1/utility

echo "JOB_NAME : "$JOB_NAME



#***********************************************************************
#Processable Formatting of Final Properties Files
#************************************************************************
Preprocessing_xml_formatting()
{
		cd /home/bitwise1/utility/test_job
        /libxml2-2.9.10/xmllint --xpath '//*[local-name()="node"]' ${FULL_JOB_NAME} > ${JOB_NAME}_XML_NODE.dat
        /libxml2-2.9.10/xmllint --xpath '//*[local-name() ="connection"]' ${FULL_JOB_NAME} > ${JOB_NAME}_XML_CONNECTION.dat
        cat ${JOB_NAME}_XML_NODE.dat ${JOB_NAME}_XML_CONNECTION.dat > ${JOB_NAME}_XML.dat
        sed -i "s/<\/node><node/<\/node>\n  <node/g"  ${JOB_NAME}_XML.dat
        sed -i '1i <data>' ${JOB_NAME}_XML.dat
        echo -e "\n</data>" >> ${JOB_NAME}_XML.dat
        
#********************* Removing Tag <nodeData> and its data ***************
cmd="sed -i '"
COUNT_START=0;
COUNT_ENDI=0;
START_TAG=`cat -n ${JOB_NAME}_XML.dat | grep -i "<nodedata" | awk  '{print $1}'`
END_TAG=`cat -n ${JOB_NAME}_XML.dat | grep -i "</nodedata" | awk  '{print $1}'`
for i in $START_TAG
do 
        COUNT_START=$(($COUNT_START +1))
        for j in $END_TAG
        do
                COUNT_ENDI=$((COUNT_ENDI  + 1))
                if [ $COUNT_START == $COUNT_ENDI ]
                then
                                cmd="$cmd${i}, ${j}d;"
                fi
        done
COUNT_ENDI=0
done
  
cmd="${cmd}' ${JOB_NAME}_XML.dat"
eval "$cmd"

#***************************************************************
}

final_formatting()
{
CURR_COMP_LBL=""
xsltproc  ${MY_HOME}/style2.xsl ${JOB_NAME}_XML.dat >  ${JOB_NAME}_XML_PARSED.dat
test -s ${JOB_NAME}_FINAL.info  && rm -rf  ${JOB_NAME}_FINAL.info
sed -i 's/\\/#/g' ${JOB_NAME}_XML_PARSED.dat
##sed -i '1d' ${JOB_NAME}_XML_PARSED.dat
while read line
do
        CURR_JOB_PROPERTY=`echo  ${line} | awk -F "#~#" '{print $3}'`
                
        if [[ ${CURR_JOB_PROPERTY} == "UNIQUE_NAME" ]]
        then
                CURR_COMP_LBL=`echo ${line} | awk -F "#~#" '{print $4}'`
        fi
echo ${line} | sed "s/#~##~#/#~#${CURR_COMP_LBL}#~#/1" >> ${JOB_NAME}_FINAL.info
done < ${JOB_NAME}_XML_PARSED.dat

#*************************************************************************
sed -i '/^$/d' ${JOB_NAME}_FINAL.info
}



#***********************************************************************
# Job Code Validation
#************************************************************************
STD_COMP_PROPERTY_VAL=""
JOB_COMP_PROPERTY_VAL=""
COMP_LABEL=""

peripheral_std()
{
#**************************************************************************
#Monitor LINK Validation
#**************************************************************************
LINK_LABEL=`grep "MONITOR_CONNECTION" ${JOB_NAME}_FINAL.info | awk -F "#~#" '{print $2}'`


        for LINK in $LINK_LABEL
        do
                MONITOR_LINK=`grep "MONITOR_CONNECTION" ${JOB_NAME}_FINAL.info | grep -w "$LINK"  |awk -F "#~#" '{print  $NF}'`
                                
                        if [[ $MONITOR_LINK == "false" ]]
                        then
                                #echo "JOB ${JOB_NAME} -Link monitor of ${LINK} not matched:"
                                #echo "Desired: true"
                                #echo "Cureent: ${MOnitor_LINK}"
                                echo "${JOB_NAME}" "@${LINK}@MONITOR_CONNECTION @true@${MONITOR_LINK}" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
                        fi
        done
#************************************
# Pre-Post Job validation
#************************************
        echo -e "\nPeripheral Standards\n" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
        
        grep "tPrejob" ${JOB_NAME}_FINAL.info 1>/dev/null
        if [[ $? != 0 ]]
        then
               echo "Prejob Component Missing...!" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
        fi

        grep "tPostjob" ${JOB_NAME}_FINAL.info 1>/dev/null
        if [[ $? != 0 ]]
        then
               echo "Postjob Component Missing...!" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
        fi

        grep "startjob" ${JOB_NAME}_FINAL.info 1>/dev/null
        if [[ $? != 0 ]]
        then
               echo "startjob Joblet Missing...!" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
        fi

        grep "endjob" ${JOB_NAME}_FINAL.info 1>/dev/null
        if [[ $? != 0 ]]
        then
               echo "endjob joblet Missing...!" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
        fi

        echo $FULL_JOB_NAME | awk -F "/" '{print $NF}' | grep "_[A-Z]_0.1.item" 1>/dev/null
        if [[ $? == 0 ]]
        then
                grep "inputoutputRecordCount" ${JOB_NAME}_FINAL.info 1>/dev/null
                if [[ $? != 0 ]]
                then
                        echo "inputoutputRecordCount joblet missing...!" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
                fi
        fi

        echo $FULL_JOB_NAME | awk -F "/" '{print $NF}' | grep "_[A-Z]_0.1.item" 1>/dev/null
        if [[ $? == 0 ]]
        then
                grep "readQualifiedJobContext" ${JOB_NAME}_FINAL.info 1>/dev/null
                if [[ $? != 0 ]]
                then
                        echo "readQualifiedJobContext joblet missing...!" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
                fi
        fi
#******************************************
# Die On Error Job Validation for tRunJob
#******************************************

        TRUNJOB=`grep "connection" ${JOB_NAME}_FINAL.info | grep "tRunJob" | awk -F "#~#" '{print $3}'`
        for RUNJOB in $TRUNJOB
        do
                grep "connection" ${JOB_NAME}_FINAL.info | grep "${RUNJOB}" | grep "tDie" 1>/dev/null
                if [[ $? != 0 ]]
                then
                        echo "tDie compoenent missing for ${RUNJOB}" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
                                fi
                done        

		echo -e "\nMemory Standard\n" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
		cat ${MY_HOME}/memory.csv >> ${MODULE_DIR}/work/${JOB_NAME}.csv
				
}

io_file_std()
{
        SCH_NAME=""
        
        if [[ ${JOB_COMP_PROPERTY_VAL} == "" ]]
        then
                echo "Filename of ${COMP_LABEL} is empty...!!!" >> ${MODULE_DIR}/work/${JOB_NAME}.csv

        else 
                echo ${JOB_COMP_PROPERTY_VAL} | grep "context\.WORK" 1>/dev/null
                if [[ $? != 0 ]]
                then 
                        SCH_NAME=`grep "SHEMA:REPOSITORY_SCHEMA_TYPE" ${JOB_NAME}_FINAL.info | grep "COMP_LABEL" | awk -F "#~#" '{print $4}' | awk '{print $3}' `
                        if [[ $? != 0 ]]
                        then
                                echo "Component ${COMP_LABEL} does not have repository  schema...!!!" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
                        fi
                fi
        fi
}

std_code_val ()
{                                                                                                                                                                       
                                                                                                                                                                        
        echo "\n\"SEP=@\"" > ${MODULE_DIR}/work/${JOB_NAME}.csv
		##echo "Components Standards@X@Y@Z@A@B" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
		
		
		
        echo "Job_Name@Component_type@Component_label@Component_Property@Desired_Value@Current_Value" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
        while read line
        do                                                                                                                                                              
                        COMP_TYP=`echo ${line} | awk -F "#~#" '{print $1}'`
                        COMP_LABEL=`echo ${line} | awk -F "#~#" '{print $2}'`
                        JOB_COMP_PROPERTY=`echo ${line} | awk -F "#~#" '{print $3}'`
                        JOB_COMP_PROPERTY_VAL=`echo ${line} | awk -F "#~#" '{print $4}'`
                        STD_COMP_PROPERTY_VAL=`grep -w "${COMP_TYP}" ${MY_HOME}/Standard_control_File 2>/dev/null | grep -w "${JOB_COMP_PROPERTY}" | awk -F "#~#" '{print $3}' `                                                                                                                                                                
                
                        if [[ ${JOB_COMP_PROPERTY} == "FILENAME" ]]
                        then
                                io_file_std
                        fi
                                                                                                                                                                        
                                                                                                                                                                        
                
                        if [[ ${STD_COMP_PROPERTY_VAL} != ${JOB_COMP_PROPERTY_VAL} && ! -z ${STD_COMP_PROPERTY_VAL} ]]
                        then
                            echo "${JOB_NAME}@${COMP_TYP}@${COMP_LABEL}@${JOB_COMP_PROPERTY}@${STD_COMP_PROPERTY_VAL}@${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${JOB_NAME}.csv
                        fi
                                                                                                                                                                        
        done < ${JOB_NAME}_FINAL.info
}

clean_temp_files()
{
        
		rm -rf ${JOB_NAME}_XML.dat ${JOB_NAME}_XML_CONNECTION.dat ${JOB_NAME}_XML_NODE.dat ${JOB_NAME}_XML_PARSED.dat ${JOB_NAME}_FINAL.info
        echo "removed"
                
}

###-------Comented, for one mail ------###
send_email()
{
        
        SUBJECT=" Standards validation failed "
        ##FILENAME=${MODULE_DIR}/work/${JOB_NAME}.csv
        USERID=`whoami`
        #MAILID=`cat ${MY_HOME}/Mail_List.txt | grep $USERID | cut -d "|" -f2`
        MAILID=`cat ${MY_HOME}/Mail_List.txt | grep $USERID | cut -d "|" -f2`
        echo $MAILID
        ##MSG="Please review job ${JOB_NAME} for coding standards"
		MSG="
			Please review validation check file at below path :- 
				/home/bitwise1/utility/work 
			
			"
        COUNT=`cat ${MODULE_DIR}/work/${JOB_NAME}.csv | wc -l`
        if [[ $COUNT -gt 5 ]]
        then
                ##echo $MSG | mail -a $FILENAME -s "$SUBJECT" $MAILID
				echo $MSG | mail -s "$SUBJECT" $MAILID
                if [[ $? -eq 0 ]]
                then
                        echo "mail sent"
                else
                        echo "issues occured"
                fi
        fi
}                                    


main()
{

        Preprocessing_xml_formatting
        final_formatting
        std_code_val
        peripheral_std
        clean_temp_files
        ##send_email
        
}

main
