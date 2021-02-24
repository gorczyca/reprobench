# Reprobench (setup for argumentation tasks)

## Argumentation solvers currently supported:
- [mu-toksia](https://bitbucket.org/andreasniskanen/mu-toksia/src/master/) 
- [aspartix](https://www.dbai.tuwien.ac.at/proj/argumentation/systempage/)
- [dpdb](https://github.com/gorczyca/dp_on_dbs)


## Requirements
- [mu-toksia](https://bitbucket.org/andreasniskanen/mu-toksia/src/master/) 
- [clingo](https://github.com/potassco/clingo)
- [dpdb (with support for argumentation problems)](https://github.com/gorczyca/dp_on_dbs)
- [runsolver](https://github.com/daajoe/runsolver)
___


## Setup 
1. clone this repository and switch to `jkf_wip_node` branch
2. download [mu-toksia](https://bitbucket.org/andreasniskanen/mu-toksia/src/master/)  and build it. It is possible that you will lack the `zlib.h` library, install it with 
    ```
    sudo apt-get install libz-dev
    ```
    Put the compiled `mu_toksia` binary in the [experiment/argu_static/tool/bin](reprobench/experiment/argu_static/tool/bin) (named _mu_toksia_)
3. download [runsolver](https://github.com/daajoe/runsolver) and build it. It is possible that you will lack the `numa.h` library, install it with:
    ```
    sudo apt-get install libnuma-dev
    ```
    Put the compiled `runsolver` into the ~/bin/directory
4. Install [clingo](https://github.com/potassco/clingo).
5. Download and setup `config.json` in DPDB. Create necessary conda environment.
6. Edit the [experiment/argu_static/tool/bin/argu_solver.sh](reprobench/experiment/argu_static/tool/bin) file, set the variables:
    - `custom_conda_location` - path to `conda` (or `miniconda`) if not installed in the default location,
    - `conda_env_name` - name of the conda environment that serves running `DPDB`,
    - `dpdb_location` - path to `DPDB`
    - `clingo_location` - path to `clingo`
5. In order to allow the to run [./purgeDB.sh](experiment/argu_static/tool/bin/purgeDB.sh), you need to change in your local Postgres configuration (most likely file `/etc/postgresql/<VERSION>/main/pg_hba.conf`) the line:

    ```
    local   all             postgres                            peer
    ```
    to
    ```
    local   all             postgres                            trust
    ```

    if you cannot find this file, run: `locate pg_hba.conf`.

    Afterwards restart your Postgres server:

    ```
    sudo service postgresql restart
    ```
    Also, run manually:
    ```
    psql -U logicsem -c 'create or replace function pg_kill_all_sessions(db varchar, application varchar)
    returns integer as
    $$
    begin
    return (select count(*) from (select pg_catalog.pg_terminate_backend(pid) from pg_catalog.pg_stat_activity where pid <> pg_backend_pid() and datname = db and application_name = application) k);
    end;
    $$
    language plpgsql security definer volatile set search_path = pg_catalog;'
    ```
    Which should create the function (if not yet created)
5. (Optionally) add more input instances from http://argumentationcompetition.org/2019/iccma-instances.tar.gz (edit [experiment/argu_static/argu_static.yml](experiment/argu_static/argu_static.yml))
5. Run the [run_server.py](run_server.py) 
    ```
    python run_server.py
    ```
6. Run the [run_local_manager.py](run_local_manager.py)       
    ```
    python run_local_manager.py
    ```
___
## In case of problems...
- if you get the following `Workload failed: Permission denied` in the output files, try allowing the *.sh files in [experiment/argu_static/tool/bin](reprobench/argu_static/tool/bin) to be executed by:
    ```
    chmod +x <FILE>
    ``` 
- follow the information outputted by the `run_local_manager.py` and execute if applicable:         
    - change value in `/proc/sys/kernel/perf_event_paranoid` from 3 to -1 (you might be unable to change it with vi), like:
        ```
        echo -1 | sudo dd of=/proc/sys/kernel/perf_event_paranoid
        ```
        then to make this changes permanent append the line:
        ```
        kernel.perf_event_paranoid = -1
        ```
        to file `/etc/sysctl.conf`.
    - 
        ```
        chmod 666 /sys/devices/system/cpu/intel_pstate/no_turbo
        ```
    - 
        ```
        echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
        ```
    -   
        ```
        echo 2500000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
        ```


