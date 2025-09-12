\ libcurl.fth - interface to libcurl

((
Copyright (c) 2012
MicroProcessor Engineering
133 Hill Lane
Southampton SO15 5AF
England

tel:   +44 (0)23 8063 1441
email: mpe@mpeforth.com
       tech-support@mpeforth.com
web:   http://www.mpeforth.com
Skype: mpe_sfp

From North America, our telephone and fax numbers are:
       011 44 23 8063 1441
       901 313 4312 (North American access number to UK office)


To do
=====

Change history
==============
20120510 MPE001 First cut.
))

((
/***************************************************************************
 *                                  _   _ ____  _
 *  Project                     ___| | | |  _ \| |
 *                             / __| | | | |_) | |
 *                            | (__| |_| |  _ <| |___
 *                             \___|\___/|_| \_\_____|
 *
 * Copyright (C) 1998 - 2012, Daniel Stenberg, <daniel@haxx.se>, et al.
 *
 * This software is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at http://curl.haxx.se/docs/copyright.html.
 *
 * You may opt to use, copy, modify, merge, publish, distribute and/or sell
 * copies of the Software, and permit persons to whom the Software is
 * furnished to do so, under the terms of the COPYING file.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 ***************************************************************************/
))

decimal

\ ===========
\ *> sharedlibs
\ *S LibCurl
\ ===========
\ *P The *\i{libcurl} library/DLL provides high-level functions
\ ** for transferring data across networks to and from servers.
\ * If you have libcurl problems, all docs and details are to
\ ** be found at:
\ *C   http://curl.haxx.se/libcurl/
\ *P Additional help may be found at the curl-library mailing
\ ** list subscription and unsubscription web interface:
\ *C   http://cool.haxx.se/mailman/listinfo/curl-library/

[defined] Target_386_Windows [if]
library: libcurl.dll
[then]

[defined] Target_386_OSX [if]
library: libcurl.2.dylib
[then]

[defined] Target_386_Linux [if]
library: libcurl.so.3
\ library: libcurl.so.4
[then]

also types definitions
: curl_socket_t  int  ;
: CURLSH  void  ;
[undefined] time_t [if]
: time_t  uint32  ;
[then]
previous definitions

-1 constant CURL_SOCKET_BAD

struct /curl_httppost	\ -- len
\ *G The Forth version of the curl_httppost structure.
  int chp.*next			\ next entry in the list
  int chp.*name			\ pointer to allocated name
  int chp.namelength		\ length of name length
  int chp.*contents		\ pointer to allocated data contents
  int chp.contentslength	\ length of contents field
  int chp.*buffer		\ pointer to allocated buffer contents
  int chp.bufferlength		\ length of buffer field
  int chp.*contenttype		\ Content-Type
  int chp.*contentheader	\ list of extra headers for this form
  int chp.*more			\ if one field name has more than one
                                \ file, this link should link to following
                                \ files
  int chp.flags			\ as defined below
  int chp.*showfilename		\ The file name to show. If not set, the
                                \ actual file name will be used (if this
                                \ is a file part)
  int chp.*userp		\ custom pointer used for
                                \ HTTPPOST_CALLBACK posts
end-struct

\ HTTPPOST flags
1 constant HTTPPOST_FILENAME	\ specified content is a file name
2 constant HTTPPOST_READFILE	\ specified content is a file name
4 constant HTTPPOST_PTRNAME	\ name is only stored pointer
                                \ do not free in formfree
8 constant HTTPPOST_PTRCONTENTS	\ contents is only stored pointer
                                \   do not free in formfree
16 constant HTTPPOST_BUFFER	\ upload file from buffer
32 constant HTTPPOST_PTRBUFFER	\ upload file from pointer contents
64 constant HTTPPOST_CALLBACK	\ upload file contents by using the
                                \ regular read callback to get the data
                                \ and pass the given pointer as custom
                                \ pointer

#16 kb constant CURL_MAX_WRITE_SIZE
#100 kb constant CURL_MAX_HTTP_HEADER

0x10000001 constant CURL_WRITEFUNC_PAUSE
\ *G This is a magic return code for the write callback that, when
\ ** returned, will signal libcurl to pause receiving on the
\ ** current transfer.

\ *P Note that all Curl callbacks must be defined with *\fo{FromC}.

((
typedef size_t (*curl_write_callback)(
  char *buffer, size_t size, size_t nitems, void *outstream
);
))

\ enumeration of file types
0 constant CURLFILETYPE_FILE
1 constant CURLFILETYPE_DIRECTORY
2 constant CURLFILETYPE_SYMLINK
3 constant CURLFILETYPE_DEVICE_BLOCK
4 constant CURLFILETYPE_DEVICE_CHAR
5 constant CURLFILETYPE_NAMEDPIPE
6 constant CURLFILETYPE_SOCKET
7 constant CURLFILETYPE_DOOR	\ is possible only on Sun Solaris now
8 constant CURLFILETYPE_UNKNOWN	\ should never occur

1 0 lshift constant CURLFINFOFLAG_KNOWN_FILENAME
1 1 lshift constant CURLFINFOFLAG_KNOWN_FILETYPE
1 2 lshift constant CURLFINFOFLAG_KNOWN_TIME
1 3 lshift constant CURLFINFOFLAG_KNOWN_PERM
1 4 lshift constant CURLFINFOFLAG_KNOWN_UID
1 5 lshift constant CURLFINFOFLAG_KNOWN_GID
1 6 lshift constant CURLFINFOFLAG_KNOWN_SIZE
1 7 lshift constant CURLFINFOFLAG_KNOWN_HLINKCOUNT

struct /curl_fileinfo	\ -- len
\ *G Content of this structure depends on information which is
\ ** known and is achievable (e.g. by FTP LIST parsing). Please
\ ** see the url_easy_setopt(3) man page for callbacks returning
\ ** this structure -- some fields are mandatory, some others are
\ ** optional. The FLAG field has special meaning.
  int cfi.*filename
  int cfi.filetype
  int cfi.time
  int cfi.perm
  int cfi.uid
  int cfi.gid
  cell field cfi.size		\ curl_off_t size;
  int cfi.hardlinks		\ long int hardlinks;

  int cfi.*time
  int cfi.*perm
  int cfi.*user
  int cfi.*group
  int cfi.*target	\ pointer to the target filename of a symlink

  int cfi.flags

  \ used internally
  int cfi.*b_data
  int cfi.b_size
  int cfi.b_used
end-struct

((
struct curl_fileinfo {
  char *filename;
  curlfiletype filetype;
  time_t time;
  unsigned int perm;
  int uid;
  int gid;
  curl_off_t size;
  long int hardlinks;

  struct {
    /* If some of these fields is not NULL, it is a pointer to b_data. */
    char *time;
    char *perm;
    char *user;
    char *group;
    char *target; /* pointer to the target filename of a symlink */
  } strings;

  unsigned int flags;

  /* used internally */
  char * b_data;
  size_t b_size;
  size_t b_used;
};
))

\ return codes for CURLOPT_CHUNK_BGN_FUNCTION
0 constant CURL_CHUNK_BGN_FUNC_OK
1 constant CURL_CHUNK_BGN_FUNC_FAIL	\ tell the lib to end the task
2 constant CURL_CHUNK_BGN_FUNC_SKIP	\ skip this chunk over

((
/* if splitting of data transfer is enabled, this callback is called before
   download of an individual chunk started. Note that parameter "remains" works
   only for FTP wildcard downloading (for now), otherwise is not used */
typedef long (*curl_chunk_bgn_callback)(
  const void *transfer_info, void *ptr, int remains
);
))

\ return codes for CURLOPT_CHUNK_END_FUNCTION
0 constant CURL_CHUNK_END_FUNC_OK
1 constant CURL_CHUNK_END_FUNC_FAIL     \ tell the lib to end the task

((
/* If splitting of data transfer is enabled this callback is called after
   download of an individual chunk finished.
   Note! After this callback was set then it have to be called FOR ALL chunks.
   Even if downloading of this chunk was skipped in CHUNK_BGN_FUNC.
   This is the reason why we don't need "transfer_info" parameter in this
   callback and we are not interested in "remains" parameter too. */
typedef long (*curl_chunk_end_callback)(void *ptr);
))

\ return codes for FNMATCHFUNCTION
0 constant CURL_FNMATCHFUNC_MATCH    \ string corresponds to the pattern
1 constant CURL_FNMATCHFUNC_NOMATCH  \ pattern doesn't match the string
2 constant CURL_FNMATCHFUNC_FAIL     \ an error occurred

((
/* callback type for wildcard downloading pattern matching. If the
   string matches the pattern, return CURL_FNMATCHFUNC_MATCH value, etc. */
typedef int (*curl_fnmatch_callback)(
  void *ptr, const char *pattern, const char *string
);
))

\ These are the return codes for the seek callbacks
0 constant CURL_SEEKFUNC_OK
1 constant CURL_SEEKFUNC_FAIL		\ fail the entire transfer
2 constant CURL_SEEKFUNC_CANTSEEK	\ tell libcurl seeking can't be done, so
                                        \ libcurl might try other means instead
((
typedef int (*curl_seek_callback)(
  void *instream, curl_off_t offset, int origin
);
))

\ This is a return code for the read callback that, when returned,
\ will signal libcurl to immediately abort the current transfer.
0x10000000 constant CURL_READFUNC_ABORT
\ This is a return code for the read callback that, when returned,
\ will signal libcurl to pause sending data on the current transfer.
0x10000001 constant CURL_READFUNC_PAUSE

((
typedef size_t (*curl_read_callback)(
  char *buffer, size_t size, size_t nitems, void * instream
);
))

0 constant CURLSOCKTYPE_IPCXN	\ socket created for a specific IP connection
1 constant CURLSOCKTYPE_LAST	\ never use

\ The return code from the sockopt_callback can signal information
\ back to libcurl:
0 constant CURL_SOCKOPT_OK
1 constant CURL_SOCKOPT_ERROR	\ causes libcurl to abort and return
                                \ CURLE_ABORTED_BY_CALLBACK
2 constant CURL_SOCKOPT_ALREADY_CONNECTED

((
typedef int (*curl_sockopt_callback)(
  void *clientp, curl_socket_t curlfd, curlsocktype purpose
);
))

struct /curl_sockaddr	\ -- len
  int csa.family
  int csa.socktype
  int csa.protocol
  int csa.addrlen	\ addrlen was a socklen_t type before 7.18.0 but it
                        \ turned really ugly and painful on the systems that
                        \ lack this type
  16 field csa.addr
end-struct

((
typedef curl_socket_t (*curl_opensocket_callback)(
  void *clientp, curlsocktype purpose, struct curl_sockaddr *address
);

typedef int (*curl_closesocket_callback)(
  void *clientp, curl_socket_t item
);
))

0 constant CURLIOE_OK            \ I/O operation successful
1 constant CURLIOE_UNKNOWNCMD    \ command was unknown to callback
2 constant CURLIOE_FAILRESTART   \ failed to restart the read
3 constant CURLIOE_LAST          \ never use

