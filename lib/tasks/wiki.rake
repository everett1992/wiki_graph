DUMP_DIR = Rails.root.join('lib','assets')

namespace :wiki do
  desc "Download simple wiki page and page links database dumps to /lib/assets"
  task :get do
    exec Rails.root.join('lib', 'get_wiki').to_s
  end

  namespace :parse do
    desc "Read wiki page dumps from lib/assests into the database"
    task :pages => :environment do
      parse_dumps('page') do |line|
        page = {}
        attrs = [:id, :namepsace, :title, :restrictions, :counter, :is_redirect,
               :is_new, :random, :touched, :latest, :len, :no_title_convert]

        attrs.each_index { |i| page[attrs[i]] = line[i] }
        Page.create(page)
      end
    end
    task :pagelinks => :environment do
      parse_dumps('pagelinks') do |obj|
        p obj
      end
    end
  end
end

def indent *args
  print ":: "
  puts args
end

def parse_dumps(dump, &block)
  DUMP_DIR.entries.each do |file|
    file, wiki = *(file.to_s.match(/(\w*)-#{dump}.sql/))
    if file
      indent "Parsing #{wiki} #{dump.pluralize} from #{file}"
      each_value(DUMP_DIR.join(file), &block)
    end
  end
end

def each_value(filename)
  f = File.open(filename)
  n = 0

  begin                               # read file until line starting with INSERT INTO
    line = f.gets
  end until line.match /^INSERT INTO/

  begin
    line = line.match(/\(.*\)[,;]/)[0]  # ignore begining of line until (...) object
    begin
      yield line[1..-2].split(',').map { |e| e.match(/^['"].*['"]$/) ?  e[1..-2] : e.to_f }
      n += 1
      line = f.gets
    end while(line[0] == '(')          # until next insert block, or end of file
  end while  line.match /^INSERT INTO/ # Until line doesn't start with (...
  p n

  f.close
end
