output "rtmp_url" {
  description = "OBS Settings -> Stream -> Server"
  value       = "rtmp://${google_compute_instance.ome.network_interface.0.access_config.0.nat_ip}/app"
}

output "hls_js_player" {
  description = "hls.js demo player url"
  value       = "https://hlsjs.video-dev.org/demo/?src=https://${fastly_service_vcl.llhls.name}-${random_id.unique.hex}.global.ssl.fastly.net/app/stream/llhls.m3u8"
}