#!/bin/bash
ln -snf ../../parm/jedivar.yaml .
ln -snf ../../parm/getkf.yaml .
ln -snf ../../parm/bec_bump.yaml .
ln -snf ../yaml_finalize .
ln -snf ../yamltools4rrfs.py .
ln -snf ../hifiyaml4rrfs.py .

export analysisDate=2024050600
export beginDate=2024050600
export HYB_WGT_STATIC=0.5
export HYB_WGT_ENS=0.5
export start_type=cold  # cold, warm
export GETKF_TYPE=observer # observer, solver, post
export USE_CONV_SAT_INFO=false   # false, true
export STATIC_BEC_MODEL=GSIBEC  # GSIBEC, BUMPBEC


rm -rf tmp/
mkdir -p tmp/

#----------------------------------------------------------
#  jedivar.yaml
#  compare the generate yamls with the original jedivar.yaml
#----------------------------------------------------------
# change static BEC to BUMPBEC
export STATIC_BEC_MODEL=BUMPBEC
yaml_finalize jedivar.yaml stdout > tmp/bumpbec.yaml

# change back to use the default GSIBEC 
export STATIC_BEC_MODEL=GSIBEC

# change to pure 3DVAR
export HYB_WGT_STATIC=1.0
export HYB_WGT_ENS=0.0
yaml_finalize jedivar.yaml stdout > tmp/3dvar.yaml

# change to pure 3DENVAR
export HYB_WGT_STATIC=0.0
export HYB_WGT_ENS=1.0
yaml_finalize jedivar.yaml stdout > tmp/3denvar.yaml

# change back to default hybrid setting
export HYB_WGT_STATIC=0.5
export HYB_WGT_ENS=0.5

#----------------------------------------------------------
#  getkf.yaml
#  compare the generate yamls with the original getkf.yaml
#----------------------------------------------------------
# test getkf solver
export GETKF_TYPE=solver
yaml_finalize getkf.yaml stdout > tmp/getkf_solver.yaml

# test getkf post
export GETKF_TYPE=post
yaml_finalize getkf.yaml stdout > tmp/getkf_post.yaml

# test getkf observer
export GETKF_TYPE=observer
yaml_finalize getkf.yaml stdout > tmp/getkf_observer.yaml

#----------------------------------------------------------
#  use convinfo and satinfo to manage observers 
#----------------------------------------------------------
export USE_CONV_SAT_INFO=true
yaml_finalize jedivar.yaml stdout > tmp/jedivar_final.yaml
yaml_finalize getkf.yaml stdout > tmp/getkf_final.yaml


#----------------------------------------------------------
#  compare tmp/ to ref/
#----------------------------------------------------------
# diff tmp ref
diff -r tmp ref 1>/dev/null 2>/dev/null
if (( $? == 0 )); then
  echo "test passed, identical results."
else
  echo "test failed, different results from 'diff -r tmp ref'!"
fi
