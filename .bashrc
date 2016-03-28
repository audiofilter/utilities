PATH=.:${HOME}/anaconda/bin:${HOME}/bin:${HOME}/utilities:${PATH}:/usr/local/bin:/usr/local/octave/3.8.2/bin:/Developer/NVIDIA/CUDA-7.0/bin:/Applications/MATLAB_R2014b.app/bin


function frameworkpython {
    if [[ ! -z "$VIRTUAL_ENV" ]]; then
        PYTHONHOME=$VIRTUAL_ENV /Users/tgkirk/anaconda/bin/python "$@"
    else
        /Users/tgkirk/anaconda/bin/python "$@"
    fi
}


source ~/.bash_alias
