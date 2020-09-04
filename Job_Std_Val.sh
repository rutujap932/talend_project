FULL_JOB_NAME=$1
JOB_NAME=`echo $FULL_JOB_NAME | awk -F "/" '{print $NF}' |sed 's/_0.1.item//g'`
MY_HOME=/home/bitwise1/utility/script
MODULE_DIR=/home/bitwise1/utility
JOB_FOLDER=/home/bitwise1/utility/test_job
DIR=$(date +"%Y%m%d")
printf "\n"
echo "========================================"
echo "JOB_NAME : "$JOB_NAME
echo "========================================"
printf "\n"


##***********************************************************************
#Memory processing
##************************************************************************
Memory()
{

MEMORY_PARAMS=`cat ${JOB_FOLDER}/${JOB_NAME}_run.sh | grep -o "\-Xm[sx][0-9]*[A-Z]"`


for PARAM in ${MEMORY_PARAMS}
do
    UNIT=`echo $PARAM | awk -F "[0-9]*" '{print $NF}'`
    echo $PARAM | grep "\-Xms" 1>/dev/null          
    if [[ $? == 0 ]]
        then
              if [[ $UNIT == "M" ]]
                 then
                        MEMORY_VAL_Xms=`echo $PARAM | grep -o "[0-9]*"`
                        MEMORY_VAL_Xms=$( echo "scale=4;${MEMORY_VAL_Xms}/1024" |bc )                                                                
               else
                        MEMORY_VAL_Xms=`echo $PARAM | grep -o "[0-9]*"`
                                                                
              fi
                        
               MEMORY_COMP_STD_VAL_Xms=`grep -w "MEMORY" ${MY_HOME}/Standard_control_File 2>/dev/null | grep -w "Xms" | awk -F "#~#" '{print $3}'`
                                        
                if [[ `echo "${MEMORY_VAL_Xms} > ${MEMORY_COMP_STD_VAL_Xms}" | bc -l` == 1 ]]
                 then
                                                
                      COMP_TYP=" -Xms"
                      COMP_LABEL="Minimum Memory"
                      JOB_COMP_PROPERTY=""
                      JOB_COMP_PROPERTY_VAL="${MEMORY_VAL_Xms} GB"
                      STD_COMP_PROPERTY_VAL="Less Than ${MEMORY_COMP_STD_VAL_Xms} GB"   
                      Status="Failed" 
                                          
                      echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                                          
                 else
                           COMP_TYP=" -Xms"
                           COMP_LABEL="Minimum Memory"
                           JOB_COMP_PROPERTY=""
                           JOB_COMP_PROPERTY_VAL="${MEMORY_VAL_Xms} GB"
                           STD_COMP_PROPERTY_VAL="Less Than ${MEMORY_COMP_STD_VAL_Xms} GB"   
                           Status="Passed"
                                                
                        echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                                
                                         
                fi
                                                
                        
                        
      else
                        
            if [[ $UNIT == "M" ]]
            then
                        
                 MEMORY_VAL_Xmx=`echo $PARAM | grep -o "[0-9]*"`
                 MEMORY_VAL_Xmx=$( echo "scale=4;${MEMORY_VAL_Xmx}/1024" |bc )
                    
                 else
                       MEMORY_VAL=`echo $PARAM | grep -o "[0-9]*"`
                                
             fi
                                                
             MEMORY_COMP_STD_VAL_Xmx=`grep -w "MEMORY" ${MY_HOME}/Standard_control_File 2>/dev/null | grep -w "Xmx" | awk -F "#~#" '{print $3}'`
                                                

              if [[ `echo "${MEMORY_VAL_Xmx} > ${MEMORY_COMP_STD_VAL_Xmx}" | bc -l` == 1 ]]
              then
                                                
                   COMP_TYP=" -Xmx"
                   COMP_LABEL="Maximum Memory"
                   JOB_COMP_PROPERTY=""
                   JOB_COMP_PROPERTY_VAL="${MEMORY_VAL_Xmx} GB"
                   STD_COMP_PROPERTY_VAL="Less Than ${MEMORY_COMP_STD_VAL_Xmx} GB"  
                   Status="Failed"    
                   echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                   echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Memory_Standards.txt 
                                                                                                                                                                                                     
              else
                                                        
                    COMP_TYP=" -Xmx"
                    COMP_LABEL="Maximum Memory"
                    JOB_COMP_PROPERTY=""
                    JOB_COMP_PROPERTY_VAL="${MEMORY_VAL_Xmx} GB"
                    STD_COMP_PROPERTY_VAL="Less Than ${MEMORY_COMP_STD_VAL_Xmx} GB"  
                    Status="Passed"    
                    echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                                                        
                                                                
               fi

        fi

  done

}

                                                                                                                                                                                                     
#***********************************************************************
#Processable Formatting of Final Properties Files
#************************************************************************
Preprocessing_xml_formatting()
{
         ###cd /home/bitwise1/utility/test_job
                cd ${JOB_FOLDER}
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
xsltproc  ${MY_HOME}/style2.xsl ${JOB_NAME}_XML.dat >  ${JOB_NAME}_XML_PARSED.dat 2</dev/null
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

echo "" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
echo "" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
echo "Peripheral Standards" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
echo "Job_Name,Component_type,Component_label,Component_Property,Desired_Value,Current_Value,Status" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv

#**************************************************************************
#Monitor LINK Validation
#**************************************************************************
LINK_LABEL=`grep "MONITOR_CONNECTION" ${JOB_NAME}_FINAL.info | awk -F "#~#" '{print $2}'`


        for LINK in $LINK_LABEL
        do                                                                                                                                                                                           
                MONITOR_LINK=`grep "MONITOR_CONNECTION" ${JOB_NAME}_FINAL.info | grep -w "$LINK"  | awk -F "#~#" '{print  $NF}'`
                                
                if [[ $MONITOR_LINK == "false" ]]
                then
                      COMP_TYP="Monitor Connection"
                      COMP_LABEL=$LINK
                      JOB_COMP_PROPERTY=""
                      JOB_COMP_PROPERTY_VAL="False"
                      STD_COMP_PROPERTY_VAL="True"    
                      Status="Failed"       
                      echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv 
                      echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt 
                        
                else
                      COMP_TYP="Monitor Connection"
                      COMP_LABEL=$LINK
                      JOB_COMP_PROPERTY=""
                      JOB_COMP_PROPERTY_VAL="True"
                      STD_COMP_PROPERTY_VAL="True"    
                      Status="Passed"       
                      echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                              
                fi
       done
#************************************
# Pre-Post Job validation
#************************************
        ###echo -e "\nPeripheral Standards\n" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
        
        grep "tPrejob" ${JOB_NAME}_FINAL.info 1>/dev/null
        if [[ $? != 0 ]]
        then

                COMP_TYP="PreJob"
                COMP_LABEL="PreJob"
                JOB_COMP_PROPERTY=""
                JOB_COMP_PROPERTY_VAL="Missing"
                STD_COMP_PROPERTY_VAL="Present" 
                Status="Failed"       
                echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt 
               ###echo "Prejob Component Missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv

        else 
                COMP_TYP="PreJob"
                COMP_LABEL="PreJob"
                JOB_COMP_PROPERTY=""
                JOB_COMP_PROPERTY_VAL="Present"
                STD_COMP_PROPERTY_VAL="Present" 
                Status="Passed"       
                echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
        fi

        grep "tPostjob" ${JOB_NAME}_FINAL.info 1>/dev/null
        if [[ $? != 0 ]]
        then                                                                                                                                                                                         
                COMP_TYP="PostJob"
                COMP_LABEL="PostJob"
                JOB_COMP_PROPERTY=""
                JOB_COMP_PROPERTY_VAL="Missing"
                STD_COMP_PROPERTY_VAL="Present" 
                Status="Failed"    
                echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv  
                echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt                        
        else
                COMP_TYP="PostJob"
                COMP_LABEL="PostJob"
                JOB_COMP_PROPERTY=""
                JOB_COMP_PROPERTY_VAL="Present"
                STD_COMP_PROPERTY_VAL="Present" 
                Status="Passed"    
                echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv        
    
                ###echo "Postjob Component Missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
        fi

        grep "startjob" ${JOB_NAME}_FINAL.info 1>/dev/null
        if [[ $? != 0 ]]
        then
                COMP_TYP="StartJob"
                COMP_LABEL="StartJob"
                JOB_COMP_PROPERTY=""
                JOB_COMP_PROPERTY_VAL="Missing"
                STD_COMP_PROPERTY_VAL="Present" 
                Status="Failed"    
                echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt
                ###echo "startjob Joblet Missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
        else
                COMP_TYP="StartJob"
                COMP_LABEL="StartJob"
                JOB_COMP_PROPERTY=""
                JOB_COMP_PROPERTY_VAL="Present"
                STD_COMP_PROPERTY_VAL="Present" 
                Status="Passed"    
                echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                ###echo "startjob Joblet Missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
        fi

        grep "endjob" ${JOB_NAME}_FINAL.info 1>/dev/null
        if [[ $? != 0 ]]
        then
                COMP_TYP="EndJob"
                COMP_LABEL="EndJob"
                JOB_COMP_PROPERTY=""
                JOB_COMP_PROPERTY_VAL="Missing"
                STD_COMP_PROPERTY_VAL="Present" 
                Status="Failed"    
                echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt           
    
                ###echo "endjob joblet Missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
        else
                COMP_TYP="EndJob"
                COMP_LABEL="EndJob"
                JOB_COMP_PROPERTY=""
                JOB_COMP_PROPERTY_VAL="Present"
                STD_COMP_PROPERTY_VAL="Present" 
                Status="Passed"    
                echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv 
        fi                                                                                                                                                                                           

        echo $FULL_JOB_NAME | awk -F "/" '{print $NF}' | grep "_[A-Z]_0.1.item" 1>/dev/null
        if [[ $? == 0 ]]
        then
                grep "inputoutputRecordCount" ${JOB_NAME}_FINAL.info 1>/dev/null
                if [[ $? != 0 ]]
                then
                        COMP_TYP="InputoutputRecordCount Joblet"
                        COMP_LABEL="InputoutputRecordCount Joblet"
                        JOB_COMP_PROPERTY=""                                                                                                                                                         
                        JOB_COMP_PROPERTY_VAL="Missing"
                        STD_COMP_PROPERTY_VAL="Present" 
                        Status="Failed"    
                        echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                        echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt
                        ###echo "inputoutputRecordCount joblet missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                else
                        COMP_TYP="InputoutputRecordCount Joblet"
                        COMP_LABEL="InputoutputRecordCount Joblet"
                        JOB_COMP_PROPERTY=""                                                                                                                                                         
                        JOB_COMP_PROPERTY_VAL="Present"
                        STD_COMP_PROPERTY_VAL="Present" 
                        Status="Passed"    
                        echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                        ###echo "inputoutputRecordCount joblet missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                fi
        fi

        echo $FULL_JOB_NAME | awk -F "/" '{print $NF}' | grep "_[A-Z]_0.1.item" 1>/dev/null
        if [[ $? == 0 ]]
        then                                                                                                                                                                                         
                grep "readQualifiedJobContext" ${JOB_NAME}_FINAL.info 1>/dev/null
                if [[ $? != 0 ]]
                then
                        COMP_TYP="ReadQualifiedJobContext Joblet"
                        COMP_LABEL="ReadQualifiedJobContext Joblet"
                        JOB_COMP_PROPERTY=""
                        JOB_COMP_PROPERTY_VAL="Missing"
                        STD_COMP_PROPERTY_VAL="Present" 
                        Status="Failed"    
                        echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                        echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt
                        ###echo "readQualifiedJobContext joblet missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                else
                        COMP_TYP="ReadQualifiedJobContext Joblet"
                        COMP_LABEL="ReadQualifiedJobContext Joblet"
                        JOB_COMP_PROPERTY=""
                        JOB_COMP_PROPERTY_VAL="Present"
                        STD_COMP_PROPERTY_VAL="Present" 
                        Status="Passed"    
                        echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                        ###echo "readQualifiedJobContext joblet missing...!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
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
                      COMP_TYP="Connection"
                      COMP_LABEL="${RUNJOB}"
                      JOB_COMP_PROPERTY="tDie"
                      JOB_COMP_PROPERTY_VAL="tDie Missing"
                      STD_COMP_PROPERTY_VAL="tDie Present" 
                      Status="Failed"    
                      echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                      echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Peripheral_Standards.txt
                        ###echo "tDie compoenent missing for ${RUNJOB}" 
                        ###echo "tDie compoenent missing for ${RUNJOB}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv

                else
                      COMP_TYP="Connection"
                      COMP_LABEL="${RUNJOB}"
                      JOB_COMP_PROPERTY="tDie"
                      JOB_COMP_PROPERTY_VAL="tDie Present"
                      STD_COMP_PROPERTY_VAL="tDie Present" 
                      Status="Passed"    
                      echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                fi
         done        

              ###  echo -e "\nMemory Standard\n" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
               ### cat ${MY_HOME}/memory.csv >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv

                                                                                                                                                                                                     
#******************************************
# Memory Standards
#******************************************
                                                                                                                                                                                                     
echo "" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
echo "" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
echo "Memory Standards" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv             
echo "Job_Name,Component_type,Component_label,Component_Property,Desired_Value,Current_Value,Status" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv

Memory
                                                                                                                                                                                                     
                                
}

