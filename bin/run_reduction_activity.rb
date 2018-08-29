#!/usr/bin/env ruby -w

#
# Copyright 2017-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific language governing permissions
# and limitations under the License.
#

# This is main entry point and example usage of StepFunctions::Activity class.
#
# In order to setup this example you need to configure your AWS credentials executing in terminal:
# $ aws configure
#
# Replace the `ACTIVITY_ARN` with you register activity ARN and specify the region.
#
# You can change the activity settings and adjust the number of activity poller threads as well the number
# of activity worker threads. You should also adjust the activity hearbeat, specified in seconds, accordingly to your
# Step Functions state machine definition.

require_relative '../lib/step_functions/activity'

credentials = Aws::SharedCredentials.new
region = 'us-east-1'
activity_arn = 'arn:aws:states:us-east-1:767904627276:activity:t16_random_exception'

activity = StepFunctions::Activity.new(
  credentials: credentials,
  region: region,
  activity_arn: activity_arn,
  workers_count: 1,
  pollers_count: 1,
  heartbeat_delay: 30
)

def reduce_to_single_digit(num)
  if num > 10
    num = num.to_s.chars.map(&:to_i).reduce(:+)
    reduce_to_single_digit(num)
  else
    return num
  end
end

class RandomErrorA < StandardError; end
class RandomErrorB < StandardError; end

# The start method takes as argument the block that is the actual logic of your custom activity.
# Just recursively reduces the number provided by adding the digits to a single digit.
activity.start do |input|
	number = reduce_to_single_digit(input['addition'] || input['product'])
  # Throws an exception randomly - this is to test Step Function Retries
  random_num = rand(4)
  raise RandomErrorA.new("RandomError A") if random_num == 0 || random_num == 4
  raise RandomErrorB.new("RandomError B") if random_num == 1
  { result: :SUCCESS, action: :reduction, number: number }
end
