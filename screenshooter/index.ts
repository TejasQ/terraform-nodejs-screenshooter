import type { Handler } from "aws-lambda";
import { takeScreenshot } from "./takeScreenshot";

export const handler: Handler = async (event, _, callback) => {
  try {
    const { url } = event?.queryStringParameters ?? {
      url: "https://google.com",
    };
    const screenshot = await takeScreenshot(url);
    callback(null, {
      statusCode: 200,
      body: screenshot,
      isBase64Encoded: true,
      headers: {
        "cache-control": "s-maxage=86400",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST,GET",
        "Access-Control-Allow-Headers": "Content-Type,Accept",
        "Content-Type": "image/jpeg",
      },
    });
    return;
  } catch (e) {
    callback(null, {
      statusCode: 200,
      body: `Died because ${JSON.stringify(e, null, 2)}`,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST,GET",
        "Access-Control-Allow-Headers": "Content-Type,Accept",
      },
    });
    return;
  }
};
