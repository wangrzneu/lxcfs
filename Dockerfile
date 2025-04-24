# Copyright Yinan Li <cndoit18@outlook.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y python3 python3-jinja2 python3-setuptools meson wget gcc cmake libfuse2 libfuse-dev uuid-runtime systemd help2man pkg-config

ENV LXCFS 5.0.2
COPY . .
RUN meson setup -Dinit-script=systemd --prefix=/usr build/ && \
    meson compile && \
    meson install -C build

FROM ubuntu:20.04

RUN apt-get update && apt-get install -y dumb-init

COPY --from=builder /usr/bin/lxcfs /usr/bin/lxcfs
COPY --from=builder /usr/lib64/lxcfs /usr/lib64/lxcfs
COPY --from=builder /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/libdl.so.2
COPY --from=builder /lib/x86_64-linux-gnu/libfuse.so.2 /lib/x86_64-linux-gnu/libfuse.so.2
COPY --from=builder /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so.1
COPY --from=builder /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libpthread.so.0
COPY --from=builder /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=builder /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

ENTRYPOINT ["dumb-init", "--"]

RUN mkdir /lxcfs

COPY ./entrypoint.sh /lxcfs/
COPY ./lxcfs-mount.sh /lxcfs/

CMD ["/lxcfs/entrypoint.sh"]
