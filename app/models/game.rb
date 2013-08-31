class Game < ActiveRecord::Base
  validates_presence_of :user_one, :user_two

  after_create :create_repo

  def repo_name
    "#{user_one}-vs-#{user_two}"
  end

  def full_repo_name
    "code-tennis/#{repo_name}"
  end
  
  def repo_url
    "https://github.com/#{full_repo_name}"
  end

  def pages_url
    "http://code-tennis.github.io/#{repo_name}/"
  end

  def to_s
    "#{user_one} vs #{user_two}"
  end

  def toggle_collaborator
    users = client.collaborators(full_repo_name).map(&:login)
    if users.include?(user_one)
      client.remove_collaborator(full_repo_name, user_one)
      client.add_collaborator(full_repo_name, user_two)
    else
      client.remove_collaborator(full_repo_name, user_two)
      client.add_collaborator(full_repo_name, user_one)
    end
  end

  def create_repo
    client.create(repo_name, :auto_init => true, :homepage => pages_url)
    change_default_branch
    client.add_collaborator(full_repo_name, user_one)
    add_index_page
    create_hook
  end

  def change_default_branch
    sha = client.commits(full_repo_name).first.sha
    client.create_ref(full_repo_name,"heads/gh-pages", sha) rescue nil
    client.delete_ref(full_repo_name,"heads/master")
  end

  def index_contents
    Base64.strict_encode64(IO.read("lib/index.html"))
  end

  def add_index_page
    client.put("repos/#{full_repo_name}/contents/index.html", 
                :message => 'Adding index.html', 
                :content => Base64.strict_encode64(IO.read("lib/index.html")))
  end

  def client
    @client ||= Octokit::Client.new :login => 'code-tennis', :password => ENV['password']
  end

  def create_hook
    client.create_hook(
      full_repo_name,
      'web',
      {
        :url => 'http://something.com/webhook',
        :content_type => 'json'
      },
      {
        :events => ['push'],
        :active => true
      }
    )
  end
end