0 constant CURLIOCMD_NOP         \ no operation
1 constant CURLIOCMD_RESTARTREAD \ restart the read stream from start
2 constant CURLIOCMD_LAST        // never use

((
typedef curlioerr (*curl_ioctl_callback)(
  CURL *handle, int cmd, void *clientp
);
))

\ The following typedef's are signatures of malloc, free, realloc, strdup and
\ calloc respectively.  Function pointers of these types can be passed to the
\ curl_global_init_mem() function to set user defined memory management
\ callback routines.
((
typedef void *(*curl_malloc_callback)(size_t size);
typedef void (*curl_free_callback)(void *ptr);
typedef void *(*curl_realloc_callback)(void *ptr, size_t size);
typedef char *(*curl_strdup_callback)(const char *str);
typedef void *(*curl_calloc_callback)(size_t nmemb, size_t size);
))

\ the kind of data that is passed to information_callback
0 constant CURLINFO_TEXT
1 constant CURLINFO_HEADER_IN
2 constant CURLINFO_HEADER_OUT
3 constant CURLINFO_DATA_IN
4 constant CURLINFO_DATA_OUT
5 constant CURLINFO_SSL_DATA_IN
6 constant CURLINFO_SSL_DATA_OUT
7 constant CURLINFO_END

((
typedef int (*curl_debug_callback)
       (CURL *handle,      /* the handle/transfer this concerns */
        curl_infotype type, /* what kind of data */
        char *data,        /* points to the data */
        size_t size,       /* size of the data pointed to */
        void *userptr);    /* whatever the user please */
))

((
All possible error codes from all sorts of curl functions. Future versions
may return other values, stay prepared.

Always add new return codes last. Never *EVER* remove any. The return
codes must remain the same!
))

0 constant CURLE_OK
1 constant CURLE_UNSUPPORTED_PROTOCOL     \ 1
2 constant CURLE_FAILED_INIT              \ 2
3 constant CURLE_URL_MALFORMAT            \ 3
4 constant CURLE_NOT_BUILT_IN             \ 4 - [was obsoleted in August 2007 for
                                          \ 7.17.0, reused in April 2011 for 7.21.5]
5 constant CURLE_COULDNT_RESOLVE_PROXY    \ 5
6 constant CURLE_COULDNT_RESOLVE_HOST     \ 6
7 constant CURLE_COULDNT_CONNECT          \ 7
8 constant CURLE_FTP_WEIRD_SERVER_REPLY   \ 8
9 constant CURLE_REMOTE_ACCESS_DENIED     \ 9 a service was denied by the server
                                          \   due to lack of access - when login fails
                                          \   this is not returned.
10 constant CURLE_FTP_ACCEPT_FAILED       \ 10 - [was obsoleted in April 2006 for
                                          \    7.15.4, reused in Dec 2011 for 7.24.0]
11 constant CURLE_FTP_WEIRD_PASS_REPLY    \ 11
12 constant CURLE_FTP_ACCEPT_TIMEOUT      \ 12 - timeout occurred accepting server
                                          \    [was obsoleted in August 2007 for 7.17.0,
                                          \    reused in Dec 2011 for 7.24.0]
13 constant CURLE_FTP_WEIRD_PASV_REPLY     \ 13
14 constant CURLE_FTP_WEIRD_227_FORMAT     \ 14
15 constant CURLE_FTP_CANT_GET_HOST        \ 15
\ 16 constant CURLE_OBSOLETE16               \ 16 - NOT USED
17 constant CURLE_FTP_COULDNT_SET_TYPE     \ 17
18 constant CURLE_PARTIAL_FILE             \ 18
19 constant CURLE_FTP_COULDNT_RETR_FILE    \ 19
\ 20 constant CURLE_OBSOLETE20               \ 20 - NOT USED
21 constant CURLE_QUOTE_ERROR              \ 21 - quote command failure
22 constant CURLE_HTTP_RETURNED_ERROR      \ 22
23 constant CURLE_WRITE_ERROR              \ 23
\ 24 constant CURLE_OBSOLETE24               \ 24 - NOT USED
25 constant CURLE_UPLOAD_FAILED            \ 25 - failed upload "command"
26 constant CURLE_READ_ERROR               \ 26 - couldn't open/read from file
27 constant CURLE_OUT_OF_MEMORY            \ 27
\ Note: CURLE_OUT_OF_MEMORY may sometimes indicate a conversion error
\ instead of a memory allocation error if CURL_DOES_CONVERSIONS
\ is defined
28 constant CURLE_OPERATION_TIMEDOUT       \ 28 - the timeout time was reached
29 constant CURLE_OBSOLETE29               \ 29 - NOT USED
30 constant CURLE_FTP_PORT_FAILED          \ 30 - FTP PORT operation failed
31 constant CURLE_FTP_COULDNT_USE_REST     \ 31 - the REST command failed
32 constant CURLE_OBSOLETE32               \ 32 - NOT USED
33 constant CURLE_RANGE_ERROR              \ 33 - RANGE "command" didn't work
34 constant CURLE_HTTP_POST_ERROR          \ 34
35 constant CURLE_SSL_CONNECT_ERROR        \ 35 - wrong when connecting with SSL
36 constant CURLE_BAD_DOWNLOAD_RESUME      \ 36 - couldn't resume download
37 constant CURLE_FILE_COULDNT_READ_FILE   \ 37
38 constant CURLE_LDAP_CANNOT_BIND         \ 38
39 constant CURLE_LDAP_SEARCH_FAILED       \ 39
40 constant CURLE_OBSOLETE40               \ 40 - NOT USED
41 constant CURLE_FUNCTION_NOT_FOUND       \ 41
42 constant CURLE_ABORTED_BY_CALLBACK      \ 42
43 constant CURLE_BAD_FUNCTION_ARGUMENT    \ 43
\  CURLE_OBSOLETE44               \ 44 - NOT USED
45 constant CURLE_INTERFACE_FAILED         \ 45 - CURLOPT_INTERFACE failed
\  CURLE_OBSOLETE46               \ 46 - NOT USED
47 constant CURLE_TOO_MANY_REDIRECTS       \ 47 - catch endless re-direct loops
48 constant CURLE_UNKNOWN_OPTION           \ 48 - User specified an unknown option
49 constant CURLE_TELNET_OPTION_SYNTAX     \ 49 - Malformed telnet option
\  CURLE_OBSOLETE50               \ 50 - NOT USED
51 constant CURLE_PEER_FAILED_VERIFICATION  \ 51 - peer's certificate or fingerprint
                                            \   wasn't verified fine
52 constant CURLE_GOT_NOTHING              \ 52 - when this is a specific error
53 constant CURLE_SSL_ENGINE_NOTFOUND      \ 53 - SSL crypto engine not found
54 constant CURLE_SSL_ENGINE_SETFAILED     \ 54 - can not set SSL crypto engine as
                                           \   default
55 constant CURLE_SEND_ERROR               \ 55 - failed sending network data
56 constant CURLE_RECV_ERROR               \ 56 - failure in receiving network data
\ 57 constant CURLE_OBSOLETE57               \ 57 - NOT IN USE
58 constant CURLE_SSL_CERTPROBLEM          \ 58 - problem with the local certificate
59 constant CURLE_SSL_CIPHER               \ 59 - couldn't use specified cipher
60 constant CURLE_SSL_CACERT               \ 60 - problem with the CA cert (path?)
61 constant CURLE_BAD_CONTENT_ENCODING     \ 61 - Unrecognized/bad encoding
62 constant CURLE_LDAP_INVALID_URL         \ 62 - Invalid LDAP URL
63 constant CURLE_FILESIZE_EXCEEDED        \ 63 - Maximum file size exceeded
64 constant CURLE_USE_SSL_FAILED           \ 64 - Requested FTP SSL level failed
65 constant CURLE_SEND_FAIL_REWIND         \ 65 - Sending the data requires a rewind
                                           \   that failed
66 constant CURLE_SSL_ENGINE_INITFAILED    \ 66 - failed to initialise ENGINE
67 constant CURLE_LOGIN_DENIED             \ 67 - user, password or similar was not
                                           \   accepted and we failed to login
68 constant CURLE_TFTP_NOTFOUND            \ 68 - file not found on server
69 constant CURLE_TFTP_PERM                \ 69 - permission problem on server
70 constant CURLE_REMOTE_DISK_FULL         \ 70 - out of disk space on server
71 constant CURLE_TFTP_ILLEGAL             \ 71 - Illegal TFTP operation
72 constant CURLE_TFTP_UNKNOWNID           \ 72 - Unknown transfer ID
73 constant CURLE_REMOTE_FILE_EXISTS       \ 73 - File already exists
74 constant CURLE_TFTP_NOSUCHUSER          \ 74 - No such user
75 constant CURLE_CONV_FAILED              \ 75 - conversion failed
76 constant CURLE_CONV_REQD                \ 76 - caller must register conversion
                                           \       callbacks using curl_easy_setopt options
                                           \       CURLOPT_CONV_FROM_NETWORK_FUNCTION,
                                           \       CURLOPT_CONV_TO_NETWORK_FUNCTION, and
                                           \       CURLOPT_CONV_FROM_UTF8_FUNCTION
77 constant CURLE_SSL_CACERT_BADFILE,      \ 77 - could not load CACERT file, missing
                                           \      or wrong format
78 constant CURLE_REMOTE_FILE_NOT_FOUND    \ 78 - remote file not found
79 constant CURLE_SSH                      \ 79 - error from the SSH layer, somewhat
                                           \      generic so the error message will be of
                                           \      interest when this has happened
80 constant CURLE_SSL_SHUTDOWN_FAILED      \ 80 - Failed to shut down the SSL
                                           \      connection
81 constant CURLE_AGAIN                    \ 81 - socket is not ready for send/recv,
                                           \      wait till it's ready and try again (Added
                                           \      in 7.18.2)
82 constant CURLE_SSL_CRL_BADFILE          \ 82 - could not load CRL file, missing or
                                           \      wrong format (Added in 7.19.0)
83 constant CURLE_SSL_ISSUER_ERROR         \ 83 - Issuer check failed.  (Added in
                                           \      7.19.0)
84 constant CURLE_FTP_PRET_FAILED          \ 84 - a PRET command failed
85 constant CURLE_RTSP_CSEQ_ERROR          \ 85 - mismatch of RTSP CSeq numbers
86 constant CURLE_RTSP_SESSION_ERROR       \ 86 - mismatch of RTSP Session Ids
87 constant CURLE_FTP_BAD_FILE_LIST        \ 87 - unable to parse FTP file list
88 constant CURLE_CHUNK_FAILED             \ 88 - chunk callback reported error
89 constant CURL_LAST                      \ never use!

((
/* This prototype applies to all conversion callbacks */
typedef CURLcode (*curl_conv_callback)(char *buffer, size_t length);

typedef CURLcode (*curl_ssl_ctx_callback)(CURL *curl,    /* easy handle */
                                          void *ssl_ctx, /* actually an
                                                            OpenSSL SSL_CTX */
                                          void *userptr);
))

0 constant CURLPROXY_HTTP	\ added in 7.10, new in 7.19.4 default is to use
                                \ CONNECT HTTP/1.1
