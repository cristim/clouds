# clouds

This is a tool that aims to ease the handling of Cloudformation stacks as code.

## Features
- List existing stacks defined in AWS and also those only defined locally
- Dumps all the stacks from your account into the current directory (preferably SCN backed) under the 'stacks' directory.
- Perform updates on the AWS stacks once you modified the dumped data
- Clone existing stacks to create new ones. It defaults to local clone, which then needs another update call to get in effect
- Delete existing stacks

## Build instructions
Simply run
    rake gem

## Installing
    sudo gem install pkg/clouds-0.0.1.gem

## Running
Execute this in your shell:
    clouds

    export AWS_DEFAULT_PROFILE#my_aws_profile # as defined in .aws/config

oh-my-zsh users can also use the asp command implemented in the [AWS zsh plugin](https://github.com/robbyrussell/oh-my-zsh/pull/2149)


Dump all the stacks from your account into the current directory:
    clouds dump --all

Once you edit a stack source code, this command would update it on AWS:
    clouds update stack_name

Clone a stack (locally)
    clouds clone stack new_stack

Upload the cloned stack to AWS
    clouds update new_stack -c

Delete the new stack (needs --force)
    clouds delete new_stack

## Development
### Install dependencies
    bundle install

### Running for development
    bundle exec bin/clouds

### Updating the installed gem
    rake repackage
    sudo gem install pkg/clouds-0.0.1.gem
