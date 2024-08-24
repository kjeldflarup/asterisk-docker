FROM ubuntu:20.04

RUN rm -f /etc/localtime; ln -s /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \ 
        build-essential zip unzip libreadline-dev curl libncurses-dev mc aptitude \
        tcsh scons libpcre++-dev libboost-dev libboost-all-dev libreadline-dev \
        libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev \
        libboost-date-time-dev gcc g++ git make libmongo-client-dev \
        dh-autoreconf lame sox libzmq3-dev libzmqpp-dev libtiff-tools perl \
	net-tools tcpdump \
	subversion libvpb1 uuid-dev apt-utils && \
    apt clean


WORKDIR /usr/src
#RUN git clone -b 13 --depth 1 http://gerrit.asterisk.org/asterisk 
#RUN git clone -b 16.1.0 https://github.com/asterisk/asterisk.git
RUN git clone -b 13 https://github.com/asterisk/asterisk.git

WORKDIR /usr/src/asterisk
# Configure
RUN sh contrib/scripts/install_prereq install
RUN sh contrib/scripts/get_mp3_source.sh
RUN ./configure --with-jansson-bundled 1> /dev/null

# Remove the native build option
# from: https://wiki.asterisk.org/wiki/display/AST/Building+and+Installing+Asterisk
RUN make menuselect.makeopts
RUN menuselect/menuselect \
  --disable BUILD_NATIVE \
  --enable format_mp3 \
  --enable cdr_csv \
  --enable chan_sip \
  --enable res_snmp \
  --enable res_http_websocket \
  --enable res_hep_pjsip \
  --enable res_hep_rtcp \
  --enable res_sorcery_astdb \
  --enable res_sorcery_config \
  --enable res_sorcery_memory \
  --enable res_sorcery_memory_cache \
  --enable res_pjproject \
  --enable res_rtp_asterisk \
  --enable res_ari \
  --enable res_ari_applications \
  --enable res_ari_asterisk \
  --enable res_ari_bridges \
  --enable res_ari_channels \
  --enable res_ari_device_states \
  --enable res_ari_endpoints \
  --enable res_ari_events \
  --enable res_ari_mailboxes \
  --enable res_ari_model \
  --enable res_ari_playbacks \
  --enable res_ari_recordings \
  --enable res_ari_sounds \
  --enable res_pjsip \
  --enable res_pjsip_acl \
  --enable res_pjsip_authenticator_digest \
  --enable res_pjsip_caller_id \
  --enable res_pjsip_config_wizard \
  --enable res_pjsip_dialog_info_body_generator \
  --enable res_pjsip_diversion \
  --enable res_pjsip_dlg_options \
  --enable res_pjsip_dtmf_info \
  --enable res_pjsip_empty_info \
  --enable res_pjsip_endpoint_identifier_anonymous \
  --enable res_pjsip_endpoint_identifier_ip \
  --enable res_pjsip_endpoint_identifier_user \
  --enable res_pjsip_exten_state \
  --enable res_pjsip_header_funcs \
  --enable res_pjsip_logger \
  --enable res_pjsip_messaging \
  --enable res_pjsip_mwi \
  --enable res_pjsip_mwi_body_generator \
  --enable res_pjsip_nat \
  --enable res_pjsip_notify \
  --enable res_pjsip_one_touch_record_info \
  --enable res_pjsip_outbound_authenticator_digest \
  --enable res_pjsip_outbound_publish \
  --enable res_pjsip_outbound_registration \
  --enable res_pjsip_path \
  --enable res_pjsip_pidf_body_generator \
  --enable res_pjsip_publish_asterisk \
  --enable res_pjsip_pubsub \
  --enable res_pjsip_refer \
  --enable res_pjsip_registrar \
  --enable res_pjsip_registrar_expire \
  --enable res_pjsip_rfc3326 \
  --enable res_pjsip_sdp_rtp \
  --enable res_pjsip_send_to_voicemail \
  --enable res_pjsip_session \
  --enable res_pjsip_sips_contact \
  --enable res_pjsip_t38 \
  --enable res_pjsip_transport_websocket \
  --enable res_pjsip_xpidf_body_generator \
  --enable res_statsd \
  --enable res_timing_timerfd \
  --enable res_stasis \
  --enable res_stasis_answer \
  --enable res_stasis_device_state \
  --enable res_stasis_mailbox \
  --enable res_stasis_playback \
  --enable res_stasis_recording \
  --enable res_stasis_snoop \
  --enable res_stasis_test \
  menuselect.makeopts

# ./buildmenu.sh app_stasis res_stasis cdr_syslog chan_bridge_media chan_rtp chan_pjsip codec_a_mu codec_ulaw pbx_config

# Continue with a standard make.
RUN make 1> /dev/null && \
    make install 1> /dev/null && \
    make samples 1> /dev/null && \
    rm -rf /usr/src/asterisk
WORKDIR /

## g729

RUN mkdir /usr/codecs && \
    cd /usr/codecs && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-athlon-sse.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-atom.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-barcelona.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-core2-sse4.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-core2.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-debug.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-geode.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-opteron-sse3.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-opteron.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-pentium-m.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-pentium.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-pentium2.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-pentium3-no-sse.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-pentium3.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-pentium4-no-sse.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-pentium4-sse3.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-pentium4.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-x86_64-barcelona.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-x86_64-core2-sse4.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-x86_64-core2.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-x86_64-opteron-sse3.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-x86_64-opteron.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc-x86_64-pentium4.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc2.2-x86_64-barcelona.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc2.2-x86_64-core2-sse4.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc2.2-x86_64-core2.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc2.2-x86_64-opteron-sse3.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc2.2-x86_64-opteron.so && \
    curl -O http://asterisk.hosting.lv/bin/codec_g729-ast150-gcc4-glibc2.2-x86_64-pentium4.so


# Update max number of open files.
RUN sed -i -e 's/# MAXFILES=/MAXFILES=/' /usr/sbin/safe_asterisk
# User has to mount a usable /etc/asterisk via docker-compose
# Keep the original in /etc/asterisk.orig for reference
RUN mv /etc/asterisk /etc/asterisk.orig

# And run asterisk in the foreground.
CMD asterisk -f

