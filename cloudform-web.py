import boto3
import botocore

s3 = boto3.resource('s3')

bucket = s3.Bucket('salt-stack')
exists = True
try:
    s3.meta.client.head_bucket(Bucket='salt-stack')
except botocore.exceptions.ClientError as e:
    # If a client error is thrown, then check that it was a 404 error.
    # If it was a 404 error, then the bucket does not exist.
    error_code = int(e.response['Error']['Code'])
    if error_code == 404:
        exists = False


client = boto3.client('cloudformation')

response = client.create_stack(
    StackName='BotoWebStack03',
    TemplateURL='https://s3-us-west-2.amazonaws.com/salt-stack/minion-cloud-form.json',
#    Parameters=[
#        {
#            'ParameterKey': 'string',
#
#            'ParameterValue': 'string',
#            'UsePreviousValue': True|False
#        },
#    ],


    ResourceTypes=[
        'AWS::*',
    ],
    OnFailure='DO_NOTHING',
    Tags=[
        {
            'Key': 'BotoWebMinions03',
            'Value': 'Minions is launched by boto3'
        },
    ]
)