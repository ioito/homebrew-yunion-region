class YunionRegionAT31 < Formula
  desc "Yunion Cloud Region Controller V2 Service"
  homepage "https://github.com/yunionio/onecloud.git"
  url "https://github.com/yunionio/onecloud.git",
    :tag      => "release/3.1"
  version_scheme 1
  head "https://github.com/yunionio/onecloud.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    (buildpath/"src/yunion.io/x/onecloud").install buildpath.children
    cd buildpath/"src/yunion.io/x/onecloud" do
      system "make", "cmd/region"
      bin.install "_output/bin/region"
      prefix.install_metafiles
    end

    (buildpath/"region.conf").write region_conf
    etc.install "region.conf"
  end

  def post_install
    (var/"log/region").mkpath
  end

  def region_conf; <<~EOS
  region = 'Yunion'
  address = '127.0.0.1'
  port = 8888
  auth_uri = 'https://127.0.0.1:35357/v3'
  admin_user = 'regionadmin'
  admin_password = 'RvzdKVMTNIZrSyap'
  admin_tenant_name = 'system'
  sql_connection = 'mysql+pymysql://yunioncloud:uFhm1KNVdBmMdoRM@10.127.10.228:3306/yunioncloud?charset=utf8'
  dns_server = '114.114.114.114'
  dns_domain = 'yunion.local'
  dns_resolvers = ['114.114.114.114']
  scheduler_port = 8897
  ignore_nonrunning_guests = True
  port_v2 = 8889
  log_level = 'debug'
  auto_sync_table = True
  enable_ssl = false
  ssl_certfile = '/opt/yunionsetup/config/keys/region/region-full.crt'
  ssl_keyfile = '/opt/yunionsetup/config/keys/region/region.key'
  ssl_ca_certs = '/opt/yunionsetup/config/keys/region/ca.crt'
  rbac_debug = false
  EOS
  end

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>RunAtLoad</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/region</string>
        <string>--conf</string>
        <string>#{etc}/region.conf</string>
        <string>--auto-sync-table</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/region/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/region/output.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "false"
  end
end
