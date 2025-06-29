#! /bin/sh
#
##########
# Creator: Bruce Kogami
# Date: 06/10/2021
# Updated ssh-keygen command: 06/08/2023

##########
ARCHT=`uname -s`
DATE=`date +%m%d%Y`
TIME=`date +%H%M%S`
TODAYsec=`date +%s`
HOST=`uname -n`
NRCHK=/home/security/disa_NR_checks
INDrpt=0

##################
# Custom variables
##################
NRtitle="V-230230"
NRtitle2="V-230230"
ItemNo=6
##################

# If OUTDIR is not already set from run_disa_NR_checks_21to40.sh script then set it
if [ x$OUTDIR = x ]; then
   OUTDIR="${NRCHK}/${HOST}/${DATE}"
   INDrpt=1
fi

# Add OUTLOG variables.
OUTLOG_disa_NR_checks=$OUTLOG
OUTLOG="${OUTDIR}/${NRtitle2}_${DATE}.${TIME}"
OUTLOG_BM="${OUTDIR}/${NRtitle2}_BM"

if [ x$disa_NR_checks = x0 ]; then
   # If Yes to individual logs set in run_disa_NA_checks_21to40.sh
   INDrpt=1
fi

# Create destination directory if it doesn't exist
if [ ! -d $OUTDIR ]; then
   mkdir -p $OUTDIR
fi

if [ ! -d $OUTDIR ]; then
   printf "Was not able to create $OUTDIR\n"
   printf "\n"
   exit 1
fi

# Check if isso group exists
getent group isso > /dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "Could not find an isso group. Please create an isso group before"
   echo "running this script."
   echo
   exit 1
fi

##########

# [PASS] in green
P="[\033[22;32mPASS\033[0m]"

# [WARN] highlighted in yellow
W="[\033[22;43mWARN\033[0m]"

# [FAIL] highlighted in red
F="[\033[22;41mFAIL\033[0m]"

CLAMERR=0

tbar2() {
TBAR3="################################################################################"
printf "%-75s\n" $TBAR3
}
### title bar for sections

tbar() {
echo " "
TBAR3="################################################################################"
printf "%-75s\n" $TBAR3
printf " $1 $HOST\n"
tbar2
}

#####################################################################
tbar "${ItemNo}. ${NRtitle} - CAT II; RHEL 8, for certificate-based authentication, must enforce authorized access to the corresponding private key." | tee -a $OUTLOG

printf "\n" | tee -a $OUTLOG

#####################################################################
# Add your Discussion and Check Text here.
cat << EOF | tee -a $OUTLOG

Discussion: 
If an unauthorized user obtains access to a private key without a passcode, that user would have unauthorized access to any system where the associated public key has been installed.


#####################################################################
Check Text: 
Verify the SSH private key files have a passcode.

For each private key stored on the system, use the following command:

$ sudo ssh-keygen -y -f /path/to/file

If the contents of the key are displayed, this is a finding.

#####################################################################
Fix Text: 
Create a new private and public key pair that utilizes a passcode with the following command:

$ sudo ssh-keygen -N [passphrase]


#####################################################################

EOF
#####################################################################

# Checker commands

Pass=0
Fail=0
HOST=`uname -n`
test=pass

printf "\n" | tee -a $OUTLOG
printf -- "--------------------------------------------------------------\n" | tee -a $OUTLOG
printf "Note: This will look through valid home directories.\n" | tee -a $OUTLOG
printf "      A successful check will prompt you for a password. You will need to hit enter a few times for it to continue.\n" | tee -a $OUTLOG
printf -- "--------------------------------------------------------------\n" | tee -a $OUTLOG
printf "\n" | tee -a $OUTLOG

ChkLocalUsers ()
{
echo "================================" | tee -a $OUTLOG
echo "Checking local /etc/passwd file" | tee -a $OUTLOG

MINUID=`cat /etc/login.defs | grep UID_MIN | grep -v SYS_UID_MIN | awk '{print $2}'`
export MINUID
for USER in `awk -F: '$1 !~ /^root$/ && $2 !~ /^[!*]/ {print $1}' /etc/shadow`; do
    echo "------------------" | tee -a $OUTLOG
    #echo $USER | tee -a $OUTLOG
    #semanage login -l | grep $USER > /dev/null 2>&1
    printf "Checking $USER\n" | tee -a $OUTLOG
    ls /home/${USER}/.ssh/id_* 2> /dev/null | grep -v pub > /dev/null
    if [ $? -ne 0 ]; then
       printf "$USER does not have a private key. Skipping check.\n" | tee -a $OUTLOG
    else
       for key_file in `ls /home/${USER}/.ssh/id_* 2> /dev/null | grep -v pub`; do
          if [ -f $key_file ]; then
          # Check if the private key is encrypted
             if ssh-keygen -y -P "" -f "$key_file" > /dev/null 2>&1; then
               printf "$F\tFor $USER, Private key $key_file is NOT password protected.\n" | tee -a $OUTLOG
               test=fail
             else
               printf "$P\tFor $USER, Private key $key_file IS password protected.\n" | tee -a $OUTLOG
             fi
          fi
       done
    fi
done
printf "\n" | tee -a $OUTLOG
}

