arch=""
src=""

# arg parse begin
help() {
    echo "Usage: bootstrap.sh --arch ARCH --src SRC"
    exit 2
}
parsed=$(getopt -o a:s: --long arch:,src: -- "$@")
if [ "$?" != "0" ]; then
    help
fi

eval set -- "$parsed"
while :
do
    case "$1" in
        --arch) arch="$2" ; shift 2 ;;
        --src)  src="$2"  ; shift 2 ;;
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
# arg parse end

mono=""
if [ "$arch" = "ppc64le" ]; then
    mono="--use-mono-runtime"
fi

pushd .
cd $src
if [ "$arch" = "x64" ]; then
    # x64 needn't cross compile
    ./build.sh --prep -sb --os linux --rid linux-$arch --arch $arch
else
    # cross compile using microsoft provided toolchain
    docker run --platform linux/amd64 --rm \
    -v .:/dotnet -w /dotnet -e ROOTFS_DIR=/crossrootfs/$arch \
    mcr.microsoft.com/dotnet-buildtools/prereqs:azurelinux-3.0-net10.0-cross-$arch \
    ./build.sh --prep -sb --os linux --rid linux-$arch --arch $arch $mono
fi
popd

