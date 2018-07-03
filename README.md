- requires   bucket = "${var.domain}-redirector-bucket"
      with "lambda.zip" inside:

```
cd lambda
zip -r -X "../lambda.zip" *
```



- lambda test console 
```json
{
  "queryStringParameters" : { "o" : "http://www.google.com" }
}
```
     
- API test console
```
Query Strings 
o=blah.com
```
