import json
import boto3

from botocore.exceptions import ClientError

#Bedrock client

client = boto3.client(service_name="bedrock-runtime", region_name="eu-west-2")

def lambda_handler(event, context):
    

    prompt = "Your role is to take a transcript of a meeting, and output it in the form of Kanban board items, formatted in JSON. Only output JSON formatted actions. This is the transcript:" + event["prompt"]

    native_request = {
        "inputText": prompt,
        "textGenerationConfig": {
            "maxTokenCount": 512,
            "temperature": 0.8,
        },
    }
    
    request = json.dumps(native_request)
    
    
    try:
        response = client.invoke_model(modelId="amazon.titan-text-express-v1", body=request)

    except (ClientError, Exception) as e:
        print(f"ERROR: Can't invoke: Reason: {e}")
        exit(1)

    model_response = json.loads(response["body"].read())

    response_text = model_response["results"][0]["outputText"]
    

    return {
        'statusCode': 200,
        'body': json.dumps({"Answer": response_text})
    }
