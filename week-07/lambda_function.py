import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Properties')


def lambda_handler(event, context):
    # Same lookup as PropertyLite's get_property route, but reading DynamoDB instead of the CSV
    listing_id = event['pathParameters']['id']
    resp = table.get_item(Key={'L_ListingID': listing_id})
    item = resp.get('Item')

    if not item:
        return {
            'statusCode': 404,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'not found'})
        }

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        # default=str handles DynamoDB number types (Decimal), which json can't serialize on its own
        'body': json.dumps(item, default=str)
    }
