#!/bin/bash 

PRG=./VSFS
FS="test.notes"
EF="EF.txt"
IF="IF.txt"
ID="somedirectory/"
NEF="nonexistent/doesntexist.txt" 
[ -e "nonexistent/doesntexist.txt" ] && rm "nonexistent/doesntexist.txt"
[ -e "nonexsistent" ] && rmdir "nonexistent"
[ -e "somedirectory" ] && rmdir "somedirectory"
[ -e "invalid.notes" ] && rm "invalid.notes"
declare -a arr=($FS $EF $IF)

for i in "${arr[@]}"
do
    [ -e $i ] && rm $i
    touch $i
done

[ -e "$FS.gz" ] && rm "$FS.gz"

printf "NOTES V1.0\n" >> $FS

touch invalid.notes
echo "gibberish" > invalid.notes

TEST=1
ERR=0
EXPECT=0
declare -a RESULTS



printf "Welcome to the test script!\n"
printf "=========================================\n"


# --------------------------------------------------COPYIN TESTS------------------------------------------------------------
printf "\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n"
printf "SECTION 1: copyin\n"
printf "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n"
# TEST 1
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0\n*Expect no content line is printed\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyin $FS $EF $IF\n\n"
$PRG copyin $FS $EF $IF
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 2
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0\n*Expect content line is printed\n*Expect file replaced with old file removed\n\n"
echo "example text" > $EF
printf "$FS Before:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyin $FS $EF $IF \n\n"
$PRG copyin $FS $EF $IF
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 3
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=2
printf "*Expect exit 2 because EF doesn't exist\n*Expect no change to FS\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyin $FS $NEF $IF \n\n"
$PRG copyin $FS $NEF.txt $IF
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 4
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 with intermediate directories created\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyin $FS $EF nodirectory/$IF \n\n"
$PRG copyin $FS $EF nodirectory/$IF
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 5
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 , file path already exists no intermediate directories created\n*Expect file copied\n\n"
$PRG mkdir $FS $ID
printf "$FS Before:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyin $FS $EF $ID$IF \n\n"
$PRG copyin $FS $EF $ID$IF
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 6
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=22
printf "*Expect exit 22 because IF path cannot be named \"/\" , \".\" , \"..\" \n*Expect FS unchanged\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyin $FS $EF . \n\n"
$PRG copyin $FS $EF .
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 7
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=22
printf "*Expect exit 22 because IF path cannot start or end in '/' \n*Expect FS unchanged\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyin $FS $EF abc/\n\n"
$PRG copyin $FS $EF abc/
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# --------------------------------------------------COPYOUT TESTS------------------------------------------------------------
printf "\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n"
printf "SECTION 2: copyout\n"
printf "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n"

printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
# TEST 8
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 because EF and intermediate paths will be created\n\n"
printf "$NEF Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $NEF
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyout $FS $IF $NEF \n\n"
$PRG copyout $FS $IF $NEF
printf "$NEF After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $NEF
printf "++++++++++++++++++++++++++++++\n"
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
cat $NEF
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 9
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=2
printf "*Expect exit 2 because IF doesn't exist\n\n"
printf "Run : $PRG copyout $FS doesntexist.txt $EF\n\n"
$PRG copyout $FS doesntexist.txt $EF
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 10
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 because IF and EF exist\n*Expect EF changed\n\n"
echo "Before copyout" > $EF
printf "$EF Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $EF
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG copyout $FS $IF $EF\n\n"
$PRG copyout $FS $IF $EF
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$EF After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $EF
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

