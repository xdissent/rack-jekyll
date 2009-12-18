require "rack"
require "rack/request"
require "rack/response"

module Rack
  class Jekyll
    
    def initialize(opts = {})
      @path = opts[:path].nil? ? "_site" : opts[:path]
      @files = Dir[@path + "/**/*"].inspect
      if Dir[@path + "/**/*"].empty?
        system("jekyll #{@path}")
      end
    end
    
    def call(env)
      request = Request.new(env)
      path_info = request.path_info
      if @files.include?(path_info)
        if path_info =~ /(\/?)$/
          if path_info !~ /\.(css|js|jpe?g|gif|png|mov|mp3)$/i
            path_info += $1.nil? ? "/index.html" : "index.html"
          end
        end
        mime = mime(path_info)
        body = content(::File.expand_path(@path + path_info))
        [200, {"Content-Type" => mime, "Content-length" => body.length.to_s}, [body]]
      else
        status, body, path_info = ::File.exist? ? [200,content(@path+"/404.html"),"404.html"] : [404,"Not found","404,html"]
        mime = mime(path_info)
        [status, {"Content-Type" => mime, "Content-Type" => body.length.to_s}, [body]]
      end
    end
    def content(file)
      ::File.read(file)
    end
    def mime(path_info)
      ext = $1 if path_info =~ /(\.\S+)$/
      Mime.mime_type((ext.nil? ? ".html" : ext))
    end
  end
end