io_file_std()
{

 while read line
        do                                                                                                                                                              
               COMP_TYP=`echo ${line} | awk -F "#~#" '{print $1}'`
               COMP_LABEL=`echo ${line} | awk -F "#~#" '{print $2}'`
               JOB_COMP_PROPERTY=`echo ${line} | awk -F "#~#" '{print $3}'`
               JOB_COMP_PROPERTY_VAL=`echo ${line} | awk -F "#~#" '{print $4}'`
               STD_COMP_PROPERTY_VAL=`grep -w "${COMP_TYP}" ${MY_HOME}/Standard_control_File 2>/dev/null | grep -w "${JOB_COMP_PROPERTY}" | awk -F "#~#" '{print $3}' `                     
                                                                                                                                           
              if [[ ${JOB_COMP_PROPERTY} == "FILENAME" ]]
               then
                      SCH_NAME=""
        
                        if [[ ${JOB_COMP_PROPERTY_VAL} == "" ]]
                         then                                                                                                                                                                        
                 
                                echo "Filename of ${COMP_LABEL} is empty...!!!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv

                        else 
                                  echo ${JOB_COMP_PROPERTY_VAL} | grep "context\.WORK" 1>/dev/null
                                  if [[ $? != 0 ]]
                                   then 
                                        SCH_NAME=`grep "SHEMA:REPOSITORY_SCHEMA_TYPE" ${JOB_NAME}_FINAL.info | grep "COMP_LABEL" | awk -F "#~#" '{print $4}' | awk '{print $3}' `
                                        if [[ $? != 0 ]]
                                         then
                                                echo "Component ${COMP_LABEL} does not have repository  schema...!!!" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
                                
                                        fi
                                  fi
                                                                                                                                                                                                     
                        fi
              fi
                                                                                                                                                                        
                                                                                                                                                                        
        done < ${JOB_FOLDER}/${JOB_NAME}_FINAL_new.info
        
}

