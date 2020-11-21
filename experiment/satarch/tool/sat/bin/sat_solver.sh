#!/usr/bin/env bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
#verbose=0
thp=0
while getopts "h?vt:s:f:i:p:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  echo "Currently unsupported."
        #verbose=1
        ;;
    t)  thp=$OPTARG
        ;;
    s)  solver=$OPTARG
        ;;
    f)  filename=$OPTARG
        ;;
    i)  original_input=$OPTARG
        ;;
    p)  preprocessor=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

function interrupted(){
  kill -TERM $PID
}
trap interrupted TERM
trap interrupted INT


if [ -z $solver ] ; then
  echo "No Solver given. Exiting..."
  exit 1
fi

if [ -z $filename ] ; then
  echo "No filename given. Exiting..."
  exit 1
fi

if [ ! -f $filename ] ; then
  echo "Filename does not exist. Exiting..."
  exit 1
fi

if [ $thp == 1 ] ; then
  env=GLIBC_THP_ALWAYS=1
elif [ $thp == 2 ] ; then
  env=GLIBC_THP_2M_FRIEDNLY=1
elif [ $thp == 3 ] ; then
  env="GLIBC_THP_2M_FRIEDNLY=1 GLIBC_THP_ALWAYS=1"
else
  env=VOID=1
fi

cd "$(dirname "$0")" || (echo "Could not change directory to $0. Exiting..."; exit 1)


if [ "$solver" == "sath-berkmin561-2003" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-berkmin561-2003/BerkMin561/sath-BerkMin561"
elif [ "$solver" == "sath-berkmin62-2003" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-berkmin62-2003/BerkMin62/sath-BerkMin62"
elif [ "$solver" == "sath-cadical-sc2020-2020" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-cadical-sc2020-2020/CaDiCaL-sc2020/cadical"
elif [ "$solver" == "sath-glucose-2016" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-glucose-2016/glucose/glucose"
elif [ "$solver" == "sath-glucose-4.2.1-2019" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-glucose-4.2.1-2019/glucose-4.2.1/glucose"
elif [ "$solver" == "sath-limmat-2003" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-limmat-2003/limmat/sath-limmat"
elif [ "$solver" == "sath-maple-lcmchronobt_scavel_ewma-2019" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-maple-lcmchronobt_scavel_ewma-2019/MapleLCMChronoBT_Scavel_EWMA/MLCMCBT_S_EWMA"
elif [ "$solver" == "sath-maple-lcmdistchronobt_scavel_ewma_08all-2019" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-maple-lcmdistchronobt_scavel_ewma_08all-2019/MapleLCMDISTChronoBT_Scavel_EWMA_08ALL/MLCMCBT_S_EWMV_08ALL"
elif [ "$solver" == "sath-siege-2003" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-siege-2003/siege/sath-siege"
elif [ "$solver" == "sath-zchaff-2003" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-zchaff-2003/zchaff/sath-zchaff"
elif [ "$solver" == "sath-satzilla-2003" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-satzilla-2003/satzilla/satzilla"
elif [ "$solver" == "sath-satzilla2-2003" ] ; then
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/sath-satzilla2-2003/satzilla2/satzilla2"
elif [ "$solver" == "knuth_cnf_sat13_cdcl.sh" ] ; then
  solver_cmd="$HOME/satarch/bin/Linux_i686/knuth_cnf_sat13_cdcl.sh"
elif [ "$solver" == "knuth_cnf_sat13_cdcl_nopp.sh" ] ; then
  solver_cmd="$HOME/satarch/bin/Linux_i686/knuth_cnf_sat13_cdcl_nopp.sh"
elif [ "$solver" == "knuth_cnf_sat11_lookahead.sh" ] ; then
  solver_cmd="$HOME/satarch/bin/Linux_i686/knuth_cnf_sat11_lookahead.sh"
elif [ "$solver" == "knuth_cnf_sat11_lookahead_nopp.sh" ] ; then
  solver_cmd="$HOME/satarch/bin/Linux_i686/knuth_cnf_sat11_lookahead_nopp.sh"
elif [ "$solver" == "knuth_cnf_sat10_dpll.sh" ] ; then
  solver_cmd="$HOME/satarch/bin/Linux_i686/knuth_cnf_sat10_dpll.sh"
elif [ "$solver" == "knuth_cnf_sat10_dpll_nopp.sh" ] ; then
  solver_cmd="$HOME/satarch/bin/Linux_i686/knuth_cnf_sat10_dpll_nopp.sh"
else
  solver_cmd="$HOME/satarch/src/bin/Linux_x86_64/"$solver $*
fi


echo "Original input instance was $original_input"
echo "env $env $solver_cmd $filename"
echo
echo

echo "FILENAME:"$filename

# if [ ! -z "$preprocessor" ] & [ "$preprocessor" != "none" ]; then
#   tmpfile=$(mktemp /tmp/sat_preprocessed.XXXXXXXXX)
#   trap "rm $tmpfile" EXIT
#   if [ "$preprocessor" == "minisat2" ] ; then
#     #experiment/thp/tool/sat/bin/minisat_glibc -pre -no-solve -dimacs=/tmp/foo
#     pre_cmd="./minisat_glibc -pre -no-solve -dimacs=$tmpfile $filename"
#   elif [ "$preprocessor" == "satelite" ] ; then
#     echo "FIXME"
#     exit 1
#     pre_cmd="./satelite -pre -no-solve -dimacs=$tmpfile $filename"
#   elif [ "$preprocessor" == "glucose" ] ; then
#     pre_cmd="./glucose-4.2.1_glibc -pre  -dimacs=$tmpfile $filename"
#   else
#     echo "Preprocessor '$preprocessor' undefined. Exiting..."
#     exit 5
#   fi
#   env $env $pre_cmd &
#   PID=$!
#   wait $PID
#   filename=$tmpfile
# fi


#NOTE: if you need to redirect the solver output in the future, we suggest to use stdlog.txt
#
# run call in background and wait for finishing
env $env $solver_cmd $filename &
#alternative approach
#(export $env; $solver_cmd $filename) &
PID=$!
wait $PID
exit_code=$?
echo "Solver finished with exit code="$exit_code
exit $exit_code
