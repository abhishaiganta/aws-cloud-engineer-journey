# Week 7: Serverless & Event-Driven Architecture

## Request path

```
curl / browser
     |
     |  GET https://<api-id>.execute-api.us-east-1.amazonaws.com/properties/R100234
     v
API Gateway (HTTP API, route GET /properties/{id})
     |
     |  invokes the Lambda, passing {id} in event["pathParameters"]["id"]
     v
Lambda: get-property (Python 3.12)
     |
     |  get_item(Key={"L_ListingID": "R100234"})
     |  allowed by its execution role: dynamodb:GetItem on table/Properties only
     v
DynamoDB table: Properties (partition key L_ListingID)
     |
     |  returns the item
     v
Lambda turns it into JSON -> API Gateway -> 200 response back to the caller
```

## What I did

This week I took the same `get_property` lookup from PropertyLite and moved it off an always-on EC2 instance onto serverless pieces. I recreated the `Properties` DynamoDB table and loaded the sample listings, then wrote a Lambda function (`lambda_function.py`) that reads the listing ID from the URL and fetches it from DynamoDB instead of the CSV. I put an HTTP API in API Gateway in front of it with the route `GET /properties/{id}`. Calling `/properties/R100234` returns the same Sacramento listing, with the same JSON fields, that PropertyLite returned on EC2 in Week 3, but now nothing is running when nobody is calling it. A listing that doesn't exist returns a 404, just like the Flask app. The tests are in `curl-tests.sh`.

The Lambda's execution role only has one permission I added: `dynamodb:GetItem` on `arn:aws:dynamodb:*:*:table/Properties`. It can read a single item from that one table and can't write, delete, scan, or touch any other table or service, which is the same least-privilege idea as my Week 2 S3 policy. If the function's code were ever abused, the damage would stop at reading listings. When something breaks, the first place to look is Lambda > Monitor > View CloudWatch logs, because the API only says "Internal Server Error" while the logs show the real cause, like an `AccessDeniedException` or a `KeyError`.

I also set up an SQS queue (`property-queue`) with a dead-letter queue (`property-dlq`) and `maxReceiveCount` of 3. I sent a message and received it back, and any message that fails processing 3 times gets moved to the dead-letter queue so it isn't lost or retried forever.