std_code_val ()
{                                                                                                                                                                       
sed -n '2,$p' ${JOB_FOLDER}/${JOB_NAME}_FINAL.info > ${JOB_FOLDER}/${JOB_NAME}_FINAL_new.info                                                            
echo "Components Standards" > ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv     

###echo "Job_Name@Component_type@Component_label@Component_Property@Desired_Value@Current_Value" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv        

echo "Job_Name,Component_type,Component_label,Component_Property,Desired_Value,Current_Value,Status" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv        
	
																																														 
while read line
do                                                                                                                                                              
COMP_TYP=`echo ${line} | awk -F "#~#" '{print $1}'`
COMP_LABEL=`echo ${line} | awk -F "#~#" '{print $2}'`
JOB_COMP_PROPERTY=`echo ${line} | awk -F "#~#" '{print $3}'`
JOB_COMP_PROPERTY_VAL=`echo ${line} | awk -F "#~#" '{print $4}'`
STD_COMP_PROPERTY_VAL=`grep -w "${COMP_TYP}" ${MY_HOME}/Standard_control_File 2>/dev/null | grep -w "${JOB_COMP_PROPERTY}" | awk -F "#~#" '{print $3}' `                     
																														   
###if [[ ${JOB_COMP_PROPERTY} == "FILENAME" ]]
### then
	  ###io_file_std
###fi

###if [[ ${STD_COMP_PROPERTY_VAL} != ${JOB_COMP_PROPERTY_VAL} && ! -z ${STD_COMP_PROPERTY_VAL} ]]

if [[ ${STD_COMP_PROPERTY_VAL} != ${JOB_COMP_PROPERTY_VAL} && ! -z ${STD_COMP_PROPERTY_VAL} ]]                                                                                         
	   
then
	Status="Failed"
	echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
	echo "${COMP_TYP}|${COMP_LABEL}|${JOB_COMP_PROPERTY}|${STD_COMP_PROPERTY_VAL}|${JOB_COMP_PROPERTY_VAL}" >> ${MODULE_DIR}/work/${DIR}/Components_Standards.txt
	
else
	if [[ ${STD_COMP_PROPERTY_VAL} == ${JOB_COMP_PROPERTY_VAL} && ! -z ${STD_COMP_PROPERTY_VAL} ]]  
	then
		Status="Passed"
		echo "${JOB_NAME},${COMP_TYP},${COMP_LABEL},${JOB_COMP_PROPERTY},${STD_COMP_PROPERTY_VAL},${JOB_COMP_PROPERTY_VAL},${Status}" >> ${MODULE_DIR}/work/${DIR}/${JOB_NAME}.csv
	fi
fi
																																						
																																						
done < ${JOB_FOLDER}/${JOB_NAME}_FINAL_new.info
}

clean_temp_files()
{

  rm -rf ${JOB_NAME}_XML.dat ${JOB_NAME}_XML_CONNECTION.dat ${JOB_NAME}_XML_NODE.dat ${JOB_NAME}_XML_PARSED.dat ${JOB_NAME}_FINAL.info  
  ###echo "removed intermediate files "             
}

                                                                                                                                                                                                     

main()
{
                
        Preprocessing_xml_formatting
        final_formatting
        std_code_val
        peripheral_std
        io_file_std
        clean_temp_files
        
}

main
