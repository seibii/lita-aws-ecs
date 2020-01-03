# lita-aws-ecs
[![Gem Version](https://badge.fury.io/rb/lita-aws-ecs.svg)](https://badge.fury.io/rb/lita-aws-ecs)
[![Circle CI](https://circleci.com/gh/seibii/lita-aws-ecs.svg?style=shield)](https://circleci.com/gh/seibii/lita-aws-ecs)
[![Code Climate](https://codeclimate.com/github/seibii/lita-aws-ecs/badges/gpa.svg)](https://codeclimate.com/github/seibii/lita-aws-ecs)
[![codecov](https://codecov.io/gh/seibii/lita-aws-ecs/branch/master/graph/badge.svg)](https://codecov.io/gh/seibii/lita-aws-ecs)
[![Libraries.io dependency status for GitHub repo](https://img.shields.io/librariesio/github/seibii/lita-aws-ecs.svg)](https://libraries.io/github/seibii/lita-aws-ecs)
![](http://ruby-gem-downloads-badge.herokuapp.com/lita-aws-ecs?type=total)
![GitHub](https://img.shields.io/github/license/seibii/lita-aws-ecs.svg)

`lita-aws-ecs` allows you to manage AWS ECS by commands. 

## Installation

Add lita-aws-ecs to your Lita instance's Gemfile:

``` ruby
gem "lita-aws-ecs"
```

## Configuration
Set environment variables below.

```
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=xxxx
AWS_SECRET_ACCESS_KEY=xxxx
```

or use config

```
Lita.config.handlers.aws_ecs.aws_region = 'us-east-1'
Lita.config.handlers.aws_ecs.aws_access_key_id = 'xxxx'
Lita.config.handlers.aws_ecs.aws_secret_access_key = 'xxxx'
```

## Usage

```bash
lita ecs clusters
lita ecs cluster services ${cluster_name}
lita ecs cluster tasks ${cluster_name}
lita ecs service tasks ${service_name}
lita ecs cluster component ${cluster_name}
lita ecs service update ${cluster_name} ${service_name} ${task_name:revision}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seibii/lita-aws-ecs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lita::AWS::ECS project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/seibii/lita-aws-ecs/blob/master/CODE_OF_CONDUCT.md).
