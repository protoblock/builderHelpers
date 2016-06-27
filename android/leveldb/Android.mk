
# Copyright (c) 2011 The LevelDB Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file. See the AUTHORS file for names of contributors.

# INSTRUCTIONS
# After you've downloaded and installed the Android NDK from:
# http://developer.android.com/sdk/ndk/index.html
# 1. In the same directory as this file, Android.mk, type:
#    $ ln -s leveldb .$(LDB_PREFIX)/jni
#    (The Android NDK will only build native projects in 
#     subdirectories named "jni".)
# 2. $ cd ..
# 3. Execute ndk-build:
#    $ $(ANDROID_NDK_DIR)/ndk-build

LDB_PREFIX=/tmp/leveldb-android/leveldb

include $(CLEAR_VARS)
LOCAL_MODULE := leveldb
LOCAL_CFLAGS := -D_REENTRANT -DOS_ANDROID -DLEVELDB_PLATFORM_POSIX -DNDEBUG  -std=c++11  #-DSNAPPY
LOCAL_CPP_FEATURES += exceptions
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(LDB_PREFIX)/include $(LDB_PREFIX)/leveldb $(LDB_PREFIX)
LOCAL_SRC_FILES := $(LDB_PREFIX)/db/builder.cc \
					$(LDB_PREFIX)/db/c.cc \
					$(LDB_PREFIX)/db/db_impl.cc \
					$(LDB_PREFIX)/db/db_iter.cc \
					$(LDB_PREFIX)/db/dbformat.cc \
					$(LDB_PREFIX)/db/dumpfile.cc \
					$(LDB_PREFIX)/db/filename.cc \
					$(LDB_PREFIX)/db/leveldb_main.cc \
					$(LDB_PREFIX)/db/log_reader.cc \
					$(LDB_PREFIX)/db/log_writer.cc \
					$(LDB_PREFIX)/db/memtable.cc \
					$(LDB_PREFIX)/db/repair.cc \
					$(LDB_PREFIX)/db/table_cache.cc \
					$(LDB_PREFIX)/db/version_edit.cc \
					$(LDB_PREFIX)/db/version_set.cc \
					$(LDB_PREFIX)/db/write_batch.cc \
					$(LDB_PREFIX)/helpers/memenv/memenv.cc \
					$(LDB_PREFIX)/port/port_posix.cc \
					$(LDB_PREFIX)/table/block.cc \
					$(LDB_PREFIX)/table/block_builder.cc \
					$(LDB_PREFIX)/table/filter_block.cc \
					$(LDB_PREFIX)/table/format.cc \
					$(LDB_PREFIX)/table/iterator.cc \
					$(LDB_PREFIX)/table/merger.cc \
					$(LDB_PREFIX)/table/table.cc \
					$(LDB_PREFIX)/table/table_builder.cc \
					$(LDB_PREFIX)/table/two_level_iterator.cc \
					$(LDB_PREFIX)/util/arena.cc \
					$(LDB_PREFIX)/util/bloom.cc \
					$(LDB_PREFIX)/util/cache.cc \
					$(LDB_PREFIX)/util/coding.cc \
					$(LDB_PREFIX)/util/comparator.cc \
					$(LDB_PREFIX)/util/crc32c.cc \
					$(LDB_PREFIX)/util/env.cc \
					$(LDB_PREFIX)/util/env_posix.cc \
					$(LDB_PREFIX)/util/filter_policy.cc \
					$(LDB_PREFIX)/util/hash.cc \
					$(LDB_PREFIX)/util/histogram.cc \
					$(LDB_PREFIX)/util/logging.cc \
					$(LDB_PREFIX)/util/options.cc \
					$(LDB_PREFIX)/util/status.cc

include $(BUILD_STATIC_LIBRARY)

LOCAL_STATIC_LIBRARIES := leveldb
