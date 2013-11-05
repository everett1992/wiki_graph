class Pages < Neo4j::Rails::Model
  include Neo4j::NodeMixin

  has_n(:links).to(Pages)
  has_one(:wiki).to(Wikis)

  property :page_id
  property :namespace,        :type => Fixnum
  property :title,            :type => String
  property :restrictions,     :type => String
  property :counter,          :type => Fixnum
  property :is_redirect,      :type => Fixnum
  property :is_new,           :type => Fixnum
  property :random,           :type => Float
  property :touched,          :type => String
  property :latest,           :type => Fixnum
  property :length,           :type => Fixnum
  property :no_title_convert, :type => Fixnum

  def self.total_links
    Pages.all.reduce(0) { |c, p| c += p.links.count }
  end

  def self.average_links
    Pages.total_links / Pages.count.to_f
  end
end