1 constant CURLPROXY_HTTP_1_0	\ added in 7.19.4, force to use CONNECT
                                \ HTTP/1.0
4 constant CURLPROXY_SOCKS4	\ support added in 7.15.2, enum existed already
                                \ in 7.10
5 constant CURLPROXY_SOCKS5	\ added in 7.10
6 constant CURLPROXY_SOCKS4A	\ added in 7.18.0
7 constant CURLPROXY_SOCKS5_HOSTNAME
\ Use the SOCKS5 protocol but pass along the host name rather
\ than the IP address. added in 7.18.0

0 constant CURLAUTH_NONE		\ nothing
1 0 lshift constant CURLAUTH_BASIC	\ Basic (default)
1 1 lshift constant CURLAUTH_DIGEST	\ Digest
1 2 lshift constant CURLAUTH_GSSNEGOTIATE \ GSS-Negotiate
1 3 lshift constant CURLAUTH_NTLM	\ NTLM
1 4 lshift constant CURLAUTH_DIGEST_IE	\ Digest with IE flavour
1 5 lshift constant CURLAUTH_NTLM_WB	\ NTLM delegating to winbind helper
1 31 lshift constant CURLAUTH_ONLY	\ used together with a single other
                                        \ type to force no auth or just that
                                        \ single type
CURLAUTH_DIGEST_IE invert constant CURLAUTH_ANY	\ all fine types set
CURLAUTH_BASIC CURLAUTH_DIGEST_IE or invert constant CURLAUTH_ANYSAFE

-1 constant CURLSSH_AUTH_ANY      \ all types supported by the server
0 constant CURLSSH_AUTH_NONE      \ none allowed, silly but complete
1 constant CURLSSH_AUTH_PUBLICKEY \ public/private key files
2 constant CURLSSH_AUTH_PASSWORD  \ password
4 constant CURLSSH_AUTH_HOST      \ host key files
8 constant CURLSSH_AUTH_KEYBOARD  \ keyboard interactive
CURLSSH_AUTH_ANY constant CURLSSH_AUTH_DEFAULT

0 constant CURLGSSAPI_DELEGATION_NONE		\ no delegation (default)
1 constant CURLGSSAPI_DELEGATION_POLICY_FLAG	\ if permitted by policy
2 constant CURLGSSAPI_DELEGATION_FLAG		\ delegate always

256 constant CURL_ERROR_SIZE

struct /curl_khkey	\ -- len
  int ckh.*key	\ points to a zero-terminated string encoded with base64
                \ if len is zero, otherwise to the "raw" data
  int ckn.len
  int ckh.keytype
end-struct

0 constant CURLKHTYPE_UNKNOWN
1 constant CURLKHTYPE_RSA1
2 constant CURLKHTYPE_RSA
3 constant CURLKHTYPE_DSS

\ this is the set of return values expected from the
\ curl_sshkeycallback callback
0 constant CURLKHSTAT_FINE_ADD_TO_FILE
1 constant CURLKHSTAT_FINE
2 constant CURLKHSTAT_REJECT	\ reject the connection, return an error
3 constant CURLKHSTAT_DEFER	\ do not accept it, but we can't answer right now so
                                \ this causes a CURLE_DEFER error but otherwise the
                                \ connection will be left intact etc
4 constant CURLKHSTAT_LAST	\ not for use, only a marker for last-in-list

\ this is the set of status codes pass in to the callback
0 constant CURLKHMATCH_OK		\ match
1 constant CURLKHMATCH_MISMATCH		\ host found, key mismatch!
2 constant CURLKHMATCH_MISSING		\ no matching host/key found
3 constant CURLKHMATCH_LAST		\ not for use, only a marker for last-in-list

((
typedef int (*curl_sshkeycallback) (
  CURL *easy,     			/* easy handle */
  const struct curl_khkey *knownkey,	/* known */
  const struct curl_khkey *foundkey,	/* found */
  enum curl_khmatch,			/* libcurl's view on the keys */
  void *clientp				/* custom pointer passed from app */
);
))

\ parameter for the CURLOPT_USE_SSL option
0 constant CURLUSESSL_NONE	\ do not attempt to use SSL
1 constant CURLUSESSL_TRY	\ try using SSL, proceed anyway otherwise
2 constant CURLUSESSL_CONTROL	\ SSL for the control connection or fail
3 constant CURLUSESSL_ALL	\ SSL for all communication or fail
4 constant CURLUSESSL_LAST	\ not an option, never use

\ Definition of bits for the CURLOPT_SSL_OPTIONS argument:

\ - ALLOW_BEAST tells libcurl to allow the BEAST SSL vulnerability in the
\   name of improving interoperability with older servers. Some SSL libraries
\   have introduced work-arounds for this flaw but those work-arounds sometimes
\   make the SSL communication fail. To regain functionality with those broken
\   servers, a user can this way allow the vulnerability back.
1 constant CURLSSLOPT_ALLOW_BEAST

\ parameter for the CURLOPT_FTP_SSL_CCC option
0 constant CURLFTPSSL_CCC_NONE     \ do not send CCC
1 constant CURLFTPSSL_CCC_PASSIVE  \ Let the server initiate the shutdown
2 constant CURLFTPSSL_CCC_ACTIVE   \ Initiate the shutdown
3 constant CURLFTPSSL_CCC_LAST     \ not an option, never use

\ parameter for the CURLOPT_FTPSSLAUTH option
0 constant CURLFTPAUTH_DEFAULT	\ let libcurl decide
1 constant CURLFTPAUTH_SSL      \ use "AUTH SSL"
2 constant CURLFTPAUTH_TLS      \ use "AUTH TLS"
3 constant CURLFTPAUTH_LAST     \ not an option, never use

\ parameter for the CURLOPT_FTP_CREATE_MISSING_DIRS option
0 constant CURLFTP_CREATE_DIR_NONE   \ do NOT create missing dirs!
1 constant CURLFTP_CREATE_DIR        \ (FTP/SFTP) if CWD fails, try MKD and then CWD
                                     \ again if MKD succeeded, for SFTP this does
                                     \ similar magic
2 constant CURLFTP_CREATE_DIR_RETRY  \ (FTP only) if CWD fails, try MKD and then CWD
                                     \ again even if MKD failed!
3 constant CURLFTP_CREATE_DIR_LAST   \ not an option, never use

\ parameter for the CURLOPT_FTP_FILEMETHOD option
0 constant CURLFTPMETHOD_DEFAULT    \ let libcurl pick
1 constant CURLFTPMETHOD_MULTICWD   \ single CWD operation for each path part
2 constant CURLFTPMETHOD_NOCWD      \ no CWD at all
3 constant CURLFTPMETHOD_SINGLECWD  \ one CWD to full dir, then work on file
4 constant CURLFTPMETHOD_LAST       \ not an option, never use

\ CURLPROTO_ defines are for the CURLOPT_*PROTOCOLS options
1 0 lshift constant CURLPROTO_HTTP
1 1 lshift constant CURLPROTO_HTTPS
1 2 lshift constant CURLPROTO_FTP
1 3 lshift constant CURLPROTO_FTPS
1 4 lshift constant CURLPROTO_SCP
1 5 lshift constant CURLPROTO_SFTP
1 6 lshift constant CURLPROTO_TELNET
1 7 lshift constant CURLPROTO_LDAP
1 8 lshift constant CURLPROTO_LDAPS
1 9 lshift constant CURLPROTO_DICT
1 10 lshift constant CURLPROTO_FILE
1 11 lshift constant CURLPROTO_TFTP
1 12 lshift constant CURLPROTO_IMAP
1 13 lshift constant CURLPROTO_IMAPS
1 14 lshift constant CURLPROTO_POP3
1 15 lshift constant CURLPROTO_POP3S
1 16 lshift constant CURLPROTO_SMTP
1 17 lshift constant CURLPROTO_SMTPS
1 18 lshift constant CURLPROTO_RTSP
1 19 lshift constant CURLPROTO_RTMP
1 20 lshift constant CURLPROTO_RTMPT
1 21 lshift constant CURLPROTO_RTMPE
1 22 lshift constant CURLPROTO_RTMPTE
1 23 lshift constant CURLPROTO_RTMPS
1 24 lshift constant CURLPROTO_RTMPTS
1 25 lshift constant CURLPROTO_GOPHER
-1 constant CURLPROTO_ALL

\ long may be 32 or 64 bits, but we should never depend on
\ anything else but 32
0 constant CURLOPTTYPE_LONG
10000 constant CURLOPTTYPE_OBJECTPOINT
20000 constant CURLOPTTYPE_FUNCTIONPOINT
30000 constant CURLOPTTYPE_OFF_T

((
#define CINIT(na,t,nu) CURLOPT_ ## na = CURLOPTTYPE_ ## t + nu
->
CURLOPTTYPE_type num + constant CURLOPT_name
))

: remove,	\ caddr --
\ remove a trailing,
  dup count + 1- c@ [char] , =
  if  -1 over c+!  endif
  drop
;

