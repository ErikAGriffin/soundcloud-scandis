require 'net/http'
require 'multi_json'


class Hunter

  attr_reader :target

  def initialize
    super
    @client_id = ENV['SC_CLIENT_ID']
    @target
  end

  def prompt_resolve_user
    url = prompt
    resolve_user(url)
  end

  def resolve_user(url)
    res = get_json_from('http://api.soundcloud.com/resolve.json?url='+url+'&client_id='+@client_id)
    get_json_from(res[:location])
  end

  def search_scandis_of(users)
    places = ['oslo','bergen','asker','norway','trondheim','stockholm','copenhagen','sweden','denmark']
    users.inject([]) do |result,user|
      if user[:country]
        places.each {|place| user[:country].downcase.include?(place) ? (result<<user;break) : nil}
        result
      elsif user[:city]
        places.each {|place| user[:city].downcase.include?(place) ? (result<<user;break) : nil }
        result
      else
        result
      end
    end
  end

  def prompt_set_target
    url = prompt
    set_target(url)
  end

  def set_target(url)
    user = resolve_user(url)
    @target = user[:id].to_s
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

  def prompt
    gets.chomp
  end

  def get_json_from(url)
    uri = URI(url)
    MultiJson.load(Net::HTTP.get(uri), symbolize_keys: true)
  end

end
