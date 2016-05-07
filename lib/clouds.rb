require 'clouds/version.rb'

require 'aws-sdk-v1'

require 'inifile'
require 'fileutils'
require 'yaml'

def configure(profile=nil)
  if profile.nil? && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
    @aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
    @aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    @aws_session_token = ENV['AWS_SECURITY_TOKEN']
    @region = ENV['AWS_DEFAULT_REGION'] || 'us-east-1'
  else
    profile = profile || ENV['AWS_DEFAULT_PROFILE']
    aws_credentials_file = File.join(File.expand_path('~'), '.aws', 'credentials')

    if profile.nil?
      profile = "default"
      puts "Using the default profile"
    else
      puts "Using the profile '#{profile}'"
    end
    aws_config = IniFile.load(aws_credentials_file)[profile]

    @aws_access_key_id = aws_config['aws_access_key_id']
    @aws_secret_access_key = aws_config['aws_secret_access_key']
    @region = aws_config['region']
  end

  proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']

  AWS.config({:access_key_id => @aws_access_key_id,
              :secret_access_key => @aws_secret_access_key,
              :session_token => @aws_session_token,
              :region => @region,
              :proxy_uri => proxy,
  })

  @cfn = AWS::CloudFormation.new
end

def write_file(file_name, content, force)
  puts "Creating #{file_name}"
  if File.exist?(file_name) and force == false
    raise 'The file already exists, use --force to override'
  end
  File.open(file_name, 'w')  {|f| f.write(content)}
  puts "Created #{file_name}"
end

def read_file(file_name)
  begin
    File.open(file_name,'rb').read
  rescue => e
    puts e
  end
end

def get_stack_directory(stack_name)
  File.join(File.expand_path('.'),'stacks', stack_name)
end

def create_stack_directory(stack_name)
  FileUtils.mkdir_p(get_stack_directory(stack_name))
end


def get_template_path(stack_name)
  File.join(get_stack_directory(stack_name), 'template.json')
end

def get_parameters_path(stack_name)
  File.join(get_stack_directory(stack_name), 'parameters.yaml')
end

def list_stacks()
  configure()
  max_stack_length = 0
  stacks = Hash.new()

  local_stacks = list_local_stacks()
  local_stacks.each do |s|
    max_stack_length = s.length if s.length > max_stack_length
    stacks[s] = 'LOCAL-ONLY'
  end

  begin
    @cfn.stacks.each do |stack|
      stacks[stack.name] = stack.status
      max_stack_length = stack.name.length if stack.name.length > max_stack_length
    end
  rescue => e
    puts e
  end
  puts 'Stack list and stack status:'
  stacks.keys.sort.each do |key|
    printf("%#{max_stack_length}s %s\n",key, stacks[key])
  end
end

def list_local_stacks()
  list = []
  return [] unless File.directory?('stacks')
  Dir.foreach('stacks') do |item|
    next if item == '.' or item == '..'
    list << item
  end
list
end

def dump_stacks(stack_list, force=false)
  stack_list.each do |stack_name|
    configure()
    begin
      stack = @cfn.stacks[stack_name]
      puts "Dumping stack #{stack.name}"

      template_content = stack.template
      parameters = stack.parameters
      create_stack_directory(stack_name)
      write_file(get_template_path(stack_name), template_content, force)
      write_file(get_parameters_path(stack_name), parameters.to_yaml, force)
    rescue => e
      puts "dump failed: #{e}"
    end
  end
end

def dump_all_stacks(force=false)
  configure()
  begin
    @cfn.stacks.each do |stack|
      dump_stacks([stack.name],force)
    end
  rescue => e
    puts e
  end
end

def update_stack(stack_name, create_if_missing=false, synchronous=false, outputs=false)
  configure
  stack = nil

  template_content = read_file(get_template_path(stack_name))
  parameters_content = read_file(get_parameters_path(stack_name))

  parameters_hash = {}

  begin
    yaml_hash = YAML.load(parameters_content)
  rescue => e
    puts e
    raise e
  end

  yaml_hash.each do |k, v|
    v = v.join(",") if v.is_a?(Array)
    parameters_hash[k] = v
  end

  p parameters_hash

  raise 'Empty stack template' if template_content.nil? || template_content.empty?

  template_validation = @cfn.validate_template(template_content)
  raise template_validation[:message] unless template_validation[:message].nil?

  begin
    if @cfn.stacks[stack_name].exists?
      puts "# Updating stack #{stack_name}"
      stack = @cfn.stacks[stack_name]
      stack_capabilities = stack.capabilities
      stack.update(:template => template_content,
                   :parameters => parameters_hash,
                   :capabilities => stack_capabilities)
      status = wait_until_status(stack, %w( CREATE_IN_PROGRESS UPDATE_IN_PROGRESS )) if synchronous
    elsif create_if_missing
      puts "# Creating stack #{stack_name}"
      stack = @cfn.stacks.create(stack_name,
                                 template_content,
                                 { :parameters => parameters_hash,
                                   :capabilities => ['CAPABILITY_IAM']})
      status = wait_until_status(stack, %w( CREATE_IN_PROGRESS UPDATE_IN_PROGRESS )) if synchronous
    else
      puts "Skipping stack #{stack_name} since it's not defined in this AWS account, if the stack exists locally you might use the -c flag"
    end
    if ! stack.nil? && %w( UPDATE_COMPLETE CREATE_COMPLETE ).include?(status)
      estimated_cost = stack.estimate_template_cost
      puts "# Estimated costs for the stack #{stack_name} is #{estimated_cost}"

      print_stack_outputs(stack) if outputs
    end
  rescue => e
    puts e
  end

  %w( UPDATE_COMPLETE CREATE_COMPLETE ).include? status
end

def wait_until_status(stack, status_arr)
  while true
    begin
      status = stack.status
      printf("# %s : %s\n", Time.now.strftime('%Y-%m-%d %H:%M:%S'), status)
      return status unless status_arr.include? status
      sleep 5
    rescue => e
      raise "Cannot retrieve stack status: #{e}"
    end
  end
end

def print_stack_outputs(stack)
  puts '# ---'
  puts "# Outputs from #{stack.name}"
  stack.outputs.each do |o|
    puts "#{o.key}: #{o.value}"
  end
  puts '# ---'
end

def update_stacks(stack_list, create_if_missing=false, synchronous=false, outputs=false)
  stack_list.each do |stack|
    res = update_stack(stack, create_if_missing, synchronous, outputs)
    return res unless res
  end

  true
end

def update_all_stacks(create_if_missing=false, synchronous=false, outputs=false)
  stacks = Dir.glob('stacks/*').map { |d| File.basename d }
  update_stacks(stacks, create_if_missing, synchronous, outputs)
end

def clone_stack(stack, new_stack, force=false, commit=false)
  if File.exist?(get_stack_directory(new_stack)) and force == false
    raise 'The stack already exists, use --force to override'
  elsif force == true
    FileUtils.rm_rf(get_stack_directory(new_stack))
  end
  FileUtils.cp_r(get_stack_directory(stack), get_stack_directory(new_stack))
  if commit
    puts 'Committing changes to AWS'
    update_stack(new_stack, true)
  else
    puts 'Only copied the stack template and parameters locally, use the --commit flag in order to do commit the changes to AWS'
  end
end

def delete_stack(stack_name)
  configure()
  if @cfn.stacks[stack_name].exists?
    puts "Deleting stack #{stack_name}"
    @cfn.stacks[stack_name].delete
  else
    puts "Stack #{stack_name} does not exist, nothing to delete here..."
  end
end

