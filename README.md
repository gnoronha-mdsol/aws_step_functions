## Step Functions Ruby Activity Worker

The code contains a sample implementation of AWS Step Functions.

## Summary

This package defines the Step Functions reference activity worker implementation.
The input to the Step Function should be a 3-digit number in a JSON object such as
```
{
  "number": 456
}
```
The Step Function [t16_condition_test](https://console.aws.amazon.com/states/home?region=us-east-1#/statemachines/view/arn:aws:states:us-east-1:767904627276:stateMachine:t16_condition_test) has the following tasks 
1. a lambda [t16_check_is_even](https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/t16_check_is_even?tab=graph) (written in Python) - which validates that the input is a 3 digit number and determines if the number is even by setting `is_even` as `true` or `false` in the output.
1. a `Choice` task that determines which of 2 activity workers written in Ruby are invoked - this Tasks takes the `is_even` key of the previous output and calls the addition activity if the number is odd and product activity if the number is even.
1. Activites
	1. an Activity [t16_addition](./bin/run_addition_activity.rb) - adds the digits of the number
	1. an Activity [t16_product](./bin/run_product_activity.rb) - mulitplies the digits of the number

![Visual Workflow of the Step Function](https://s3.amazonaws.com/mingest/glen/visual_Workflow.png)


## Setting up the code

### Install Ruby AWS SDK

```bash
gem install aws-sdk
```

Install AWS CLI and run:

```bash
aws configure
```

Setup your access key and secret key to your AWS IAM user.
Update the ACTIVITY_ARN and region within the activities located in `bin` folder.

`bin/run_addition_activity.rb` and `bin/run_product_activity.rb`

### Run the activities:

Open two terminals and run

```bash
./bin/run_addition_activity.rb
```
and

```bash
./bin/run_product_activity.rb
```

### Start the execution:
Examples for the execution are located in the `examples` folder.

Fire up another terminal and while the `addition_activity` and `product_activity` are running in other terminals initiate the executions
```bash
aws stepfunctions start-execution --state-machine-arn "arn:aws:states:us-east-1:767904627276:stateMachine:t16_condition_test" --input "$(< ./examples/odd.json)"
```
The output of this command will be
```
{
    "executionArn": "arn:aws:states:us-east-1:767904627276:execution:t16_condition_test:764ef05b-1459-4569-91b2-6fcabcc171f4",
    "startDate": 1535356667.238
}
```
To see the result of the execution run the following command with `executionArn` obtained in the `start-execution` output.
```bash
aws stepfunctions describe-execution --execution-arn "arn:aws:states:us-east-1:767904627276:execution:t16_condition_test:764ef05b-1459-4569-91b2-6fcabcc171f4"
```

## License

This library is licensed under the Apache 2.0 License. 
