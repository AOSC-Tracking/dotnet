arch=""
src=""
sdk=""
artifact=""

# arg parse begin
help() {
    echo "Usage: compile.sh --arch ARCH --src SRC --sdk SDK_TAR_GZ --artifact ARTIFACT_TAR_GZ"
    exit 2
}

parsed=$(getopt -o a:s:k:t: --long arch:,src:,sdk:,artifact: -- "$@")
if [ "$?" != "0" ]; then
    help
fi

eval set -- "$parsed"
while :
do
    case "$1" in
        --arch)      arch="$2"      ; shift 2 ;;
        --src)       src="$2"       ; shift 2 ;;
        --sdk)       sdk="$2"       ; shift 2 ;;
        --artifact)  artifact="$2"  ; shift 2 ;;
        --) shift; break ;;
        *) echo "Unexpected option: $1"
        help ;;
    esac
done

if [[ -z "$arch" ]]; then
    help
fi

if [[ -z "$src" ]]; then
    help
fi

if [[ -z "$sdk" ]]; then
    help
fi

if [[ -z "$artifact" ]]; then
    help
fi
# arg parse end

mono=""
if [ "$arch" = "ppc64le" ]; then
    mono="--use-mono-runtime"
fi

temp=$(mktemp -d)
mkdir -pv $temp/sdk
mkdir -pv $temp/artifact

tar -xzvf $sdk -C $temp/sdk
tar -xzvf $artifact -C $temp/artifact

# both this and prep-source-build.sh --with-package are required
cp -v $artifact $src/prereqs/packages/archive/
pushd .
cd $src
./prep-source-build.sh --no-sdk --no-artifacts --no-bootstrap \
    --with-sdk $temp/sdk --with-packages $temp/artifact 

./build.sh -sb --os linux --rid linux-$arch --arch $arch \
    --with-sdk $temp/sdk $mono

rm -rv $temp
popd
