import {Handler, APIGatewayEvent, APIGatewayProxyResult, APIGatewayProxyEvent} from 'aws-lambda'

const status404 = (message: string): APIGatewayProxyResult => {
    return {statusCode: 404, body: message}
}

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    if(event.body ==  null) return status404("No body")

    const { address, rent, startDate } = JSON.parse(event.body);

    if(address == null || typeof address != "string") return status404("Issue with address");
    if(rent == null || typeof rent != "number") return status404("Issue with rent");
    if(startDate == null || typeof startDate != "string") return status404("Issue with startDat");


    return {
        statusCode: 200,
        body: `Address is correct`
    }
}