: cinit(	\ -- ; )
\ simulates C CINIT( ... ) macro above.
  {: | name[ 256 ] type[ 256 ] num[ 256 ] eval[ 256 ] -- :}
  parse-name name[ place  name[ remove,	\ name
  parse-name type[ place  type[ remove,	\ type
  parse-name num[ place  num[ remove,	\ number
  0 word drop				\ to end of line

  s" CURLOPTTYPE_" eval[ place
  type[ count eval[ append
  bl eval[ addchar
  num[ count eval[ append
  s"  + constant CURLOPT_" eval[ append
  name[ count eval[ append
\ cr ." CINIT (" eval[ count type ." )"
  eval[ count evaluate
\ cr ." CINIT( ... ) done"
;

  /* This is the FILE * or void * the regular output should be written to. */
  CINIT( FILE, OBJECTPOINT, 1 )

  /* The full URL to get/put */
  CINIT( URL,  OBJECTPOINT, 2 )

  /* Port number to connect to, if other than default. */
  CINIT( PORT, LONG, 3 )

  /* Name of proxy to use. */
  CINIT( PROXY, OBJECTPOINT, 4 )

  /* "name:password" to use when fetching. */
  CINIT( USERPWD, OBJECTPOINT, 5 )

  /* "name:password" to use with proxy. */
  CINIT( PROXYUSERPWD, OBJECTPOINT, 6 )

  /* Range to get, specified as an ASCII string. */
  CINIT( RANGE, OBJECTPOINT, 7 )

  /* not used */

  /* Specified file stream to upload from (use as input): */
  CINIT( INFILE, OBJECTPOINT, 9 )

  /* Buffer to receive error messages in, must be at least CURL_ERROR_SIZE
   * bytes big. If this is not used, error messages go to stderr instead: */
  CINIT( ERRORBUFFER, OBJECTPOINT, 10 )

  /* Function that will be called to store the output (instead of fwrite). The
   * parameters will use fwrite() syntax, make sure to follow them. */
  CINIT( WRITEFUNCTION, FUNCTIONPOINT, 11 )

  /* Function that will be called to read the input (instead of fread). The
   * parameters will use fread() syntax, make sure to follow them. */
  CINIT( READFUNCTION, FUNCTIONPOINT, 12 )

  /* Time-out the read operation after this amount of seconds */
  CINIT( TIMEOUT, LONG, 13 )

  /* If the CURLOPT_INFILE is used, this can be used to inform libcurl about
   * how large the file being sent really is. That allows better error
   * checking and better verifies that the upload was successful. -1 means
   * unknown size.
   *
   * For large file support, there is also a _LARGE version of the key
   * which takes an off_t type, allowing platforms with larger off_t
   * sizes to handle larger files.  See below for INFILESIZE_LARGE.
   */
  CINIT( INFILESIZE, LONG, 14 )

  /* POST static input fields. */
  CINIT( POSTFIELDS, OBJECTPOINT, 15 )

  /* Set the referrer page (needed by some CGIs) */
  CINIT( REFERER, OBJECTPOINT, 16 )

  /* Set the FTP PORT string (interface name, named or numerical IP address)
     Use i.e '-' to use default address. */
  CINIT( FTPPORT, OBJECTPOINT, 17 )

  /* Set the User-Agent string (examined by some CGIs) */
  CINIT( USERAGENT, OBJECTPOINT, 18 )

  /* If the download receives less than "low speed limit" bytes/second
   * during "low speed time" seconds, the operations is aborted.
   * You could i.e if you have a pretty high speed connection, abort if
   * it is less than 2000 bytes/sec during 20 seconds.
   */

  /* Set the "low speed limit" */
  CINIT( LOW_SPEED_LIMIT, LONG, 19 )

  /* Set the "low speed time" */
  CINIT( LOW_SPEED_TIME, LONG, 20 )

  /* Set the continuation offset.
   *
   * Note there is also a _LARGE version of this key which uses
   * off_t types, allowing for large file offsets on platforms which
   * use larger-than-32-bit off_t's.  Look below for RESUME_FROM_LARGE.
   */
  CINIT( RESUME_FROM, LONG, 21 )

  /* Set cookie in request: */
  CINIT( COOKIE, OBJECTPOINT, 22 )

  /* This points to a linked list of headers, struct curl_slist kind */
  CINIT( HTTPHEADER, OBJECTPOINT, 23 )

  /* This points to a linked list of post entries, struct curl_httppost */
  CINIT( HTTPPOST, OBJECTPOINT, 24 )

  /* name of the file keeping your private SSL-certificate */
  CINIT( SSLCERT, OBJECTPOINT, 25 )

  /* password for the SSL or SSH private key */
  CINIT( KEYPASSWD, OBJECTPOINT, 26 )

  /* send TYPE parameter? */
  CINIT( CRLF, LONG, 27 )

  /* send linked-list of QUOTE commands */
  CINIT( QUOTE, OBJECTPOINT, 28 )

  /* send FILE * or void * to store headers to, if you use a callback it
     is simply passed to the callback unmodified */
  CINIT( WRITEHEADER, OBJECTPOINT, 29 )

  /* point to a file to read the initial cookies from, also enables
     "cookie awareness" */
  CINIT( COOKIEFILE, OBJECTPOINT, 31 )

  /* What version to specifically try to use.
     See CURL_SSLVERSION defines below. */
  CINIT( SSLVERSION, LONG, 32 )

  /* What kind of HTTP time condition to use, see defines */
  CINIT( TIMECONDITION, LONG, 33 )

  /* Time to use with the above condition. Specified in number of seconds
     since 1 Jan 1970 */
  CINIT( TIMEVALUE, LONG, 34 )

  /* 35 = OBSOLETE */

  /* Custom request, for customizing the get command like
     HTTP: DELETE, TRACE and others
     FTP: to use a different list command
     */
  CINIT( CUSTOMREQUEST, OBJECTPOINT, 36 )

  /* HTTP request, for odd commands like DELETE, TRACE and others */
  CINIT( STDERR, OBJECTPOINT, 37 )

  /* 38 is not used */

  /* send linked-list of post-transfer QUOTE commands */
  CINIT( POSTQUOTE, OBJECTPOINT, 39 )

  CINIT( WRITEINFO, OBJECTPOINT, 40 )  /* DEPRECATED, do not use! */

  CINIT( VERBOSE, LONG, 41 )       /* talk a lot */
  CINIT( HEADER, LONG, 42 )        /* throw the header out too */
  CINIT( NOPROGRESS, LONG, 43 )    /* shut off the progress meter */
  CINIT( NOBODY, LONG, 44 )        /* use HEAD to get http document */
  CINIT( FAILONERROR, LONG, 45 )   /* no output on http error codes >= 300 */
  CINIT( UPLOAD, LONG, 46 )        /* this is an upload */
  CINIT( POST, LONG, 47 )          /* HTTP POST method */
  CINIT( DIRLISTONLY, LONG, 48 )   /* bare names when listing directories */

  CINIT( APPEND, LONG, 50 )        /* Append instead of overwrite on upload! */

  /* Specify whether to read the user+password from the .netrc or the URL.
   * This must be one of the CURL_NETRC_* enums below. */
  CINIT( NETRC, LONG, 51 )

  CINIT( FOLLOWLOCATION, LONG, 52 )   /* use Location: Luke! */

  CINIT( TRANSFERTEXT, LONG, 53 )  /* transfer data in text/ASCII format */
  CINIT( PUT, LONG, 54 )           /* HTTP PUT */

  /* 55 = OBSOLETE */

  /* Function that will be called instead of the internal progress display
   * function. This function should be defined as the curl_progress_callback
   * prototype defines. */
  CINIT( PROGRESSFUNCTION, FUNCTIONPOINT, 56 )

  /* Data passed to the progress callback */
  CINIT( PROGRESSDATA, OBJECTPOINT, 57 )

  /* We want the referrer field set automatically when following locations */
  CINIT( AUTOREFERER, LONG, 58 )

  /* Port of the proxy, can be set in the proxy string as well with:
     "[host]:[port]" */
  CINIT( PROXYPORT, LONG, 59 )

  /* size of the POST input data, if strlen() is not good to use */
  CINIT( POSTFIELDSIZE, LONG, 60 )

  /* tunnel non-http operations through a HTTP proxy */
  CINIT( HTTPPROXYTUNNEL, LONG, 61 )

  /* Set the interface string to use as outgoing network interface */
  CINIT( INTERFACE, OBJECTPOINT, 62 )

  /* Set the krb4/5 security level, this also enables krb4/5 awareness.  This
   * is a string, 'clear', 'safe', 'confidential' or 'private'.  If the string
   * is set but doesn't match one of these, 'private' will be used.  */
  CINIT( KRBLEVEL, OBJECTPOINT, 63 )

  /* Set if we should verify the peer in ssl handshake, set 1 to verify. */
  CINIT( SSL_VERIFYPEER, LONG, 64 )

  /* The CApath or CAfile used to validate the peer certificate
     this option is used only if SSL_VERIFYPEER is true */
  CINIT( CAINFO, OBJECTPOINT, 65 )

  /* 66 = OBSOLETE */
  /* 67 = OBSOLETE */

  /* Maximum number of http redirects to follow */
  CINIT( MAXREDIRS, LONG, 68 )

  /* Pass a long set to 1 to get the date of the requested document (if
     possible)! Pass a zero to shut it off. */
  CINIT( FILETIME, LONG, 69 )

  /* This points to a linked list of telnet options */
  CINIT( TELNETOPTIONS, OBJECTPOINT, 70 )

  /* Max amount of cached alive connections */
  CINIT( MAXCONNECTS, LONG, 71 )

  CINIT( CLOSEPOLICY, LONG, 72 )  /* DEPRECATED, do not use! */

  /* 73 = OBSOLETE */

  /* Set to explicitly use a new connection for the upcoming transfer.
     Do not use this unless you're absolutely sure of this, as it makes the
     operation slower and is less friendly for the network. */
  CINIT( FRESH_CONNECT, LONG, 74 )

  /* Set to explicitly forbid the upcoming transfer's connection to be re-used
     when done. Do not use this unless you're absolutely sure of this, as it
     makes the operation slower and is less friendly for the network. */
  CINIT( FORBID_REUSE, LONG, 75 )

  /* Set to a file name that contains random data for libcurl to use to
     seed the random engine when doing SSL connects. */
  CINIT( RANDOM_FILE, OBJECTPOINT, 76 )

  /* Set to the Entropy Gathering Daemon socket pathname */
  CINIT( EGDSOCKET, OBJECTPOINT, 77 )

  /* Time-out connect operations after this amount of seconds, if connects
     are OK within this time, then fine... This only aborts the connect
     phase. [Only works on unix-style/SIGALRM operating systems] */
  CINIT( CONNECTTIMEOUT, LONG, 78 )

  /* Function that will be called to store headers (instead of fwrite). The
   * parameters will use fwrite() syntax, make sure to follow them. */
  CINIT( HEADERFUNCTION, FUNCTIONPOINT, 79 )

  /* Set this to force the HTTP request to get back to GET. Only really usable
     if POST, PUT or a custom request have been used first.
   */
  CINIT( HTTPGET, LONG, 80 )

  /* Set if we should verify the Common name from the peer certificate in ssl
   * handshake, set 1 to check existence, 2 to ensure that it matches the
   * provided hostname. */
  CINIT( SSL_VERIFYHOST, LONG, 81 )

  /* Specify which file name to write all known cookies in after completed
     operation. Set file name to "-" (dash) to make it go to stdout. */
  CINIT( COOKIEJAR, OBJECTPOINT, 82 )

  /* Specify which SSL ciphers to use */
  CINIT( SSL_CIPHER_LIST, OBJECTPOINT, 83 )

  /* Specify which HTTP version to use! This must be set to one of the
     CURL_HTTP_VERSION* enums set below. */
  CINIT( HTTP_VERSION, LONG, 84 )

  /* Specifically switch on or off the FTP engine's use of the EPSV command. By
     default, that one will always be attempted before the more traditional
     PASV command. */
  CINIT( FTP_USE_EPSV, LONG, 85 )

  /* type of the file keeping your SSL-certificate ("DER", "PEM", "ENG") */
  CINIT( SSLCERTTYPE, OBJECTPOINT, 86 )

  /* name of the file keeping your private SSL-key */
  CINIT( SSLKEY, OBJECTPOINT, 87 )

  /* type of the file keeping your private SSL-key ("DER", "PEM", "ENG") */
  CINIT( SSLKEYTYPE, OBJECTPOINT, 88 )

  /* crypto engine for the SSL-sub system */
  CINIT( SSLENGINE, OBJECTPOINT, 89 )

  /* set the crypto engine for the SSL-sub system as default
     the param has no meaning...
   */
  CINIT( SSLENGINE_DEFAULT, LONG, 90 )

  /* Non-zero value means to use the global dns cache */
  CINIT( DNS_USE_GLOBAL_CACHE, LONG, 91 )  /* DEPRECATED, do not use! */

  /* DNS cache timeout */
  CINIT( DNS_CACHE_TIMEOUT, LONG, 92 )

  /* send linked-list of pre-transfer QUOTE commands */
  CINIT( PREQUOTE, OBJECTPOINT, 93 )

  /* set the debug function */
  CINIT( DEBUGFUNCTION, FUNCTIONPOINT, 94 )

  /* set the data for the debug function */
  CINIT( DEBUGDATA, OBJECTPOINT, 95 )

  /* mark this as start of a cookie session */
  CINIT( COOKIESESSION, LONG, 96 )

  /* The CApath directory used to validate the peer certificate
     this option is used only if SSL_VERIFYPEER is true */
  CINIT( CAPATH, OBJECTPOINT, 97 )

  /* Instruct libcurl to use a smaller receive buffer */
  CINIT( BUFFERSIZE, LONG, 98 )

  /* Instruct libcurl to not use any signal/alarm handlers, even when using
     timeouts. This option is useful for multi-threaded applications.
     See libcurl-the-guide for more background information. */
  CINIT( NOSIGNAL, LONG, 99 )

  /* Provide a CURLShare for mutexing non-ts data */
  CINIT( SHARE, OBJECTPOINT, 100 )

  /* indicates type of proxy. accepted values are CURLPROXY_HTTP (default )
     CURLPROXY_SOCKS4, CURLPROXY_SOCKS4A and CURLPROXY_SOCKS5. */
  CINIT( PROXYTYPE, LONG, 101 )

  /* Set the Accept-Encoding string. Use this to tell a server you would like
     the response to be compressed. Before 7.21.6, this was known as
     CURLOPT_ENCODING */
  CINIT( ACCEPT_ENCODING, OBJECTPOINT, 102 )

  /* Set pointer to private data */
  CINIT( PRIVATE, OBJECTPOINT, 103 )

  /* Set aliases for HTTP 200 in the HTTP Response header */
  CINIT( HTTP200ALIASES, OBJECTPOINT, 104 )

  /* Continue to send authentication (user+password) when following locations,
     even when hostname changed. This can potentially send off the name
     and password to whatever host the server decides. */
  CINIT( UNRESTRICTED_AUTH, LONG, 105 )

  /* Specifically switch on or off the FTP engine's use of the EPRT command (
     it also disables the LPRT attempt). By default, those ones will always be
     attempted before the good old traditional PORT command. */
  CINIT( FTP_USE_EPRT, LONG, 106 )

  /* Set this to a bitmask value to enable the particular authentications
     methods you like. Use this in combination with CURLOPT_USERPWD.
     Note that setting multiple bits may cause extra network round-trips. */
  CINIT( HTTPAUTH, LONG, 107 )

  /* Set the ssl context callback function, currently only for OpenSSL ssl_ctx
     in second argument. The function must be matching the
     curl_ssl_ctx_callback proto. */
  CINIT( SSL_CTX_FUNCTION, FUNCTIONPOINT, 108 )

  /* Set the userdata for the ssl context callback function's third
     argument */
  CINIT( SSL_CTX_DATA, OBJECTPOINT, 109 )

  /* FTP Option that causes missing dirs to be created on the remote server.
     In 7.19.4 we introduced the convenience enums for this option using the
     CURLFTP_CREATE_DIR prefix.
  */
  CINIT( FTP_CREATE_MISSING_DIRS, LONG, 110 )

  /* Set this to a bitmask value to enable the particular authentications
     methods you like. Use this in combination with CURLOPT_PROXYUSERPWD.
     Note that setting multiple bits may cause extra network round-trips. */
  CINIT( PROXYAUTH, LONG, 111 )

  /* FTP option that changes the timeout, in seconds, associated with
     getting a response.  This is different from transfer timeout time and
     essentially places a demand on the FTP server to acknowledge commands
     in a timely manner. */
  CINIT( FTP_RESPONSE_TIMEOUT, LONG, 112 )
#define CURLOPT_SERVER_RESPONSE_TIMEOUT CURLOPT_FTP_RESPONSE_TIMEOUT

  /* Set this option to one of the CURL_IPRESOLVE_* defines (see below) to
     tell libcurl to resolve names to those IP versions only. This only has
     affect on systems with support for more than one, i.e IPv4 _and_ IPv6. */
  CINIT( IPRESOLVE, LONG, 113 )

  /* Set this option to limit the size of a file that will be downloaded from
     an HTTP or FTP server.

     Note there is also _LARGE version which adds large file support for
     platforms which have larger off_t sizes.  See MAXFILESIZE_LARGE below. */
  CINIT( MAXFILESIZE, LONG, 114 )

  /* See the comment for INFILESIZE above, but in short, specifies
   * the size of the file being uploaded.  -1 means unknown.
   */
  CINIT( INFILESIZE_LARGE, OFF_T, 115 )

  /* Sets the continuation offset.  There is also a LONG version of this;
   * look above for RESUME_FROM.
   */
  CINIT( RESUME_FROM_LARGE, OFF_T, 116 )

  /* Sets the maximum size of data that will be downloaded from
   * an HTTP or FTP server.  See MAXFILESIZE above for the LONG version.
   */
  CINIT( MAXFILESIZE_LARGE, OFF_T, 117 )

  /* Set this option to the file name of your .netrc file you want libcurl
     to parse (using the CURLOPT_NETRC option). If not set, libcurl will do
     a poor attempt to find the user's home directory and check for a .netrc
     file in there. */
  CINIT( NETRC_FILE, OBJECTPOINT, 118 )

  /* Enable SSL/TLS for FTP, pick one of:
     CURLFTPSSL_TRY     - try using SSL, proceed anyway otherwise
     CURLFTPSSL_CONTROL - SSL for the control connection or fail
     CURLFTPSSL_ALL     - SSL for all communication or fail
  */
  CINIT( USE_SSL, LONG, 119 )

  /* The _LARGE version of the standard POSTFIELDSIZE option */
  CINIT( POSTFIELDSIZE_LARGE, OFF_T, 120 )

  /* Enable/disable the TCP Nagle algorithm */
  CINIT( TCP_NODELAY, LONG, 121 )

  /* 122 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
  /* 123 OBSOLETE. Gone in 7.16.0 */
  /* 124 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
  /* 125 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
  /* 126 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
  /* 127 OBSOLETE. Gone in 7.16.0 */
  /* 128 OBSOLETE. Gone in 7.16.0 */

  /* When FTP over SSL/TLS is selected (with CURLOPT_USE_SSL )  this option
     can be used to change libcurl's default action which is to first try
     "AUTH SSL" and then "AUTH TLS" in this order, and proceed when a OK
     response has been received.

     Available parameters are:
     CURLFTPAUTH_DEFAULT - let libcurl decide
     CURLFTPAUTH_SSL     - try "AUTH SSL" first, then TLS
     CURLFTPAUTH_TLS     - try "AUTH TLS" first, then SSL
  */
  CINIT( FTPSSLAUTH, LONG, 129 )

  CINIT( IOCTLFUNCTION, FUNCTIONPOINT, 130 )
  CINIT( IOCTLDATA, OBJECTPOINT, 131 )

  /* 132 OBSOLETE. Gone in 7.16.0 */
  /* 133 OBSOLETE. Gone in 7.16.0 */

  /* zero terminated string for pass on to the FTP server when asked for
     "account" info */
  CINIT( FTP_ACCOUNT, OBJECTPOINT, 134 )

  /* feed cookies into cookie engine */
  CINIT( COOKIELIST, OBJECTPOINT, 135 )

  /* ignore Content-Length */
  CINIT( IGNORE_CONTENT_LENGTH, LONG, 136 )

  /* Set to non-zero to skip the IP address received in a 227 PASV FTP server
     response. Typically used for FTP-SSL purposes but is not restricted to
     that. libcurl will then instead use the same IP address it used for the
     control connection. */
  CINIT( FTP_SKIP_PASV_IP, LONG, 137 )

  /* Select "file method" to use when doing FTP, see the curl_ftpmethod
     above. */
  CINIT( FTP_FILEMETHOD, LONG, 138 )

  /* Local port number to bind the socket to */
  CINIT( LOCALPORT, LONG, 139 )

  /* Number of ports to try, including the first one set with LOCALPORT.
     Thus, setting it to 1 will make no additional attempts but the first.
  */
  CINIT( LOCALPORTRANGE, LONG, 140 )

  /* no transfer, set up connection and let application use the socket by
     extracting it with CURLINFO_LASTSOCKET */
  CINIT( CONNECT_ONLY, LONG, 141 )

  /* Function that will be called to convert from the
     network encoding (instead of using the iconv calls in libcurl) */
  CINIT( CONV_FROM_NETWORK_FUNCTION, FUNCTIONPOINT, 142 )

  /* Function that will be called to convert to the
     network encoding (instead of using the iconv calls in libcurl) */
  CINIT( CONV_TO_NETWORK_FUNCTION, FUNCTIONPOINT, 143 )

  /* Function that will be called to convert from UTF8
     (instead of using the iconv calls in libcurl)
     Note that this is used only for SSL certificate processing */
  CINIT( CONV_FROM_UTF8_FUNCTION, FUNCTIONPOINT, 144 )

  /* if the connection proceeds too quickly then need to slow it down */
  /* limit-rate: maximum number of bytes per second to send or receive */
  CINIT( MAX_SEND_SPEED_LARGE, OFF_T, 145 )
  CINIT( MAX_RECV_SPEED_LARGE, OFF_T, 146 )

  /* Pointer to command string to send if USER/PASS fails. */
  CINIT( FTP_ALTERNATIVE_TO_USER, OBJECTPOINT, 147 )

  /* callback function for setting socket options */
  CINIT( SOCKOPTFUNCTION, FUNCTIONPOINT, 148 )
  CINIT( SOCKOPTDATA, OBJECTPOINT, 149 )

  /* set to 0 to disable session ID re-use for this transfer, default is
     enabled (== 1) */
  CINIT( SSL_SESSIONID_CACHE, LONG, 150 )

  /* allowed SSH authentication methods */
  CINIT( SSH_AUTH_TYPES, LONG, 151 )

  /* Used by scp/sftp to do public/private key authentication */
  CINIT( SSH_PUBLIC_KEYFILE, OBJECTPOINT, 152 )
  CINIT( SSH_PRIVATE_KEYFILE, OBJECTPOINT, 153 )

  /* Send CCC (Clear Command Channel) after authentication */
  CINIT( FTP_SSL_CCC, LONG, 154 )

  /* Same as TIMEOUT and CONNECTTIMEOUT, but with ms resolution */
  CINIT( TIMEOUT_MS, LONG, 155 )
  CINIT( CONNECTTIMEOUT_MS, LONG, 156 )

  /* set to zero to disable the libcurl's decoding and thus pass the raw body
     data to the application even when it is encoded/compressed */
  CINIT( HTTP_TRANSFER_DECODING, LONG, 157 )
  CINIT( HTTP_CONTENT_DECODING, LONG, 158 )

  /* Permission used when creating new files and directories on the remote
     server for protocols that support it, SFTP/SCP/FILE */
  CINIT( NEW_FILE_PERMS, LONG, 159 )
  CINIT( NEW_DIRECTORY_PERMS, LONG, 160 )

  /* Set the behaviour of POST when redirecting. Values must be set to one
     of CURL_REDIR* defines below. This used to be called CURLOPT_POST301 */
  CINIT( POSTREDIR, LONG, 161 )

  /* used by scp/sftp to verify the host's public key */
  CINIT( SSH_HOST_PUBLIC_KEY_MD5, OBJECTPOINT, 162 )

  /* Callback function for opening socket (instead of socket(2) ). Optionally,
     callback is able change the address or refuse to connect returning
     CURL_SOCKET_BAD.  The callback should have type
     curl_opensocket_callback */
  CINIT( OPENSOCKETFUNCTION, FUNCTIONPOINT, 163 )
  CINIT( OPENSOCKETDATA, OBJECTPOINT, 164 )

  /* POST volatile input fields. */
  CINIT( COPYPOSTFIELDS, OBJECTPOINT, 165 )

  /* set transfer mode (;type=<a|i>) when doing FTP via an HTTP proxy */
  CINIT( PROXY_TRANSFER_MODE, LONG, 166 )

  /* Callback function for seeking in the input stream */
  CINIT( SEEKFUNCTION, FUNCTIONPOINT, 167 )
  CINIT( SEEKDATA, OBJECTPOINT, 168 )

  /* CRL file */
  CINIT( CRLFILE, OBJECTPOINT, 169 )

  /* Issuer certificate */
  CINIT( ISSUERCERT, OBJECTPOINT, 170 )

  /* (IPv6) Address scope */
  CINIT( ADDRESS_SCOPE, LONG, 171 )

  /* Collect certificate chain info and allow it to get retrievable with
     CURLINFO_CERTINFO after the transfer is complete. (Unfortunately) only
     working with OpenSSL-powered builds. */
  CINIT( CERTINFO, LONG, 172 )

  /* "name" and "pwd" to use when fetching. */
  CINIT( USERNAME, OBJECTPOINT, 173 )
  CINIT( PASSWORD, OBJECTPOINT, 174 )

    /* "name" and "pwd" to use with Proxy when fetching. */
  CINIT( PROXYUSERNAME, OBJECTPOINT, 175 )
  CINIT( PROXYPASSWORD, OBJECTPOINT, 176 )

  /* Comma separated list of hostnames defining no-proxy zones. These should
     match both hostnames directly, and hostnames within a domain. For
     example, local.com will match local.com and www.local.com, but NOT
     notlocal.com or www.notlocal.com. For compatibility with other
     implementations of this, .local.com will be considered to be the same as
     local.com. A single * is the only valid wildcard, and effectively
     disables the use of proxy. */
  CINIT( NOPROXY, OBJECTPOINT, 177 )

  /* block size for TFTP transfers */
  CINIT( TFTP_BLKSIZE, LONG, 178 )

  /* Socks Service */
  CINIT( SOCKS5_GSSAPI_SERVICE, OBJECTPOINT, 179 )

  /* Socks Service */
  CINIT( SOCKS5_GSSAPI_NEC, LONG, 180 )

  /* set the bitmask for the protocols that are allowed to be used for the
     transfer, which thus helps the app which takes URLs from users or other
     external inputs and want to restrict what protocol(s) to deal
     with. Defaults to CURLPROTO_ALL. */
  CINIT( PROTOCOLS, LONG, 181 )

  /* set the bitmask for the protocols that libcurl is allowed to follow to,
     as a subset of the CURLOPT_PROTOCOLS ones. That means the protocol needs
     to be set in both bitmasks to be allowed to get redirected to. Defaults
     to all protocols except FILE and SCP. */
  CINIT( REDIR_PROTOCOLS, LONG, 182 )

  /* set the SSH knownhost file name to use */
  CINIT( SSH_KNOWNHOSTS, OBJECTPOINT, 183 )

  /* set the SSH host key callback, must point to a curl_sshkeycallback
     function */
  CINIT( SSH_KEYFUNCTION, FUNCTIONPOINT, 184 )

  /* set the SSH host key callback custom pointer */
  CINIT( SSH_KEYDATA, OBJECTPOINT, 185 )

  /* set the SMTP mail originator */
  CINIT( MAIL_FROM, OBJECTPOINT, 186 )

  /* set the SMTP mail receiver(s) */
  CINIT( MAIL_RCPT, OBJECTPOINT, 187 )

  /* FTP: send PRET before PASV */
  CINIT( FTP_USE_PRET, LONG, 188 )

  /* RTSP request method (OPTIONS, SETUP, PLAY, etc...) */
  CINIT( RTSP_REQUEST, LONG, 189 )

  /* The RTSP session identifier */
  CINIT( RTSP_SESSION_ID, OBJECTPOINT, 190 )

  /* The RTSP stream URI */
  CINIT( RTSP_STREAM_URI, OBJECTPOINT, 191 )

  /* The Transport: header to use in RTSP requests */
  CINIT( RTSP_TRANSPORT, OBJECTPOINT, 192 )

  /* Manually initialize the client RTSP CSeq for this handle */
  CINIT( RTSP_CLIENT_CSEQ, LONG, 193 )

  /* Manually initialize the server RTSP CSeq for this handle */
  CINIT( RTSP_SERVER_CSEQ, LONG, 194 )

  /* The stream to pass to INTERLEAVEFUNCTION. */
  CINIT( INTERLEAVEDATA, OBJECTPOINT, 195 )

  /* Let the application define a custom write method for RTP data */
  CINIT( INTERLEAVEFUNCTION, FUNCTIONPOINT, 196 )

  /* Turn on wildcard matching */
  CINIT( WILDCARDMATCH, LONG, 197 )

  /* Directory matching callback called before downloading of an
     individual file (chunk) started */
  CINIT( CHUNK_BGN_FUNCTION, FUNCTIONPOINT, 198 )

  /* Directory matching callback called after the file (chunk)
     was downloaded, or skipped */
  CINIT( CHUNK_END_FUNCTION, FUNCTIONPOINT, 199 )

  /* Change match (fnmatch-like) callback for wildcard matching */
  CINIT( FNMATCH_FUNCTION, FUNCTIONPOINT, 200 )

  /* Let the application define custom chunk data pointer */
  CINIT( CHUNK_DATA, OBJECTPOINT, 201 )

  /* FNMATCH_FUNCTION user pointer */
  CINIT( FNMATCH_DATA, OBJECTPOINT, 202 )

  /* send linked-list of name:port:address sets */
  CINIT( RESOLVE, OBJECTPOINT, 203 )

  /* Set a username for authenticated TLS */
  CINIT( TLSAUTH_USERNAME, OBJECTPOINT, 204 )

  /* Set a password for authenticated TLS */
  CINIT( TLSAUTH_PASSWORD, OBJECTPOINT, 205 )

  /* Set authentication type for authenticated TLS */
  CINIT( TLSAUTH_TYPE, OBJECTPOINT, 206 )

  /* Set to 1 to enable the "TE:" header in HTTP requests to ask for
     compressed transfer-encoded responses. Set to 0 to disable the use of TE:
     in outgoing requests. The current default is 0, but it might change in a
     future libcurl release.

     libcurl will ask for the compressed methods it knows of, and if that
     isn't any, it will not ask for transfer-encoding at all even if this
     option is set to 1.

  */
  CINIT( TRANSFER_ENCODING, LONG, 207 )

  /* Callback function for closing socket (instead of close(2) ). The callback
     should have type curl_closesocket_callback */
  CINIT( CLOSESOCKETFUNCTION, FUNCTIONPOINT, 208 )
  CINIT( CLOSESOCKETDATA, OBJECTPOINT, 209 )

  /* allow GSSAPI credential delegation */
  CINIT( GSSAPI_DELEGATION, LONG, 210 )

  /* Set the name servers to use for DNS resolution */
  CINIT( DNS_SERVERS, OBJECTPOINT, 211 )

  /* Time-out accept operations (currently for FTP only) after this amount
     of miliseconds. */
  CINIT( ACCEPTTIMEOUT_MS, LONG, 212 )

  /* Set TCP keepalive */
  CINIT( TCP_KEEPALIVE, LONG, 213 )

  /* non-universal keepalive knobs (Linux, AIX, HP-UX, more) */
  CINIT( TCP_KEEPIDLE, LONG, 214 )
  CINIT( TCP_KEEPINTVL, LONG, 215 )

  /* Enable/disable specific SSL features with a bitmask, see CURLSSLOPT_* */
  CINIT( SSL_OPTIONS, LONG, 216 )

  /* set the SMTP auth originator */
  CINIT( MAIL_AUTH, OBJECTPOINT, 217 )

\  CURLOPT_LASTENTRY /* the last unused */


\ Below here follows defines for the CURLOPT_IPRESOLVE option. If a host
\ name resolves addresses using more than one IP protocol version, this
\ option might be handy to force libcurl to use a specific IP version.
0 constant CURL_IPRESOLVE_WHATEVER \ default, resolves addresses to all IP
                                   \ versions that your system allows
1 constant CURL_IPRESOLVE_V4       \ resolve to ipv4 addresses
2 constant CURL_IPRESOLVE_V6       \ resolve to ipv6 addresses

((
  /* three convenient "aliases" that follow the name scheme better */
#define CURLOPT_WRITEDATA CURLOPT_FILE
#define CURLOPT_READDATA  CURLOPT_INFILE
#define CURLOPT_HEADERDATA CURLOPT_WRITEHEADER
#define CURLOPT_RTSPHEADER CURLOPT_HTTPHEADER
))

\ These enums are for use with the CURLOPT_HTTP_VERSION option.
0 constant  CURL_HTTP_VERSION_NONE \ setting this means we don't care, and that we'd
                                   \ like the library to choose the best possible
                                   \ for us!
1 constant CURL_HTTP_VERSION_1_0   \ please use HTTP 1.0 in the request
2 constant CURL_HTTP_VERSION_1_1   \ please use HTTP 1.1 in the request

3 constant CURL_HTTP_VERSION_LAST \ *ILLEGAL* http version

\ *
\ * Public API enums for RTSP requests
\ *
0 constant CURL_RTSPREQ_NONE, \ first in list
1 constant CURL_RTSPREQ_OPTIONS
2 constant CURL_RTSPREQ_DESCRIBE
3 constant CURL_RTSPREQ_ANNOUNCE
4 constant CURL_RTSPREQ_SETUP
5 constant CURL_RTSPREQ_PLAY
6 constant CURL_RTSPREQ_PAUSE
7 constant CURL_RTSPREQ_TEARDOWN
8 constant CURL_RTSPREQ_GET_PARAMETER
9 constant CURL_RTSPREQ_SET_PARAMETER
10 constant CURL_RTSPREQ_RECORD
11 constant CURL_RTSPREQ_RECEIVE
12 constant CURL_RTSPREQ_LAST \ last in list

\ These enums are for use with the CURLOPT_NETRC option.
0 constant CURL_NETRC_IGNORED
\ The .netrc will never be read. This is the default.
1 constant CURL_NETRC_OPTIONAL
\ A user:password in the URL will be preferred to one in the .netrc.
2 constant CURL_NETRC_REQUIRED
\ A user:password in the URL will be ignored.
\ Unless one is set programmatically, the .netrc
\ will be queried.
3 constant CURL_NETRC_LAST

0 constant CURL_SSLVERSION_DEFAULT
1 constant CURL_SSLVERSION_TLSv1
2 constant CURL_SSLVERSION_SSLv2
3 constant CURL_SSLVERSION_SSLv3
4 constant CURL_SSLVERSION_LAST		\ never use, keep last

0 constant CURL_TLSAUTH_NONE
1 constant CURL_TLSAUTH_SRP
2 constant CURL_TLSAUTH_LAST		\ never use, keep last

\ symbols to use with CURLOPT_POSTREDIR.
\   CURL_REDIR_POST_301 and CURL_REDIR_POST_302 can be bitwise ORed so that
\   CURL_REDIR_POST_301 | CURL_REDIR_POST_302 == CURL_REDIR_POST_ALL
0 constant CURL_REDIR_GET_ALL
1 constant CURL_REDIR_POST_301
2 constant CURL_REDIR_POST_302
CURL_REDIR_POST_301 CURL_REDIR_POST_302 or constant CURL_REDIR_POST_ALL

0 constant CURL_TIMECOND_NONE
1 constant CURL_TIMECOND_IFMODSINCE
2 constant CURL_TIMECOND_IFUNMODSINCE
3 constant CURL_TIMECOND_LASTMOD
4 constant CURL_TIMECOND_LAST

((
/* curl_strequal() and curl_strnequal() are subject for removal in a future
   libcurl, see lib/README.curlx for details */
CURL_EXTERN int (curl_strequal)(const char *s1, const char *s2);
CURL_EXTERN int (curl_strnequal)(const char *s1, const char *s2, size_t n);
))

((
/* The macro "##" is ISO C, we assume pre-ISO C doesn't support it. */
#define CFINIT(name) CURLFORM_/**/name
#endif
))
0 constant CURLFORM_NOTHING		\ the first one is unused

1 constant CURLFORM_COPYNAME
2 constant CURLFORM_PTRNAME
3 constant CURLFORM_NAMELENGTH
4 constant CURLFORM_COPYCONTENTS
5 constant CURLFORM_PTRCONTENTS
6 constant CURLFORM_CONTENTSLENGTH
7 constant CURLFORM_FILECONTENT
8 constant CURLFORM_ARRAY
9 constant CURLFORM_OBSOLETE
10 constant CURLFORM_FILE

11 constant CURLFORM_BUFFER
12 constant CURLFORM_BUFFERPTR
13 constant CURLFORM_BUFFERLENGTH

14 constant CURLFORM_CONTENTTYPE
15 constant CURLFORM_CONTENTHEADER
16 constant CURLFORM_FILENAME
17 constant CURLFORM_END
18 constant CURLFORM_OBSOLETE2

19 constant CURLFORM_STREAM

20 constant CURLFORM_LASTENTRY		\ the last unused

\ structure to be used as parameter for CURLFORM_ARRAY
struct /curl_forms	\ -- len
  int cfo.option
  int cfo.*value
end-struct

/* use this for multipart formpost building */
/* Returns code for curl_formadd()
 *
 * Returns:
 * CURL_FORMADD_OK             on success
 * CURL_FORMADD_MEMORY         if the FormInfo allocation fails
 * CURL_FORMADD_OPTION_TWICE   if one option is given twice for one Form
 * CURL_FORMADD_NULL           if a null pointer was given for a char
 * CURL_FORMADD_MEMORY         if the allocation of a FormInfo struct failed
 * CURL_FORMADD_UNKNOWN_OPTION if an unknown option was used
 * CURL_FORMADD_INCOMPLETE     if the some FormInfo is not complete (or error)
 * CURL_FORMADD_MEMORY         if a curl_httppost struct cannot be allocated
 * CURL_FORMADD_MEMORY         if some allocation for string copying failed.
 * CURL_FORMADD_ILLEGAL_ARRAY  if an illegal option is used in an array
 *
 ************************************************************************** */

0 constant CURL_FORMADD_OK \ first, no error

1 constant  CURL_FORMADD_MEMORY
2 constant  CURL_FORMADD_OPTION_TWICE
3 constant  CURL_FORMADD_NULL
4 constant CURL_FORMADD_UNKNOWN_OPTION
5 constant CURL_FORMADD_INCOMPLETE
6 constant CURL_FORMADD_ILLEGAL_ARRAY
7 constant CURL_FORMADD_DISABLED \ libcurl was built with this disabled

8 constant CURL_FORMADD_LAST \ last

/*
 * NAME curl_formadd()
 *
 * DESCRIPTION
 *
 * Pretty advanced function for building multi-part formposts. Each invoke
 * adds one part that together construct a full post. Then use
 * CURLOPT_HTTPPOST to send it off to libcurl.
 */
Extern: int "C" curl_formadd(
 void ** httppost, void ** last_post, ...
);

/*
 * callback function for curl_formget()
 * The void *arg pointer will be the one passed as second argument to
 *   curl_formget().
 * The character buffer passed to it must not be freed.
 * Should return the buffer length passed to it as the argument "len" on
 *   success.
 */
((
typedef size_t (*curl_formget_callback)(
  void *arg, const char *buf, size_t len
);
))

/*
 * NAME curl_formget()
 *
 * DESCRIPTION
 *
 * Serialize a curl_httppost struct built with curl_formadd().
 * Accepts a void pointer as second argument which will be passed to
 * the curl_formget_callback function.
 * Returns 0 on success.
 */
Extern: int "C" curl_formget(
  void * form, void * arg, void * append
);

/*
 * NAME curl_formfree()
 *
 * DESCRIPTION
 *
 * Free a multipart formpost previously built with curl_formadd().
 */
Extern: void "C" curl_formfree( void *form );

/*
 * NAME curl_getenv()
 *
 * DESCRIPTION
 *
 * Returns a malloc()'ed string that MUST be curl_free()ed after usage is
 * complete. DEPRECATED - see lib/README.curlx
 */
Extern: char * "C" curl_getenv( const char * variable );

/*
 * NAME curl_version()
 *
 * DESCRIPTION
 *
 * Returns a static ascii string of the libcurl version.
 */
Extern: char * "C" curl_version( void );

/*
 * NAME curl_easy_escape()
 *
 * DESCRIPTION
 *
 * Escapes URL strings (converts all letters consider illegal in URLs to their
 * %XX versions). This function returns a new allocated string or NULL if an
 * error occurred.
 */
Extern: char * "C" curl_easy_escape(
  void * handle, const char * string, int length
);

/* the previous version: */
Extern: char * "C" curl_escape(
  const char * string, int length
);


/*
 * NAME curl_easy_unescape()
 *
 * DESCRIPTION
 *
 * Unescapes URL encoding in strings (converts all %XX codes to their 8bit
 * versions). This function returns a new allocated string or NULL if an error
 * occurred.
 * Conversion Note: On non-ASCII platforms the ASCII %XX codes are
 * converted into the host encoding.
 */
Extern: char * "C" curl_easy_unescape(
  void * handle, const char * string, int length, int *outlength
);

/* the previous version */
Extern: char * "C" curl_unescape(
  const char * string, int length
);

/*
 * NAME curl_free()
 *
 * DESCRIPTION
 *
 * Provided for de-allocation in the same translation unit that did the
 * allocation. Added in libcurl 7.10
 */
Extern: void "C" curl_free( void * p );

/*
 * NAME curl_global_init()
 *
 * DESCRIPTION
 *
 * curl_global_init() should be invoked exactly once for each application that
 * uses libcurl and before any call of other libcurl functions.
 *
 * This function is not thread-safe!
 */
Extern: int "C" curl_global_init( long flags );

/*
 * NAME curl_global_init_mem()
 *
 * DESCRIPTION
 *
 * curl_global_init() or curl_global_init_mem() should be invoked exactly once
 * for each application that uses libcurl.  This function can be used to
 * initialize libcurl and set user defined memory management callback
 * functions.  Users can implement memory management routines to check for
 * memory leaks, check for mis-use of the curl library etc.  User registered
 * callback routines with be invoked by this library instead of the system
 * memory management routines like malloc, free etc.
 */
Extern: int curl_global_init_mem(
  long flags,
  void * m,	// curl_malloc_callback m,
  void * f,	// curl_free_callback f,
  void * r,	// curl_realloc_callback r,
  void * s,	// curl_strdup_callback s,
  void * c	// curl_calloc_callback c
);

/*
 * NAME curl_global_cleanup()
 *
 * DESCRIPTION
 *
 * curl_global_cleanup() should be invoked exactly once for each application
 * that uses libcurl
 */
Extern: void "C" curl_global_cleanup( void );

\ linked-list structure for the CURLOPT_QUOTE option (and other) */
struct /curl_slist	\ -- len
  int csl.*data
  int csl.*next
end-struct

/*
 * NAME curl_slist_append()
 *
 * DESCRIPTION
 *
 * Appends a string to a linked list. If no list exists, it will be created
 * first. Returns the new list, after appending.
 */
Extern: void * "C" curl_slist_append(
  void *, const char *
);

/*
 * NAME curl_slist_free_all()
 *
 * DESCRIPTION
 *
 * free a previously built curl_slist.
 */
Extern: void "C" curl_slist_free_all( void * );

/*
 * NAME curl_getdate()
 *
 * DESCRIPTION
 *
 * Returns the time, in seconds since 1 Jan 1970 of the time string given in
 * the first argument. The time argument in the second parameter is unused
 * and should be set to NULL.
 */
Extern: time_t "C" curl_getdate( const char * p, const time_t * unused );

\ info about the certificate chain, only for OpenSSL builds. Asked
\ for with CURLOPT_CERTINFO / CURLINFO_CERTINFO
struct /curl_certinfo	\ -- len
  int cci.num_of_certs	\ number of certificates with information
  int cci.**certinfo	\ for each index in this array, there's a
                        \ linked list with textual information in the
                        \ format "name: value"
end-struct

0x100000 constant CURLINFO_STRING
0x200000 constant CURLINFO_LONG
0x300000 constant CURLINFO_DOUBLE
0x400000 constant CURLINFO_SLIST
0x0fffff constant CURLINFO_MASK
0xf00000 constant CURLINFO_TYPEMASK

0 constant CURLINFO_NONE	\ first, never use this
CURLINFO_STRING 1 + constant CURLINFO_EFFECTIVE_URL
CURLINFO_LONG   2 + constant CURLINFO_RESPONSE_CODE
CURLINFO_DOUBLE 3 + constant CURLINFO_TOTAL_TIME
CURLINFO_DOUBLE 4 + constant CURLINFO_NAMELOOKUP_TIME
CURLINFO_DOUBLE 5 + constant CURLINFO_CONNECT_TIME
CURLINFO_DOUBLE 6 + constant CURLINFO_PRETRANSFER_TIME
CURLINFO_DOUBLE 7 + constant CURLINFO_SIZE_UPLOAD
CURLINFO_DOUBLE 8 + constant CURLINFO_SIZE_DOWNLOAD
CURLINFO_DOUBLE 9 + constant CURLINFO_SPEED_DOWNLOAD
CURLINFO_DOUBLE 10 + constant CURLINFO_SPEED_UPLOAD
CURLINFO_LONG   11 + constant CURLINFO_HEADER_SIZE
CURLINFO_LONG   12 + constant CURLINFO_REQUEST_SIZE
CURLINFO_LONG   13 + constant CURLINFO_SSL_VERIFYRESULT
CURLINFO_LONG   14 + constant CURLINFO_FILETIME
CURLINFO_DOUBLE 15 + constant CURLINFO_CONTENT_LENGTH_DOWNLOAD
CURLINFO_DOUBLE 16 + constant CURLINFO_CONTENT_LENGTH_UPLOAD
CURLINFO_DOUBLE 17 + constant CURLINFO_STARTTRANSFER_TIME
CURLINFO_STRING 18 + constant CURLINFO_CONTENT_TYPE
CURLINFO_DOUBLE 19 + constant CURLINFO_REDIRECT_TIME
CURLINFO_LONG   20 + constant CURLINFO_REDIRECT_COUNT
CURLINFO_STRING 21 + constant CURLINFO_PRIVATE
CURLINFO_LONG   22 + constant CURLINFO_HTTP_CONNECTCODE
CURLINFO_LONG   23 + constant CURLINFO_HTTPAUTH_AVAIL
CURLINFO_LONG   24 + constant CURLINFO_PROXYAUTH_AVAIL
CURLINFO_LONG   25 + constant CURLINFO_OS_ERRNO
CURLINFO_LONG   26 + constant CURLINFO_NUM_CONNECTS
CURLINFO_SLIST  27 + constant CURLINFO_SSL_ENGINES
CURLINFO_SLIST  28 + constant CURLINFO_COOKIELIST
CURLINFO_LONG   29 + constant CURLINFO_LASTSOCKET
CURLINFO_STRING 30 + constant CURLINFO_FTP_ENTRY_PATH
CURLINFO_STRING 31 + constant CURLINFO_REDIRECT_URL
CURLINFO_STRING 32 + constant CURLINFO_PRIMARY_IP
CURLINFO_DOUBLE 33 + constant CURLINFO_APPCONNECT_TIME
CURLINFO_SLIST  34 + constant CURLINFO_CERTINFO
CURLINFO_LONG   35 + constant CURLINFO_CONDITION_UNMET
CURLINFO_STRING 36 + constant CURLINFO_RTSP_SESSION_ID
CURLINFO_LONG   37 + constant CURLINFO_RTSP_CLIENT_CSEQ
CURLINFO_LONG   38 + constant CURLINFO_RTSP_SERVER_CSEQ
CURLINFO_LONG   39 + constant CURLINFO_RTSP_CSEQ_RECV
CURLINFO_LONG   40 + constant CURLINFO_PRIMARY_PORT
CURLINFO_STRING 41 + constant CURLINFO_LOCAL_IP
CURLINFO_LONG   42 + constant CURLINFO_LOCAL_PORT
  \ Fill in new entries below here!
42 constant CURLINFO_LASTONE

\ CURLINFO_RESPONSE_CODE is the new name for the option previously
\ known as CURLINFO_HTTP_CODE
CURLINFO_RESPONSE_CODE constant CURLINFO_HTTP_CODE

0 constant CURLCLOSEPOLICY_NONE \ first, never use this
1 constant CURLCLOSEPOLICY_OLDEST
2 constant CURLCLOSEPOLICY_LEAST_RECENTLY_USED
3 constant CURLCLOSEPOLICY_LEAST_TRAFFIC
4 constant CURLCLOSEPOLICY_SLOWEST
5 constant CURLCLOSEPOLICY_CALLBACK
6 constant CURLCLOSEPOLICY_LAST \ last, never use this

1 0 lshift constant CURL_GLOBAL_SSL
1 1 lshift constant CURL_GLOBAL_WIN32
CURL_GLOBAL_SSL CURL_GLOBAL_WIN32 or constant CURL_GLOBAL_ALL
0 constant CURL_GLOBAL_NOTHING
CURL_GLOBAL_ALL constant CURL_GLOBAL_DEFAULT


\ ****************************************************************************
\ * Setup defines, protos etc for the sharing stuff.

\ Different data locks for a single share
0 constant CURL_LOCK_DATA_NONE
\ CURL_LOCK_DATA_SHARE is used internally to say that
\ the locking is just made to change the internal state of the share
\ itself.
1 constant CURL_LOCK_DATA_SHARE
2 constant CURL_LOCK_DATA_COOKIE
3 constant CURL_LOCK_DATA_DNS
4 constant CURL_LOCK_DATA_SSL_SESSION
5 constant CURL_LOCK_DATA_CONNECT
6 constant CURL_LOCK_DATA_LAST

\ Different lock access types
0 constant CURL_LOCK_ACCESS_NONE	\ unspecified action
1 constant CURL_LOCK_ACCESS_SHARED	\ for read perhaps
2 constant CURL_LOCK_ACCESS_SINGLE	\ for write perhaps
3 constant CURL_LOCK_ACCESS_LAST	\ never use

((
typedef void (*curl_lock_function)(
  CURL *handle, curl_lock_data data, curl_lock_access locktype, void *userptr
);
typedef void (*curl_unlock_function)(
  CURL *handle, curl_lock_data data, void *userptr);
))

0 constant CURLSHE_OK		\ all is fine
1 constant CURLSHE_BAD_OPTION	\ 1
2 constant CURLSHE_IN_USE	\ 2
3 constant CURLSHE_INVALID	\ 3
4 constant CURLSHE_NOMEM	\ 4 out of memory
5 constant CURLSHE_NOT_BUILT_IN	\ 5 feature not present in lib
6 constant CURLSHE_LAST		\ never use

0 constant CURLSHOPT_NONE	\ don't use
1 constant CURLSHOPT_SHARE	\ specify a data type to share
2 constant CURLSHOPT_UNSHARE	\ specify which data type to stop sharing
3 constant CURLSHOPT_LOCKFUNC	\ pass in a 'curl_lock_function' pointer
4 constant CURLSHOPT_UNLOCKFUNC	\ pass in a 'curl_unlock_function' pointer
5 constant CURLSHOPT_USERDATA	\ pass in a user data pointer used in the lock/unlock
                                \ callback functions
6 constant CURLSHOPT_LAST  \ never use

Extern: void * "C" curl_share_init( void );
Extern: int "C" curl_share_setopt( void *, int option, ... );
Extern: int "C" curl_share_cleanup( CURLSH * );

\ ***************************************************************************
\ Structures for querying information about the curl library at runtime.

0 constant CURLVERSION_FIRST
1 constant CURLVERSION_SECOND
2 constant CURLVERSION_THIRD
3 constant CURLVERSION_FOURTH
4 constant CURLVERSION_LAST	\ never actually use this

\ The 'CURLVERSION_NOW' is the symbolic name meant to be used by
\ basically all programs ever that want to get version information. It is
\ meant to be a built-in version number for what kind of struct the caller
\ expects. If the struct ever changes, we redefine the NOW to another enum
\ from above.
CURLVERSION_FOURTH constant CURLVERSION_NOW

((
typedef struct {
  CURLversion age;          /* age of the returned struct */
  const char *version;      /* LIBCURL_VERSION */
  unsigned int version_num; /* LIBCURL_VERSION_NUM */
  const char *host;         /* OS/host/cpu/machine when configured */
  int features;             /* bitmask, see defines below */
  const char *ssl_version;  /* human readable string */
  long ssl_version_num;     /* not used anymore, always 0 */
  const char *libz_version; /* human readable string */
  /* protocols is terminated by an entry with a NULL protoname */
  const char * const *protocols;

  /* The fields below this were added in CURLVERSION_SECOND */
  const char *ares;
  int ares_num;

  /* This field was added in CURLVERSION_THIRD */
  const char *libidn;

  /* These field were added in CURLVERSION_FOURTH */

  /* Same as '_libiconv_version' if built with HAVE_ICONV */
  int iconv_ver_num;

  const char *libssh_version; /* human readable string */

} curl_version_info_data;
))

1 0 lshift constant CURL_VERSION_IPV6		\ IPv6-enabled
1 1 lshift constant CURL_VERSION_KERBEROS4	\ kerberos auth is supported
1 2 lshift constant CURL_VERSION_SSL		\ SSL options are present
1 3 lshift constant CURL_VERSION_LIBZ		\ libz features are present
1 4 lshift constant CURL_VERSION_NTLM		\ NTLM auth is supported
1 5 lshift constant CURL_VERSION_GSSNEGOTIATE	\ Negotiate auth support
1 6 lshift constant CURL_VERSION_DEBUG		\ built with debug capabilities
1 7 lshift constant CURL_VERSION_ASYNCHDNS	\ asynchronous dns resolves
1 8 lshift constant CURL_VERSION_SPNEGO		\ SPNEGO auth
1 9 lshift constant CURL_VERSION_LARGEFILE	\ supports files bigger than 2GB
1 10 lshift constant CURL_VERSION_IDN		\ International Domain Names support
1 11 lshift constant CURL_VERSION_SSPI		\ SSPI is supported
1 12 lshift constant CURL_VERSION_CONV		\ character conversions supported
1 13 lshift constant CURL_VERSION_CURLDEBUG	\ debug memory tracking supported
1 14 lshift constant CURL_VERSION_TLSAUTH_SRP	\ TLS-SRP auth is supported
1 15 lshift constant CURL_VERSION_NTLM_WB	\ NTLM delegating to winbind helper

 /*
 * NAME curl_version_info()
 *
 * DESCRIPTION
 *
 * This function returns a pointer to a static copy of the version info
 * struct. See above.
 */
Extern: void * "C" curl_version_info( int CURLversion );

/*
 * NAME curl_easy_strerror()
 *
 * DESCRIPTION
 *
 * The curl_easy_strerror function may be used to turn a CURLcode value
 * into the equivalent human readable error string.  This is useful
 * for printing meaningful error messages.
 */
Extern: char * "C" curl_easy_strerror( int CURLcode );

/*
 * NAME curl_share_strerror()
 *
 * DESCRIPTION
 *
 * The curl_share_strerror function may be used to turn a CURLSHcode value
 * into the equivalent human readable error string.  This is useful
 * for printing meaningful error messages.
 */
Extern: const char * "C" curl_share_strerror( int CURLSHcode );

/*
 * NAME curl_easy_pause()
 *
 * DESCRIPTION
 *
 * The curl_easy_pause function pauses or unpauses transfers. Select the new
 * state by setting the bitmask, use the convenience defines below.
 *
 */
Extern: int curl_easy_pause( void * handle, int bitmask );

1 constant CURLPAUSE_RECV
0 constant CURLPAUSE_RECV_CONT

4 constant CURLPAUSE_SEND
0 constant CURLPAUSE_SEND_CONT

CURLPAUSE_RECV CURLPAUSE_SEND or constant CURLPAUSE_ALL
CURLPAUSE_RECV_CONT CURLPAUSE_SEND_CONT or constant CURLPAUSE_CONT


\ ======
\ *> ###
\ ======

decimal
