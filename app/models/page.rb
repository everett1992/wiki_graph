class Page < Neo4j::Rails::Model
  property :id
  property :title
  property :namespace
  property :restrictions
  property :counter
  property :is_redirect
  property :is_new
  property :random
  property :touched
  property :latest
  property :length
  property :no_title_convert
end