# Get Centrify users
ChkCentrifyUsers ()
{
echo "================================" | tee -a $OUTLOG
echo "Checking Centrify" | tee -a $OUTLOG
echo "" | tee -a $OUTLOG
adinfo | grep -w connected > /dev/null 2>&1
if [ $? -eq 0 ]; then
   for USER in `adquery user | awk -F: '{print $1}'`; do
      #echo $USER
      echo "------------------" | tee -a $OUTLOG
      #semanage login -l | grep $USER >> $OUTLOG
      printf "Checking $USER\n" | tee -a $OUTLOG
      ls /home/${USER}/.ssh/id_* 2> /dev/null | grep -v pub > /dev/null
      if [ $? -ne 0 ]; then
         printf "$USER does not have a private key. Skipping check.\n" | tee -a $OUTLOG
      else
         for key_file in `ls /home/${USER}/.ssh/id_* 2> /dev/null | grep -v pub`; do
            if [ -f $key_file ]; then
            # Check if the private key is encrypted
               if ssh-keygen -y -P "" -f "$key_file" > /dev/null 2>&1; then
                 printf "$F\tFor $USER, Private key $key_file is NOT password protected.\n" | tee -a $OUTLOG
                 test=fail
               else
                 printf "$P\tFor $USER, Private key $key_file IS password protected.\n" | tee -a $OUTLOG
               fi
            fi
         done
      fi
   done
else
   printf "$NA\tCentrify is not used. Skipping.\n" | tee -a $OUTLOG
fi
printf "\n" | tee -a $OUTLOG
}

# Get AD users
ChkADUsers ()
{
echo "================================" | tee -a $OUTLOG
echo "Checking Active Directory" | tee -a $OUTLOG
echo "" | tee -a $OUTLOG
getent passwd | grep -F @ | grep -v -F $ > /dev/null 2>&1
if [ $? -eq 0 ]; then
   for USER in `getent passwd | grep '\@' | grep -v -F $ | awk -F: '{print $1}'`; do
      #echo $USER
      echo "------------------" | tee -a $OUTLOG
      #semanage login -l | grep $USER >> $OUTLOG
      printf "Checking $USER\n" | tee -a $OUTLOG
      ls /home/${USER}/.ssh/id_* 2> /dev/null | grep -v pub > /dev/null
      if [ $? -ne 0 ]; then
         printf "$USER does not have a private key. Skipping check.\n" | tee -a $OUTLOG
      else
         for key_file in `ls /home/${USER}/.ssh/id_* 2> /dev/null | grep -v pub`; do
            if [ -f $key_file ]; then
            # Check if the private key is encrypted
               if ssh-keygen -y -P "" -f "$key_file" > /dev/null 2>&1; then
                 printf "$F\tFor $USER, Private key $key_file is NOT password protected.\n" | tee -a $OUTLOG
                 test=fail
               else
                 printf "$P\tFor $USER, Private key $key_file IS password protected.\n" | tee -a $OUTLOG
               fi
            fi
         done
      fi




      #if [ $? -ne 0 ]; then
      #   printf "$F\tAD user $USER does not have SELinux role set.\n" | tee -a $OUTLOG
      #   test1=fail
      #else
      #   printf "$P\tAD user $USER has a SELinux role set.\n" | tee -a $OUTLOG
      #fi
   done
else
   printf "$NA\tCould not find any users in Active Directory. Skipping.\n" | tee -a $OUTLOG
   printf "\n" | tee -a $OUTLOG
   printf "Note:\n" | tee -a $OUTLOG
   printf "\tIf Active Directory is used for authentication, you may need to temporarily update\n" | tee -a $OUTLOG
   printf "\t/etc/sssd/sssd.conf with:\n" | tee -a $OUTLOG
   printf "\tenumerate = true\n" | tee -a $OUTLOG
   printf "\tThen, restart sssd (systemctl restart sssd)\n" | tee -a $OUTLOG
   printf "\n" | tee -a $OUTLOG
   printf "\tOnce done, remove enumerate = true from /etc/sssd/sssd.conf and restart sssd.\n" | tee -a $OUTLOG
   printf "\n" | tee -a $OUTLOG
fi
printf "\n" | tee -a $OUTLOG
}

