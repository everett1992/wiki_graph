DUMP_DIR = Rails.root.join('lib','assets')


desc "Download wiki dumps and parse them"
task :wiki, [:wiki] => 'wiki:all'

namespace :wiki do
  task :all, [:wiki] => [:get, :parse]

  desc "Download wiki page and page links database dumps to /lib/assets"
  task :get, :wiki do |t, args|
    indent "Downloading dumps"
    sh "#{Rails.root.join('lib', "get_wiki").to_s} #{args[:wiki]}"
    indent "Done"
  end


  desc "Parse all dumps"
  task :parse, [:wiki] => 'parse:all'

  namespace :parse do
    task :all, [:wiki] => [:pages, :pagelinks]

    desc "Read wiki page dumps from lib/assests into the database"
    task :pages, [:wiki] => :environment do |t, args|
      parse_dumps('page', args[:wiki]) do |obj|
        page = Pages.create_from_dump(obj)
      end
      indent = "Created #{Pages.count} pages"
    end

    desc "Read wiki pagelink dumps from lib/assests into the database"
    task :pagelinks, [:wiki] => :environment do |t, args|
      errors = 0
      parse_dumps('pagelinks', args[:wiki]) do |from_id, namespace, to_title|
        from = Pages.find(:page_id => from_id)
        to = Pages.find(:title => to_title)
        if to.nil? || from.nil?
          errors = errors.succ
        else
          puts "#{from.title} to #{to.title}"
          from.links << to
          to.links << from
          from.save
          to.save
        end
      end


      link_count = 0
      Pages.all.each do |page|
        link_count += page.links.count
        puts "#{page.page_id} - #{page.title}: #{page.links.count}"
        page.save
      end
      indent "Created #{link_count} with #{errors} errors"
    end
  end
end

def indent *args
  print ":: "
  puts args
end

def parse_dumps(dump, wiki_match, &block)
  wiki_match ||= /\w+/
  DUMP_DIR.entries.each do |file|
    file, wiki = *(file.to_s.match(Regexp.new "(#{wiki_match})-#{dump}.sql"))
    if file
      indent "Parsing #{wiki} #{dump.pluralize} from #{file}"
      each_value(DUMP_DIR.join(file), &block)
    end
  end
end

def each_value(filename)
  f = File.open(filename)
  num_read = 0

  begin                               # read file until line starting with INSERT INTO
    line = f.gets
  end until line.match /^INSERT INTO/

  begin
    line = line.match(/\(.*\)[,;]/)[0]  # ignore begining of line until (...) object
    begin
      yield line[1..-3].split(',').map { |e| e.match(/^['"].*['"]$/) ?  e[1..-2] : e.to_f }
      num_read = num_read.succ

      line = f.gets.chomp
    end while(line[0] == '(')          # until next insert block, or end of file
  end while  line.match /^INSERT INTO/ # Until line doesn't start with (...

  f.close
end
