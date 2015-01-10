# First, create a temporary directory for zipping files
rm .zip -rf
rm build -rf
rm lib -rf
mkdir .zip
mkdir build
mkdir download
mkdir lib

# Build an installable for the submission project
python setup.py sdist
pip install dist/AutoML2015-0.1dev.tar.gz -t .zip -t .zip -b build --no-deps

# Add dependencies
pip install git+https://github.com/mfeurer/HPOlibConfigSpace#egg=HPOlibConfigSpace0.1dev -t lib/ -b build --no-deps
pip install git+https://bitbucket.org/mfeurer/autosklearn#egg=AutoSklearn -t lib/ -b build --no-deps

# ====== Download Stuff
cd download/
if [ ! -e smac-v2.08.00-master-731.tar.gz ]
then
    wget http://www.cs.ubc.ca/labs/beta/Projects/SMAC/smac-v2.08.00-master-731.tar.gz
    mv smac-v2.08.00-master-731.tar.gz downloads/
fi

if [ ! -e cma.py ]
then
    wget https://www.lri.fr/~hansen/cma.py
fi

if [ ! -e lockfile-0.10.2.tar.gz ]
then
    wget https://pypi.python.org/packages/source/l/lockfile/lockfile-0.10.2.tar.gz#md5=1aa6175a6d57f082cd12e7ac6102ab15
fi

if [ ! -e runsolver-3.3.4.tar.bz2 ]
then
    wget http://www.cril.univ-artois.fr/~roussel/runsolver/runsolver-3.3.4.tar.bz2
fi

# ==== UNZIP STUFF
tar -xf smac-v2.08.00-master-731.tar.gz
tar -xf lockfile-0.10.2.tar.gz
tar -xf runsolver-3.3.4.tar.bz2
tar -xf jre-8u25-linux-x64.tar.gz

# ==== Compile
cd runsolver/src
make
cd ../../

# ==== MOVE Libraries
cp smac-v2.08.00-master-731 ../lib/ -r
cp cma.py ../lib/
cp jre1.8.0_25 ../lib/ -r
cp lockfile-0.10.2/lockfile ../lib/ -r
cp runsolver/src/runsolver ../lib/

cd ..

# Clean up the submission directory
find -name "*.egg-info" -exec rm -rf {} \;
find .zip -name "*.pyc" -exec rm -rf {} \;
find .zip -name "*~" -exec rm -rf {} \;

# Find out number of submission
if [ ! -e number_submission ]
then
    echo "0" > number_submission
fi
typeset -i NUMSUB=$(cat number_submission)
echo $((var+1)) > number_submission

# Zip it
rm .zip/AutoML2015/lib/ -rf
cp lib .zip/AutoML2015/ -rf
cd .zip/AutoML2015
zip -r ../../submission_${NUMSUB}.zip *
cd ../..