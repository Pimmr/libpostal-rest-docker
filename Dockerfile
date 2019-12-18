FROM ubuntu:16.04 as build

ARG COMMIT
ENV COMMIT ${COMMIT:-master}
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    autoconf automake build-essential curl git libsnappy-dev libtool pkg-config

RUN git clone https://github.com/openvenues/libpostal -b $COMMIT

COPY ./*.sh /libpostal/

WORKDIR /libpostal
RUN ./build_libpostal.sh
RUN ./build_libpostal_rest.sh

FROM ubuntu:16.04

WORKDIR /libpostal

EXPOSE 8080

COPY --from=build /libpostal/workspace/bin/libpostal-rest .
COPY --from=build /usr/local/lib/libpostal.so.1 /usr/lib/
COPY --from=build /opt/libpostal_data/libpostal/transliteration/transliteration.dat /opt/libpostal_data/libpostal/transliteration/
COPY --from=build /opt/libpostal_data/libpostal/numex/numex.dat /opt/libpostal_data/libpostal/numex/
COPY --from=build /opt/libpostal_data/libpostal/address_expansions/address_dictionary.dat /opt/libpostal_data/libpostal/address_expansions/
COPY --from=build /opt/libpostal_data/libpostal/address_parser/address_parser_crf.dat /opt/libpostal_data/libpostal/address_parser/
COPY --from=build /opt/libpostal_data/libpostal/language_classifier/language_classifier.dat /opt/libpostal_data/libpostal/language_classifier/
COPY --from=build /opt/libpostal_data/libpostal/address_parser/address_parser_vocab.trie /opt/libpostal_data/libpostal/address_parser/
COPY --from=build /opt/libpostal_data/libpostal/address_parser/address_parser_phrases.dat /opt/libpostal_data/libpostal/address_parser/
COPY --from=build /opt/libpostal_data/libpostal/address_parser/address_parser_postal_codes.dat /opt/libpostal_data/libpostal/address_parser/

CMD /libpostal/libpostal-rest
