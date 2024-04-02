set beresp.do_stream = true;

if (req.url.ext == "m3u8") {
    set beresp.ttl = 1s;
}