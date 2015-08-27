#coding: utf-8

Plugin.create(:"mikutter-datasource-netcat") {
  require "yaml"
  require "json"

  def to_user(hash)
    tmp = hash.clone

    if !hash[:profile_image_url]
      tmp[:profile_image_url] = Skin.get("icon.png")
    end

    User.new({:id => 3939}.merge(tmp))
  end

  def to_message(hash)
    msg = Message.new(:message => hash[:message], :system => true)

    if hash[:user]
      msg[:user] = to_user(hash[:user])
    end

    msg
  end

  def get_hash(str)
    internal_str = str.force_encoding("utf-8")

    result = begin
      YAML.load(internal_str).symbolize
    rescue => e
      begin
        JSON.load(internal_str).symbolize
      rescue => e2
        {:message => internal_str}
      end
    end

    result
  end

  def accept_thread
    Thread.new {
      server = TCPServer.new(39390)

      loop {
        sock = server.accept

        begin
          raw = sock.read
          hash = get_hash(raw)

          Plugin.call(:extract_receive_message, :netcat, [to_message(hash)])
        rescue => e
          puts e
          puts e.backtrace
        ensure
          sock.close
        end
      }
    }
  end

  on_boot { |service|
    if service == Service.primary
      accept_thread      
    end
  }

  filter_extract_datasources { |datasources|
    datasources[:netcat] = "TCP:39390"

    [datasources]
  }
}
