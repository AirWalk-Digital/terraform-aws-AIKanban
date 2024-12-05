import json
import boto3

from botocore.exceptions import ClientError

#Bedrock client

client = boto3.client(service_name="bedrock-runtime", region_name="eu-west-2")

def lambda_handler(event, context):
    
    model = "claude"

    if model == "titan":

        prompt = "Your role is to take a transcript of a meeting, and output it in the form of Kanban board items, formatted in JSON. Only output JSON formatted actions. Focus on tasks that need to be completed, not on what has been completed already. This is the transcript:" + event["prompt"]

        native_request = {
            "inputText": prompt,
            "textGenerationConfig": {
                "maxTokenCount": 512,
                "temperature": 0.5,
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
    
    elif model == "claude":
        
        prompt = "What can you do?"

        model_id = "anthropic.claude-3-sonnet-20240229-v1:0"

        system_prompt = "Your role is to create summaries of meeting transcripts. Output a lists of tasks that need to be completed."

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
                            "text": event["prompt"]
                        }
                    ]
                }
            ],
        }))

        model_response = json.loads(response["body"].read())

        print(model_response)

        response_text = model_response["content"][0]["text"]


        return {
            'statusCode': 200,
            'body': json.dumps({"Answer": response_text})
        }





