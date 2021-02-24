#!/usr/bin/env bash

# >>>>>> Set variables 
custom_conda_location="$HOME/System/programs/anaconda3" # Set when anaconda (or miniconda) is not installed in the default location
conda_env_name="nesthdb" # name of conda environment, default should be "rb" 
dpdb_location="Dresden/3sem/project/fixing_bug/dp_on_dbs" # DPDB location
clingo_location="$HOME/System/programs/anaconda3/bin/clingo"
# <<<<<<<<<<<<<<<<<<<<


# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
#verbose=0

thp=0
preprocessor="none"
while getopts "h?vt:s:f:i:p:x:" opt; do
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
    x)  semantics=$OPTARG
	;;
    esac
done

shift $((OPTIND-1))

function interrupted(){
  kill -TERM $PID
}
trap interrupted TERM
trap interrupted INT


if [ -z "$solver" ] ; then
  echo "No Solver given. Exiting..."
  exit 1
fi

if [ -z "$filename" ] ; then
  echo "No filename given. Exiting..."
  exit 1
fi

if [ -z "$semantics" ] ; then
  echo "No semantics given. Exiting..."
  exit 1
fi

if [ ! -f "$filename" ] ; then
  echo "Filename does not exist. Exiting..."
  exit 1
fi

if [ "$thp" == 1 ] ; then
  env=GLIBC_THP_ALWAYS=1
else
  env=VOID=1
fi

cd "$(dirname "$0")" || (echo "Could not change directory to $0. Exiting..."; exit 1)


if [ "$solver" == "mu_toksia" ] ; then
    if [ "$semantics" == "stable" ] ; then
        sem="EE-ST"
    elif [ "$semantics" == "complete" ] ; then
        sem="EE-CO"     
    else 
        echo "Given semantics not supported by $solver. Exiting..."
        exit 1
    fi    
    solver_cmd="$env ./run_mu_toksia.sh $sem $filename"
elif [ "$solver" == "aspartix" ] ; then
    if [ "$semantics" == "stable" ] ; then
        sem="aspartix/stable.dl"
    elif [ "$semantics" == "complete" ] ; then
        sem="aspartix/comp.dl" ;    
    elif [ "$semantics" == "admissible" ] ; then
        sem="aspartix/adm.dl"
    else 
        echo "Given semantics not supported by $solver. Exiting..."
        exit 1
    fi    
    # clingo required
    solver_cmd="$clingo_location $filename $sem aspartix/filter.lp 0 --quiet=3"
elif [ "$solver" == "dpdb" ] ; then
    # purge databases
    ./purgeDB.sh
    if [ "$semantics" == "stable" ] ; then
        sem="CEStable"
    elif [ "$semantics" == "complete" ] ; then
        sem="CEComplete" ;    
    elif [ "$semantics" == "admissible" ] ; then
        sem="CEAdmissible2"
    else 
        echo "Given semantics not supported by $solver. Exiting..."
        exit 1
    fi        
else 
    echo "No solver $solver available. Exiting..."
    exit 1
fi 


echo "Original input instance was $original_input"


#NOTE: if you need to redirect the solver output in the future, we suggest to use stdlog.txt
#
# run call in background and wait for finishing
if [ "$solver" == "dpdb" ]; then
  echo "c Activating Conda environment"
  if [ -d "$HOME/miniconda3/" ]; then
	echo "miniconda3"
    	myconda="$HOME/miniconda3"
  elif [ -d "$HOME/anaconda3/" ]; then
   	echo "anaconda3"
    	myconda="$HOME/anaconda3"
  elif [ -d "$custom_conda_location" ]; then
    	# echo "custom conda location"
	myconda="$custom_conda_location"
  else
	  echo "c REQUIRES CONDA"
	  exit 5
  fi
  #>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
   __conda_setup="$('$myconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
	    eval "$__conda_setup"
	else
		if [ -f "$myconda/etc/profile.d/conda.sh" ]; then
			. "$myconda/etc/profile.d/conda.sh"
		else
			export PATH="$myconda/bin:$PATH"
		fi
	fi
	unset __conda_setup
	# <<< conda initialize <<<
	conda activate "$conda_env_name"
	env $env $myconda/envs/$conda_env_name/bin/python3 $HOME/$dpdb_location/dpdb.py --config $HOME/$dpdb_location/config.json -f $filename $sem  &
  # for argumentation default input format is apx, if tgf then need to add: --input-format tgf
else
  # echo "env $solver_cmd"
  env $solver_cmd &
  # echo "env $env $solver_cmd $filename"
  # env $env $solver_cmd $filename &
fi
#alternative approach
#(export $env; $solver_cmd $filename) &
PID=$!
wait $PID
exit_code=$?
echo "Solver finished with exit code="$exit_code



exit $exit_code
