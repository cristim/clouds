# clouds

This is a simple tool that aims to ease the handling of [AWS CloudFormation](https://aws.amazon.com/cloudformation/) stacks, following the [infrastructure as code](http://sdarchitect.wordpress.com/2012/12/13/infrastructure-as-code/) philosophy in ways that are not possible with the AWS console. Even though you can achieve pretty much the same using the AWS command line tools, `clouds` aims to be much easier to use, cleaner and more specialized in handling CloudFormation stacks as code.

## Features
- Upload templates and parameters from the current directory into AWS with a single intuitive command. They need to be located in stacks/stack_name/{template.json,parameters.yaml}
- List existing stacks defined in AWS and also those only defined locally
- Dump one or all of the stacks from your currently selected AWS account into the current directory (preferably stored in a version control system) under the 'stacks' directory, including both the template JSON code and the parameters that were used for launching it, which will then be saved in a human-friendly YAML file.
- Perform updates on the AWS stacks once you modified the dumped data (template or parameters)
- Validate templates for JSON correctness when uploading or updating a stack. The error messages should help you debug syntax errors.
- Clone existing stacks to create new ones. It defaults to local clone, which then needs another update call to get in effect. This is an easy way to migrate infrastructure code and later to promote changes between environments, and can also be used easily with projects running in different AWS accounts, especially if using a simple AWS profile switcher shell alias like implemented on oh-my-zsh.
- Perform cost calculations when creating a new stack.
- Delete existing stacks with a simple command
- For authentication it can use AWS account credentials defined using either the AWS_ACCESS_KEY_ID&AWS_SECRET_ACCESS_KEY combination, or the AWS_DEFAULT_PROFILE environment variables
- Able to use temporary credentials, if the AWS_SECURITY_TOKEN variable is defined in the environment.

## Installation

    gem install clouds

or using a [bundler](http://bundler.io/) Gemfile:

    gem 'clouds'

Note: On systems running Ruby 1.8.x such as RHEL5 and clones, you need to be aware of the incompatibility between the more recent versions of `nokogiri`(a dependency of the `aws-sdk`, that `clouds` indirectly depends on) and Ruby 1.8. This is pretty well-documented [here](http://ruby.awsblog.com/post/Tx2T9MFQJK7U74N/AWS-SDK-for-Ruby-and-Nokogiri). **You will need to manually install the latest compatible version of nokogiri and the AWS SDK for Ruby as documented on that page.**

## Running
Execute this in your shell:

    clouds -h

In order to do real stuff you need a profile to be defined in .aws/config for the aws command line tool, and to have it referenced by the AWS_DEFAULT_PROFILE environment variable. The AWS_ACCESS_KEY_ID&AWS_SECRET_ACCESS_KEY combination are also supported. You can also use temporary credentials, if the AWS_SECURITY_TOKEN variable is properly defined in the environment when using the temporary access key and secret.

    export AWS_DEFAULT_PROFILE=my_aws_profile
or

    export AWS_ACCESS_KEY_ID=my_key_id
    export AWS_SECRET_ACCESS_KEY=my_key_secret

The oh-my-zsh users can also use the `asp` command implemented in the [AWS zsh plugin](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins#aws), which makes it very easy to switch between different profiles defined in .aws/config.

## Use cases

Dump all the stacks from your account into the current directory

    clouds dump --all

Once you edit a stack source code, this command would update it on AWS

    clouds update stack_name

Clone a stack (locally only, so you can perform some changes)

    clouds clone stack new_stack

Upload the cloned stack to AWS CloudFormation

    clouds update new_stack -c

Delete the new stack (needs --force)

    clouds delete new_stack


## Development

### Build requirements
- Ruby, rubygems and rake (some might already be there on Ruby > 1.9)
- Development headers for libxml2 and libxslt (-devel packages)
- Bundler

    gem install bundler

### Install dependencies
Only in case you didn't do it before

    bundle install

### Running for development

    bundle exec bin/clouds

### Updating the installed gem

    rake repackage
    sudo gem install pkg/clouds-0.1.0.gem

### Build instructions

Simply run (once you have the stated requirements satisfied)

    rake package

### Installing your own gem

    sudo gem install pkg/clouds-0.1.0.gem

