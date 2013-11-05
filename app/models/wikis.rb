class Wikis < Neo4j::Rails::Model


  include Neo4j::NodeMixin

  has_n(:pages).to(Pages)

  property :name


  def get_pages
    dump = Wikis.download_dump(self.name, 'page')
    Wikis.parse_dump(dump) do |obj|
      fiber = Fiber.new { obj.each { |elem| Fiber.yield elem } }
      self.pages.create(
        wiki: self,
        page_id: fiber.resume,
        namespace: fiber.resume,
        title: fiber.resume,
        restrictions: fiber.resume,
        counter: fiber.resume,
        is_redirect: fiber.resume,
        is_new: fiber.resume,
        random: fiber.resume,
        touched: fiber.resume,
        latest: fiber.resume,
        length: fiber.resume,
        no_title_convert: fiber.resume)
    end
  end

  def get_page_links
    dump = Wikis.download_dump(self.name, 'pagelinks')
    Wikis.parse_dump(dump) do |from_id, namespace, to_title|
      from = Pages.find(:page_id => from_id, wiki: self)
      to = Pages.find(:title => to_title, wiki: self)
      unless to.nil? || from.nil?
        from.links << to
        from.save
        p from.errors.to_a if from.errors.any?
      end
    end
  end

  # Don't judge me
  def self.download_dump(wiki, dump)
    url = "http://dumps.wikimedia.org/#{wiki}/latest/#{wiki}-latest-#{dump}.sql.gz"
    tmp = Rails.root.join('tmp', "#{wiki}-#{dump}.sql")
    file = Rails.root.join('lib','assets', "#{wiki}-#{dump}.sql")

    %x[curl -# #{url} | gunzip -c | sed -e 's/),(/),\\n(/g' > #{tmp} && mv #{tmp} #{file}]
    raise "Failed to download #{url}" if $?.exitstatus != 0

    return file
  end

  def self.parse_dump(filename, &block)
    f = File.open(filename)

    begin                               # read file until line starting with INSERT INTO
      line = f.gets
    end until line.match /^INSERT INTO/

    begin
      line = line.match(/\(.*\)[,;]/)[0]  # ignore begining of line until (...) object
      begin
        yield line[1..-3].split(',').map { |e| e.match(/^['"].*['"]$/) ?  e[1..-2] : e.to_f }
        line = f.gets.chomp
      end while(line[0] == '(')          # until next insert block, or end of file
    end while  line.match /^INSERT INTO/ # Until line doesn't start with (...

    f.close
  end
end
