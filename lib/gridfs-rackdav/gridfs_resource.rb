module GridFSRackDAV
  class GridFSResource < RackDAV::Resource
    attr_reader :gridfs_model
    
    DIR_FILE = "<tr><td class='name'><a href='%s'>%s</a></td><td class='size'>%s</td><td class='type'>%s</td><td class='mtime'>%s</td></tr>"
    
    DIR_PAGE = <<-PAGE
    <html><head>
    <title>%s</title>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <style type='text/css'>
    table { width:100%%; }
    .name { text-align:left; }
    .size, .mtime { text-align:right; }
    .type { width:11em; }
    .mtime { width:15em; }
    </style>
    </head><body>
    <h1>%s</h1>
    <hr />
    <table>
    <tr>
    <th class='name'>Name</th>
    <th class='size'>Size</th>
    <th class='type'>Type</th>
    <th class='mtime'>Last Modified</th>
    </tr>
    %s
    </table>
    <hr />
    </body></html>
    PAGE
    
    
    def initialize(path, options)
      raise 'You must provide MongoDB connection in options[:connection]' if options[:connection].nil?
      raise 'You must provide root of collection in options[:root]' if options[:root].nil?
      super(path, options)
      @gridfs_model = GridFSModel.new(path, options)
    end
    
    # If this is a collection, return the child resources.
    def children
      @gridfs_model.children_names.map { |filename| self.class.new(filename, @options)}
    end

    # Is this resource a collection?
    def collection?
      @gridfs_model.collection?
    end

    # Does this recource exist?
    def exist?
      !@gridfs_model.item.nil?
    end
    
    # Return the creation time.
    def creation_date
      @gridfs_model.item['metadata'] ? Time.at(@gridfs_model.item['metadata']['mtime'].to_i) : Time.now
    end

    # Return the time of last modification.
    def last_modified
      @gridfs_model.item['metadata'] ? Time.at(@gridfs_model.item['metadata']['mtime'].to_i) : Time.now
    end
    
    # Set the time of last modification.
    def last_modified=(time)
      @gridfs_model.item['metadata']['mtime'] = Time.parse(time).to_i
      @gridfs_model.save
    end

    # Return an Etag, an unique hash value for this resource.
    def etag
      Digest::MD5.hexdigest(
        sprintf('%s-%x-%x', @gridfs_model.item['filename'], @gridfs_model.item['length'], @gridfs_model.item['metadata']['mtime'].to_i)
      )
    end

    # Return the resource type.
    #
    # If this is a collection, return
    # REXML::Element.new('D:collection')
    def resource_type
      if @gridfs_model.collection?
        REXML::Element.new('D:collection')
      end
    end

    # Return the mime type of this resource.
    def content_type
      @gridfs_model.item['contentType']
    end

    # Return the size in bytes for this resource.
    def content_length
      @gridfs_model.item['length']
    end

    # HTTP GET request.
    #
    # Write the content of the resource to the response.body.
    # TODO: Write test for get method for collections
    def get(request, response)
      if @gridfs_model.collection?
        files = []
        if @gridfs_model.path != @options[:root] + '/'
          files << DIR_FILE % [@gridfs_model.path_without_root.split('/')[0..-2].join('/') + "/", '../', "", "", ""]
        end
        @gridfs_model.children.each do |f|
          time = Time.at(f.item['metadata']['mtime']).to_s if f.item['metadata'] and f.item['metadata']['mtime']
          files << DIR_FILE % [f.path_without_root, File.basename(f.item['filename']), f.item['length'], f.item['contentType'], time]        
        end
        response.body = DIR_PAGE % [@gridfs_model.path_without_root, @gridfs_model.path_without_root, files.join('')]
        response.body.strip!
        
        response['Content-Type'] = 'text/html'
        response['Content-Length'] = response.body.size.to_s
      else
        response.body = @gridfs_model.get_file_contents
      end
    end

    # HTTP PUT request.
    #
    # Save the content of the request.body.
    def put(request, response)
      write(request.body)
    end
    
    # HTTP POST request.
    #
    # Usually forbidden.
    def post(request, response)
      raise HTTPStatus::Forbidden
    end
    
    # HTTP DELETE request.
    #
    # Delete this resource.
    def delete
      @gridfs_model.delete
    end
    
    # HTTP COPY request.
    #
    # Copy this resource to given destination resource.
    def copy(dest)
      if collection?
        dest.gridfs_model.path = dest.gridfs_model.path + '/'
        dest.make_collection
      else
        dest.write(StringIO.new(@gridfs_model.get_file_contents)) unless @gridfs_model.item.nil?
      end
    end
  
    # HTTP MOVE request.
    #
    # Move this resource to given destination resource.
    def move(dest)
      copy(dest)
      delete
    end
    
    # HTTP MKCOL request.
    #
    # Create this resource as collection.
    def make_collection
      @gridfs_model.path = @gridfs_model.path + '/'
      @gridfs_model.write
    end
    
    # Write to this resource from given IO.
    def write(io)
      file = ''
      while part = io.read(8192)
        file << part
      end
      @gridfs_model.write(file)
    end
    
  end
end
