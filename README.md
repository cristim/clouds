# clouds

This is a tool that aims to ease the handling of Cloudformation stacks as code.

## Features
- List existing stacks defined in AWS and also those only defined locally
- Dump all the stacks from your account into the current directory (preferably SCM backed) under the 'stacks' directory.
- Perform updates on the AWS stacks once you modified the dumped data
- Validate templates as JSON when updating a stack
- Clone existing stacks to create new ones. It defaults to local clone, which then needs another update call to get in effect
- Delete existing stacks

## Build requirements
- Ruby, rubygems and rake (some might already be there on Ruby > 1.9)
- Development headers for libxml2 and libxslt (-devel packages)
- Bundler

    sudo gem install bundler

    sudo bundle install

## Build instructions

Simply run (once you have the stated requirements satisfied)

    rake package

## Installing
    sudo gem install pkg/clouds-0.0.1.gem

## Running
Execute this in your shell:

    clouds -h

In order to do real stuff you need a profile to be defined in .aws/config for the aws command line tool, and to have it referenced by the AWS_DEFAULT_PROFILE environment variable.

    export AWS_DEFAULT_PROFILE=my_aws_profile

The oh-my-zsh users can also use the asp command implemented in the [AWS zsh plugin](https://github.com/robbyrussell/oh-my-zsh/pull/2149)

## Use cases

Dump all the stacks from your account into the current directory

    clouds dump --all

Once you edit a stack source code, this command would update it on AWS

    clouds update stack_name

Clone a stack (locally only, so you can perform some changes)

    clouds clone stack new_stack

Upload the cloned stack to AWS

    clouds update new_stack -c

Delete the new stack (needs --force)

    clouds delete new_stack

## Development
### Install dependencies
Only in case you didn't do it before

    bundle install

### Running for development

    bundle exec bin/clouds

### Updating the installed gem

    rake repackage
    sudo gem install pkg/clouds-0.0.1.gem
