# clouds

# Discontinued development

This project is no longer being maintained. It was good enough for me so I didn't spend much time improving it afterwards and it never really took off with external contributions.

In the meantime, [@elias5000](https://github.com/elias5000) rewrote it in Python, implementing the same functionality including most of the command-line flags, and enhanced it further with some awesome new features.

His new project is now available [here](https://github.com/elias5000/clouds-aws) and is installable via `pip install clouds-aws`, and I recommend you to to give it a try.

[![Join the chat at https://gitter.im/cristim/clouds](https://badges.gitter.im/cristim/clouds.svg)](https://gitter.im/cristim/clouds?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is a simple tool that aims to ease the handling of [AWS CloudFormation](https://aws.amazon.com/cloudformation/) stacks, following the [infrastructure as code](http://sdarchitect.wordpress.com/2012/12/13/infrastructure-as-code/) philosophy in ways that are not possible with the AWS console. Even though you can achieve pretty much the same things using the AWS command line tools, `clouds` aims to be much easier to use, cleaner and more specialized in handling CloudFormation stacks as ~~code~~ data(IMHO JSON doesn't really qualify to be called 'code', although it's quite close if considering the intrinsics), optimized for use with a source control tool.

It was developed at [HERE](http://here.com) and we use it pretty much on a daily basis for updating our existing stacks and creating new ones.

For some details about the story behind it, you can see this [presentation](http://slidesha.re/U7SRPq) on Slideshare.


## Features
- Upload templates and parameters from the current directory into AWS with a single intuitive command. They need to be located in stacks/stack_name/{template.json,parameters.yaml}
- List existing stacks defined in AWS and also those only defined locally
- Dump one or all of the stacks from your currently selected AWS account into the current directory (preferably stored in a version control system) under the 'stacks' directory, including both the template JSON code and the parameters that were used for launching it, which will then be saved in a human-friendly YAML file.
- Perform updates on the AWS stacks once you modified the dumped data (template or parameters)
- Validate templates for JSON correctness when uploading or updating a stack. The error messages should help you debug syntax errors.
- Clone existing stacks to create new ones. It defaults to a local clone, which then needs another update call to get in effect. This is an easy way to migrate infrastructure 'code' around and makes it trivial to promote changes between environments, and can also be used easily with projects running in different AWS accounts. This is especially convenient together with an AWS profile switcher shell alias like implemented on the oh-my-zsh aws plugin.
- Perform cost calculations when creating a new stack.
- Delete existing stacks with a simple command
- For authentication it can use AWS account credentials defined using either the AWS_ACCESS_KEY_ID&AWS_SECRET_ACCESS_KEY combination, or the AWS_DEFAULT_PROFILE environment variable
- Able to use temporary credentials, if the AWS_SECURITY_TOKEN variable is defined in the environment.

## Installation

###On Ruby 1.9 or newer

    gem install clouds

###On Ruby 1.8.x

You might need to install `rubygems` separtely and you should be aware of the incompatibility between the more recent versions of `nokogiri`(a dependency of the `aws-sdk`, on which `clouds` indirectly depends on) and Ruby 1.8. This is pretty well-explained [here](http://ruby.awsblog.com/post/Tx2T9MFQJK7U74N/AWS-SDK-for-Ruby-and-Nokogiri).

You will need to manually install the latest compatible version of nokogiri and its build-time dependencies, as documented below:

    apt-get install libxml2-dev libxslt-dev # Debian and clones
    yum install libxml2-devel libxslt-devel # RedHat and clones
    gem install nokogiri --version="<1.6"
    gem install clouds

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

Upload the cloned stack to AWS CloudFormation. This can also be used against templates you downloaded from third other sources, not just for dumps.

    clouds update new_stack -c

Delete the new stack (needs --force)

    clouds delete new_stack


## Development

### Build requirements
- Ruby, rubygems and rake (some of them might already be there on Ruby > 1.9)
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
    sudo gem install pkg/clouds-*.gem

### Build instructions

Once you have the stated requirements satisfied, you can just package it as gem

    rake package

### Installing your own gem

    sudo gem install pkg/clouds-*.gem

