#!/bin/sh

if [ -d /home/ffmpeg_src/ffmpeg ] ; then exit 0; fi

FFMPEG_HOME=/home/ffmpeg_src
FFMPEG_PREFIX=$FFMPEG_HOME/build
FFMPEG_BIN=/usr/local/bin
TMPDIR=$FFMPEG_HOME/tmp

export PATH=$PATH:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin
export FFMPEG_HOME FFMPEG_PREFIX FFMPEG_BIN TMPDIR

# Build dependencies and libfreetype
# Font rendering library. Required for the ​drawtext video filter.
# Requires ffmpeg to be configured with --enable-libfreetype.


rm -rf $FFMPEG_HOME/*
cd $FFMPEG_HOME
mkdir /home/ffmpeg_src/tmp

pwd
echo $PATH

# Yasm is an assembler used by x264 and FFmpeg.
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzvf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix=/usr --libdir=/usr/lib64
make
make install
make distclean

# **libx264**
# H.264 video encoder
# Requires ffmpeg to be configured with --enable-gpl --enable-libx264.
cd $FFMPEG_HOME
git clone --depth 1 git://git.videolan.org/x264
cd x264
./configure --prefix="$FFMPEG_PREFIX" --bindir="$FFMPEG_BIN" --enable-static
make
make install
make distclean

# **libfdk_aac**
# AAC audio encoder
# Requires ffmpeg to be configured with --enable-libfdk_aac (and --enable-nonfree if you also included --enable-gpl).
cd $FFMPEG_HOME
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$FFMPEG_PREFIX" --disable-shared
make
make install
make distclean

# **libmp3lame**
# MP3 audio encoder.
# Requires ffmpeg to be configured with --enable-libmp3lame.
cd $FFMPEG_HOME
curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$FFMPEG_PREFIX" --bindir="$FFMPEG_BIN" --disable-shared --enable-nasm
make
make install
make distclean

# **libopus**
# Opus audio decoder and encoder.
# Requires ffmpeg to be configured with --enable-libopus.
cd $FFMPEG_HOME
git clone git://git.opus-codec.org/opus.git
cd opus
autoreconf -fiv
./configure --prefix="$FFMPEG_PREFIX" --disable-shared
make
make install
make distclean

# **libogg**
# Ogg bitstream library. Required by libtheora and libvorbis.
cd $FFMPEG_HOME
curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
tar xzvf libogg-1.3.2.tar.gz
cd libogg-1.3.2
./configure --prefix="$FFMPEG_PREFIX" --disable-shared
make
make install
make distclean

# Ogg bitstream library. Required by libtheora.
cd $FFMPEG_HOME
curl -O http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz
tar xzvf libtheora-1.1.1.tar.gz
cd libtheora-1.1.1
./configure --prefix="$FFMPEG_PREFIX" --with-ogg="$FFMPEG_PREFIX" --disable-examples --disable-shared --disable-sdltest --disable-vorbistest
make
make install
make distclean

# **libvorbis**
# Vorbis audio encoder. Requires libogg.
# Requires ffmpeg to be configured with --enable-libvorbis.
cd $FFMPEG_HOME
curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
tar xzvf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
./configure --prefix="$FFMPEG_PREFIX" --with-ogg="$FFMPEG_PREFIX" --disable-shared
make
make install
make distclean

# **ibvpx**
# VP8/VP9 video encoder.
# Requires ffmpeg to be configured with --enable-libvpx.
cd $FFMPEG_HOME
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$FFMPEG_PREFIX" --disable-examples
make
make install
make clean

# **FFmpeg**
cd $FFMPEG_HOME
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg
git checkout n.2.8.10
PKG_CONFIG_PATH="$FFMPEG_PREFIX/lib/pkgconfig" ./configure --prefix="$FFMPEG_PREFIX" --extra-cflags="-I$FFMPEG_PREFIX/include" --extra-ldflags="-L$FFMPEG_PREFIX/lib" --bindir="$FFMPEG_BIN" --enable-libfdk_aac --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libtheora --enable-libfreetype --enable-gpl --enable-nonfree
make
make install
make distclean
hash -r

