1.  src              ==(bootstrap.sh)==> tar.gz     (on amd64)
1a. tar.gz     + src ==(compile.sh  )==> tar.gz     (on native)
2.  tar.gz     + src ==(build.stage2)==> stage2 deb (autobuild)
3.  stage2 deb + src ==(build       )==> deb        (autobuild)
3a. deb        + src ==(build       )==> deb        (autobuild)

you should also read bootstrap.sh and compile.sh

step 1a is unnecessary when bootstrap for build aosc package
documented here just for ease of maintainence

when update aosc package, only step 3a is needed

build & build.stage2 is in aosc-os-abbs repo
tar.gz include both dotnet-sdk and Private.SourceBuilt.Artifact
upload tar.gz to https://repo.aosc.io/aosc-repacks/dotnet-10/ if necessary

remember exclude these documents from patch
