#! /bin/sh

# setup environment variables
CWD=`pwd`
PROJECT_ROOT="$CWD/.."
LLVM_BUILD="$PROJECT_ROOT/build/llvm-install"
GOOGLE_TEST_SRC="$PROJECT_ROOT/googletest"
GOOGLE_TEST_BUILD="$PROJECT_ROOT/build/googletest"
OCLINT_METRICS_SRC="$PROJECT_ROOT/oclint-metrics"
OCLINT_METRICS_BUILD="$PROJECT_ROOT/build/oclint-metrics-test"
SUCCESS=0
EXTRA="-D CMAKE_CXX_COMPILER=$LLVM_BUILD/bin/clang++ -D CMAKE_C_COMPILER=$LLVM_BUILD/bin/clang"
GENERATOR_FLAG=
GENERATOR=

OS=$(uname -s)
if [[ "$OS" =~ MINGW32 ]]; then
    GENERATOR_FLAG="-G"
    GENERATOR="MSYS Makefiles"
    # use default compiler (g++)
    EXTRA=
fi


# clean test directory
if [ $# -eq 1 ] && [ "$1" = "clean" ]; then
    rm -rf "$OCLINT_METRICS_BUILD"
    exit 0
fi

# create directory and prepare for build
mkdir -p "$OCLINT_METRICS_BUILD"
cd "$OCLINT_METRICS_BUILD"

# configure and build
if [ $SUCCESS -eq 0 ]; then
    cmake $EXTRA -D LLVM_ROOT="$LLVM_BUILD" -D GOOGLETEST_SRC="$GOOGLE_TEST_SRC" -D GOOGLETEST_BUILD="$GOOGLE_TEST_BUILD" -D TEST_BUILD=1 "$OCLINT_METRICS_SRC" "$GENERATOR_FLAG" "$GENERATOR"
    if [ $? -ne 0 ]; then
        SUCCESS=1
    fi
fi
if [ $SUCCESS -eq 0 ]; then
    make
    if [ $? -ne 0 ]; then
        SUCCESS=2
    fi
fi
if [ $SUCCESS -eq 0 ]; then
    ctest --output-on-failure > "$OCLINT_METRICS_BUILD"/testresults.txt
    if [ $? -ne 0 ]; then
        SUCCESS=3
    fi
    cat "$OCLINT_METRICS_BUILD"/testresults.txt
fi

# back to the current folder
cd "$CWD"
exit $SUCCESS
