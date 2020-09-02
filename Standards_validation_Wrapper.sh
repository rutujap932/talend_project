WAG_TALEND_JOB=/home/bitwise1/utility/test_job/talend
MY_HOME=/home/bitwise1/utility/script
MODULE_DIR=/home/bitwise1/utility
##MEMORY_PARAMS=`cat ${WAG_TALEND_JOB}/${JOB_NAME}/${JOB_NAME}/$(JOB_NAME}_run.sh | grep -o "\-Xm[sx][0-9]*[A-Z]"`
MEMORY_PARAMS="-Xms2G -Xms895M -Xmx26G"
Val=0

## to get memory validation information in a memory variable
test -s ${MY_HOME}/memory.csv && rm -rf ${MY_HOME}/memory.csv

limit()
{
        MEMORY=$( echo "scale=4;${MEMORY}/1024" |bc )
}

for PARAM in ${MEMORY_PARAMS}
do
        UNIT=`echo $PARAM | awk -F "[0-9]*" '{print $NF}'`
        echo $PARAM | grep "\-Xms" 1>/dev/null
        if [[ $? == 0 ]]
        then
                        
                        if [[ $UNIT == "M" ]]
                        then
                
                                MEMORY=`echo $PARAM | grep -o "[0-9]*"`
                                limit
								
                
                        else
                                MEMORY=`echo $PARAM | grep -o "[0-9]*"`
								
                        fi
                        
                        if [[ `echo "${MEMORY} > 1.00" | bc -l` == 1 ]]
                        then
                                        echo "-Xms should not be greater than 1G" >> ${MY_HOME}/memory.csv
										val=`expr $val + 1`
										
										
                        fi
        else
                        
                        if [[ $UNIT == "M" ]]
                    then
                        
                                MEMORY=`echo $PARAM | grep -o "[0-9]*"`
                                limit
                    
                        else
                                MEMORY=`echo $PARAM | grep -o "[0-9]*"`
                                
                fi
                        
                    if [[ `echo "${MEMORY} > 25.00" | bc -l` == 1 ]]
                     then
                                 
								echo "-Xmx should not be greater than 25G" >> ${MY_HOME}/memory.csv
								val=`expr $val + 1`
								
                    fi

        fi

        done

Validation()
{
##export FIND_PATH="${WAG_TALEND_JOB}/${JOB_NAME}/${JOB_NAME}/items/${PKG_NAME}/process/"
export FIND_PATH="/home/bitwise1/utility/test_job"
export ITEM_FILES=`find ${FIND_PATH} -name "*.item" 2>/dev/null`
##export ITEM_FILES="unique_file_0.1.item"
echo "ITEM_FILES :" $ITEM_FILES


for CURRENT_ITEM_FILE in $ITEM_FILES
do
        FULL_JOB_NAME=${CURRENT_ITEM_FILE}
        . ${MY_HOME}/Job_Std_Val.sh $FULL_JOB_NAME
done

}

send_email()
{
        
        SUBJECT=" Standards validation failed "
        ###FILENAME=${MODULE_DIR}/work/${JOB_NAME}.csv
		FILENAME=/home/bitwise1/utility/work/unique.csv
        USERID=`whoami`
        #MAILID=`cat ${MY_HOME}/Mail_List.txt | grep $USERID | cut -d "|" -f2`
        MAILID=`cat Mail_List.txt | grep $USERID | cut -d "|" -f2`
        echo $MAILID
        ##MSG="Please review job ${JOB_NAME} for coding standards"
		echo -e "\n" > MSG	
		echo -e "Please review validation check file at below path :-" >> MSG
		echo -e "\n/home/bitwise1/utility/work \n" >> MSG
        ###COUNT=`cat ${MODULE_DIR}/work/${JOB_NAME}.csv | wc -l`
		COUNT=`cat /home/bitwise1/utility/work/unique.csv | wc -l`
        if [[ $COUNT -gt 5 ]]
        then
                echo $MSG | mail -a $FILENAME -s "$SUBJECT" $MAILID
				##cat $MSG | mail -s "$SUBJECT" $MAILID
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

        ##Validation
		send_email
		
        
}

main
