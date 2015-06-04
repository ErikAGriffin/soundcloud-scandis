require 'net/http'
require 'multi_json'


class Hunter

  attr_reader :target

  def initialize
    super
    @client_id = ENV['SC_CLIENT_ID']
    @target
  end

  def resolve_user(url)
    res = get_json_from('http://api.soundcloud.com/resolve?url='+url+'&client_id='+@client_id)
    get_json_from(res[:location])
  end

  def search_scandis_of(users)
    # places = /oslo|bergen|asker|norway|trondheim|norge|stockholm|copenhagen|sweden|denmark/i
    places = /oslo|bergen|asker|norway|trondheim|norge/i
    users.select{|user| user[:city].to_s + user[:country].to_s =~ places }
  end

  def set_target(id)
    raise "must give user id as integer!\nUse resolve_target to pass url" if !id.is_a? Integer
    @target = id.to_s
  end

  def resolve_target(url)
    user = resolve_user(url)
    set_target(user[:id])
  end

  def get_target_followings
    result = []
    url = get_subresource('users',@target,'followings')
    res = get_json_from(url+'&limit=200&linked_partitioning=1')
    res[:collection].each {|user| result<<user}
    while res[:next_href]
      res = get_json_from(res[:next_href])
      res[:collection].each {|user| result<<user}
    end
    result
  end

  private

  def get_subresource(resource,id,subresource)
    'http://api.soundcloud.com/'+resource+'/'+id+'/'+subresource+'?client_id='+@client_id
  end

  def get_resource(resource,id)
    'http://api.soundcloud.com/'+resource+'/'+id+'?client_id='+@client_id
  end

  def get_json_from(url)
    uri = URI(url)
    MultiJson.load(Net::HTTP.get(uri), symbolize_keys: true)
  end

end