ChkLocalUsers
ChkCentrifyUsers
ChkADUsers

######################################################################
# Final Results

printf "\n" | tee -a $OUTLOG
printf "######################################\n" | tee -a $OUTLOG
printf "\n" | tee -a $OUTLOG
printf -- "------- Final Result ------------\n" | tee -a $OUTLOG

if [ $test = fail ]; then
   printf "$F\t${ItemNo}. $NRtitle has failed\n" | tee -a $OUTLOG
   printf "Finding\n" > $OUTLOG_BM
   printf "$NRtitle has a finding.\\\n\n" >> $OUTLOG_BM
   printf "Type 'more $OUTLOG' for details on failure.\n" >> $OUTLOG_BM
else
   printf "$P\t${ItemNo}. $NRtitle has passed\n" | tee -a $OUTLOG
   printf "Not_a_Finding\n" > $OUTLOG_BM
   printf "$NRtitle has passed\\\n\n" >> $OUTLOG_BM
   printf "Type 'more $OUTLOG' for additional details.\n" >> $OUTLOG_BM
fi
printf "\n" | tee -a $OUTLOG

######################################################################

##########



##### End of EDIT #####
##########################
# Secure $NRCHK for reports

PERM=`stat -c "%a_%U_%G" ${NRCHK}`
if [ $PERM != "2750_root_isso" ]; then
   chgrp isso ${NRCHK}
   chmod 2750 ${NRCHK}
fi

PERM=`stat -c "%a_%U_%G" ${NRCHK}/${HOST}`
if [ $PERM != "2750_root_isso" ]; then
   chgrp isso ${NRCHK}/${HOST}
   chmod 2750 ${NRCHK}/${HOST}
fi

for DIR in `find ${NRCHK}/${HOST} -maxdepth 1 -type d`; do
   PERM=`stat -c "%a_%U_%G" ${DIR}`
   if [ $PERM != "2750_root_isso" ]; then
      chgrp isso ${DIR}
      chmod 2750 ${DIR}
   fi
done

for FILE in `find ${NRCHK}/${HOST} -maxdepth 1 -type f`; do
   PERM=`stat -c "%a_%U_%G" ${FILE}`
   if [ $PERM != "640_root_isso" ]; then
      chgrp isso ${FILE}
      chmod 640 ${FILE}
   fi
done

for DIR in `find ${NRCHK}/${HOST}/${DATE} -type d`; do
   PERM=`stat -c "%a_%U_%G" ${DIR}`
   if [ $PERM != "2750_root_isso" ]; then
      chgrp isso ${DIR}
      chmod 2750 ${DIR}
   fi
done

for FILE in `find ${NRCHK}/${HOST}/${DATE} -type f`; do
   PERM=`stat -c "%a_%U_%G" ${FILE}`
   if [ $PERM != "640_root_isso" ]; then
      chgrp isso ${FILE}
      chmod 640 ${FILE}
   fi
done

# If No to individual logs then remove the individual report
if [ $INDrpt -eq 0 -a -f $OUTLOG ]; then
   # Concat individual report to entire disa_NR_checks report
   cat $OUTLOG >> $OUTLOG_disa_NR_checks
   rm -rf $OUTLOG
else
   printf "######################################\n" | tee -a $OUTLOG
   printf "This individual report is best viewed using the more command: 'more $OUTLOG'\n" | tee -a $OUTLOG
   printf "\n" | tee -a $OUTLOG
   printf "${NRtitle} check has been completed.\n" | tee -a $OUTLOG
   printf "\n" | tee -a $OUTLOG
   if [ x$OUTLOG_disa_NR_checks != x ]; then
      # Concat individual report to entire disa_NR_checks report
      cat $OUTLOG >> $OUTLOG_disa_NR_checks
   fi
   if [ x$OUTLOG != x ]; then
      chown root:isso $OUTLOG
      chmod 640 $OUTLOG
   fi
fi

if [ x$OUTLOG_disa_NR_checks != x ]; then
   chown root:isso $OUTLOG_disa_NR_checks
   chmod 640 $OUTLOG_disa_NR_checks
fi