printf "\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n"
printf "SECTION 3: mkdir\n"
printf "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n"
$PRG defrag $FS
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
# TEST 11
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=21
printf "*Expect exit 21 because directory already exists\n*Expect EF unchanged\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG mkdir $FS $ID \n\n"
$PRG mkdir $FS $ID
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 12
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=22
printf "*Expect exit 22 because directory must end in '/' \n*Expect EF unchanged\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG mkdir $FS noslashdir \n\n"
$PRG mkdir $FS noslashdir
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 13
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=22
printf "*Expect exit 22 because directory can't start with '/' \n*Expect EF unchanged\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG mkdir $FS /slashdir \n\n"
$PRG mkdir $FS /slashdir
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 14
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 because directory unique and valid name \n*Expect EF changed\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG mkdir $FS newdir/ \n\n"
$PRG mkdir $FS newdir/
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 15
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 on valid subdirectory \n*Expect EF changed\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG mkdir $FS newdir/subdir/ \n\n"
$PRG mkdir $FS newdir/subdir/
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"


# TEST 16
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=2
printf "*Expect exit 2 on invalid subdirectory \n*Expect EF unchanged\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG mkdir $FS nodir/subdir/ \n\n"
$PRG mkdir $FS nodir/subdir/
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

printf "\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n"
printf "SECTION 4: rm\n"
printf "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n"

printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
# TEST 17
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=2
printf "*Expect exit 2 when file not found \n*Expect EF unchanged\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG rm $FS nofile.txt \n\n"
$PRG rm $FS nofile.txt
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"


# TEST 18
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 when file removed \n*Expect EF changed with #\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG rm $FS $IF \n\n"
$PRG rm $FS $IF
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

printf "\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n"
printf "SECTION 5: rmdir\n"
printf "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
# TEST 19
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=2
printf "*Expect exit 2 when directory doesn't exist \n*Expect EF unchanged\n\n"
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG rmdir $FS nodir/ \n\n"
$PRG rmdir $FS nodir/
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 20
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 when directory exists \n*Expect directory deleted\n*Expect subdirectories deleted\n*Expect files deleted\n\n"
$PRG copyin $FS $EF newdir/subdir/$IF
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG rmdir $FS newdir/ \n\n"
$PRG rmdir $FS newdir/
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

printf "\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n"
printf "SECTION 6: defrag\n"
printf "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
# TEST 21
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 \n*Expect deleted records removed\n*Expect sorted by file tree sequence\n\n"
$PRG copyin $FS $EF $IF
printf "$FS Before:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n\n\n"
printf "Run : $PRG defrag $FS \n\n"
$PRG defrag $FS
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "$FS After:\n"
printf "++++++++++++++++++++++++++++++\n"
cat $FS
printf "++++++++++++++++++++++++++++++\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

printf "\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n"
printf "SECTION 7: list\n"
printf "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
# TEST 22
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 \n*Expect sorted by file tree sequence\n\n"
printf "Run : $PRG list $FS \n\n"
$PRG list $FS
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

printf "\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n"
printf "SECTION 8: other \n"
printf "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
# TEST 23
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=200
printf "*Expect exit 200 because line in notes file doesn't start with on of ' ', '=', '@' \n\n"
printf "Run : $PRG list invalid.notes \n\n"
$PRG list invalid.notes
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"


# TEST 24
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=200
printf "*Expect exit 200 because .gz file does not exist \n\n"
printf "Run : $PRG list $FS.gz \n\n"
$PRG list $FS.gz
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

# TEST 25
((++TEST))
printf "TEST ($TEST)\n"
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
let EXPECT=0
printf "*Expect exit 0 because .gz file exists\n*Expect gz files behave the same\n\n"
gzip $FS
printf "Run : $PRG list $FS.gz \n\n"
$PRG list $FS.gz
let ERR=$?
printf "Exit code: $ERR\n"
if (($EXPECT == $ERR))
then
    RESULTS[$TEST-1]=1
else
    RESULTS[$TEST-1]=0
fi
printf "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"


printf "\nUNIT TEST RESULTS: \n"
printf "========================== \n"
for i in "${!RESULTS[@]}"; do 
    result="none"
    if ((${RESULTS[$i]} == 1));
    then
        result="PASS"
    else
        result="FAIL!!!!!!!!!"
    fi
    let testnum=$i+1 
    echo "Test $testnum : $result"
done


chmod +x tests.sh