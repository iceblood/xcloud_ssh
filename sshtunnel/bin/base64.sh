#!./bash

################################################################################ 
# Function Name:   HELP_USAGE                                                   
# Description:     Function to display the usage of the script                  
# Parameters:      None                                                         
# Return:          Help messages                                                
# Called By:       Script Main Loop->Script Parameters' Handler                 
# History:         2013-Dec-31 Initial Edition                       RobinHoo  
################################################################################

function help_usage(){
cat <<EOF
BASE64 ENCODE & DECODE BASH SCRIPT
Usage: $PROGNAME [OPTION]... [FILE]
  -d, --decode Decode the base64 encoded file
  -h, --help   Show current help message of the script usages
    

Please Report Script Bugs to $AUTHOR_MAIL
EOF
exit 1
}

function BASE64ENCODE()
{
        busybox hexdump -ve '1/1 "%d "' < "$FNAME"|awk -v B64="$BASE64CODE" '{for(i=1;i<=NF;i+=3){t=0;t=$i*256*256+$(i+1)*256+$(i+2);for(j=3;j>=0;j--){c=(i+2-j<=NF)?substr(B64,int(t/2^(6*j))+1,1):"=";printf("%c",c);t%=2^(6*j);if (++k==76) printf"\n";k%=76}}}'
}

function BASE64DECODE()
{
        local buff=""
        for buff in $(cat < "$FNAME"|awk -v B64="$BASE64CODE" '{while(length()){split(substr($0,1,4),a,"");$0=substr($0,5);t=0;for(i=3;i>=0;i--) t=t+2^(6*i)*((a[4-i]=="=")?0:index(B64,a[4-i])-1);for (i=2;i>=0;i--) if (a[4-i]!="="){printf("\\x%x",t/2^(8*i));t=t%2^(8*i)}}printf"\n"}');do printf "$buff"; done
}
BASE_DIR=$(cd "$(dirname "$0")" && pwd)
PROGNAME=$(basename "$0")
AUTHOR_MAIL="robin.hoo@hotmail.com"
BASE64CODE="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
DECODE=0;
HELP=0;
FNAME="";
while [ $# -gt 0 ]
do
    case "$1" in
    (-d)        DECODE=1;;
    (-h)        HELP=1;;
    (--decode)  DECODE=1;;
    (--help)    HELP=1;;
    (-*)        echo "$PROGNAME: error - unrecognized option or parameter $1" 1>&2; HELP=1;break;;
    (*)         [ "$FNAME" != "" ] && echo "$PROGNAME: error - more than one file name " 1>&2 && HELP=1 && break || FNAME="$1";;
    esac
    shift
done
[ $# -gt 1 ] && HELP=1
[ "$FNAME" == "" ] && FNAME="/dev/stdin"
[ $HELP -eq 1 ] && help_usage

[ $DECODE -eq 1 ] && BASE64DECODE || BASE64ENCODE 