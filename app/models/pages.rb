class Pages < Neo4j::Rails::Model
  include Neo4j::NodeMixin
  has_n(:links).to(Pages)

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


  def self.create_from_dump(obj)
    # TODO: I wonder if there is a way to compine these calls
    page = {}

    # order of this array is important, it corresponds to the data in obj
    attrs = [:page_id, :namespace, :title, :restrictions, :counter, :is_redirect,
             :is_new, :random, :touched, :latest, :length, :no_title_convert]

    attrs.each_index { |i| page[attrs[i]] = obj[i] }
    page = Pages.create(page)
    return page
  end
end
