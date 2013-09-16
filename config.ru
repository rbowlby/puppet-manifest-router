require 'rack'
require 'puppet/util/command_line'

class ManifestRouter

  def initialize(manifest_dir, domain_dir)
    @domain_dir = "#{manifest_dir}/#{domain_dir}"
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.path =~ %r|/catalog/|
      domain = get_domain(request.path)
      domains = get_domains(@domain_dir)
      if domain and domains.include? domain
        ARGV << "--manifest" << "#{@domain_dir}/#{domain}.pp"
      end
    end

    @puppet = Rack::Builder.new do
      $0 = "master"
      #ARGV << "--debug"
      ARGV << "--rack"
      ARGV << "--confdir" << "/etc/puppet"
      ARGV << "--vardir"  << "/var/lib/puppet"
      run Puppet::Util::CommandLine.new.execute
    end
    @puppet.call(env)
  end

  private
  def get_domains(dir)
    Dir.glob("#{dir}/*.pp").collect { |f| f.split('/')[-1].gsub('.pp', '') }
  end

  def get_domain(path)
    path.split('/')[3].split('.')[1..-1].join('.')
  end

end

run ManifestRouter.new("/path/to/node/manifests", "subdir_containing_import_files")
