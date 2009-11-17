module GridFSRackDAV
  class GridFSModel
    include Mongo
    include GridFS

    attr_reader :path, :collection
    attr_reader :root

    def initialize(resource_path, options)
      @connection = options[:connection]
      @collection = @connection.collection('fs.files')
      self.root = options[:root]
      self.path = resource_path
    end
    def path=(path)
      @path = ('/' + path).gsub(/\/+/, '/').strip
      @path = self.root + @path if @path[0..root.length-1] != root
    end
    def root=(raw_root)
      raw_root = '' if raw_root.nil?
      raw_root = "/" + raw_root if raw_root != "/"
      raw_root = raw_root[0..-2] if raw_root[-1,1] == '/'
      @root = raw_root
    end
    def path_without_root
      @path[root.length..-1]
    end
    def collection?
      if item.nil?
        path[-1,1] == '/'
      else
        item['filename'][-1,1] == '/'
      end
    end
    def name
      item.nil? ? path : item['filename']
    end
    def item
      @item ||= @collection.find_one({:filename => /^(#{Regexp.escape(self.path)})\/?$/})
      if @item.nil? and path == (self.root + '/').gsub(/\/+/, '/')
        @item = self.write
      end
      @item
    end

    def children_names
      children_names = []
      if self.collection? && !item.nil?
        @collection.find({:filename => /^(#{Regexp.escape(self.item['filename'])})[^\/]+(\/?)$/}).each do |r|
          children_names << r['filename'] if r['filename'] != self.path
        end
        children_names
      end
      children_names
    end

    def children
      if self.collection? && !item.nil?
        @collection.find({:filename => /^(#{Regexp.escape(self.item['filename'])})[^\/]+(\/?)$/}).map do |c|
          self.class.new(c['filename'], root)
        end
      end
    end

    def get_file_contents
      GridStore.open(@connection, self.path, 'r') { |f| f.read }
    end
    def write(file_contents = '__DIR__')
      filename = ('/' + self.path).gsub(/\/+/, '/')
      GridStore.open(@connection, filename, 'w') do |f|
        f.content_type = MIME::Types.type_for(filename).first.to_s
        f.metadata = {
          :ctime => Time.now.to_i,
          :mtime => Time.now.to_i
        }
        f.write(file_contents)
      end
      @item = nil
      item
    end
    def save
      @collection.save(self.item)
    end
    def delete
      if collection?
        @collection.remove({:filename => /^(#{Regexp.escape(item['filename'])}).*/})
      else
        @collection.remove({:filename => /^(#{Regexp.escape(item['filename'])})\/?$/})
      end
    end

  end
end