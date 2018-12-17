#! /usr/bin/env bash

cd $HOME/blender-git/blender && git pull

for i in /tmp/patches/* ; do
    echo "applying" "$i"
    patch -p1 < "$i"
done

cd $HOME/blender-git/blender && \
mkdir buildfolder && \
cd buildfolder && \
cmake \
    -C"$HOME/blender-git/blender/build_files/cmake/config/blender_full.cmake" \
    -DLIBDIR=/opt/blender/lib .. && \
make -j 4 && make install

# from: https://github.com/mattias-ohlsson/docker-centos-blender-2.8-builder

cd /
rm -f blender-*.tar.gz
cpack 
cpack -G TGZ --config $HOME/blender-git/blender/buildfolder/CPackConfig.cmake

if [ -f blender-*.tar.gz ]; then
	filename=$(ls blender-*.tar.gz)
	echo "Use docker cp to copy the package:"
	echo "  docker cp $HOSTNAME:/$filename ./"
fi

