import json
import boto3

from botocore.exceptions import ClientError

#Bedrock client

client = boto3.client(service_name="bedrock-runtime", region_name="eu-west-2")

def lambda_handler(event, context):
            
    try:        
        body = json.loads(event["body"])
        prompt = body["prompt"]
        
    except Exception as err:
        return{
            'statusCode':400,
            'body': "Request body missing parameter 'prompt' "}


    model_id = "anthropic.claude-3-haiku-20240307-v1:0"

    f = open("system_prompt2.txt", "r")
    system_prompt = f.read()


    try:
        response = client.invoke_model(
            modelId = model_id,
            body=json.dumps(
                {"anthropic_version": "bedrock-2023-05-31",
                    "max_tokens": 1024,
                    "system":system_prompt,
                    "messages": [
                    {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": prompt
                        }
                    ]
                }
            ],
        }))
        model_response = json.loads(response["body"].read())

    except:
        return {
            'statusCode' : 500,
            'body' : "Model invocation failed"
        }

    print(model_response)

    response = model_response["content"][0]["text"]

    print("response")
    print(response)
    print(type(response))

    try:
        suggestions = json.loads(response)["suggestions"]
        print(suggestions)

    except Exception as err:
        
        print(err)

        return {
            'statusCode' : 500,
            'body' : str(err)
        }

    return {
        'statusCode': 200,
        'body': json.dumps(suggestions)
    }





