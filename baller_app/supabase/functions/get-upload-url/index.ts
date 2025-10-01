// supabase/functions/get-upload-url/index.ts
import { S3Client, PutObjectCommand } from "npm:@aws-sdk/client-s3";
import { getSignedUrl } from "npm:@aws-sdk/s3-request-presigner";

const s3 = new S3Client({
  endpoint: "https://s3.us-west-002.backblazeb2.com",
  region: "us-west-002",
  credentials: {
    accessKeyId: Deno.env.get("B2_KEY_ID")!,
    secretAccessKey: Deno.env.get("B2_APP_KEY")!,
  },
});

Deno.serve(async (req) => {
  try {
    const { filename } = await req.json();

    const key = `originals/${Date.now()}-${filename}`;
    const command = new PutObjectCommand({
      Bucket: "courtfinder-images", // dein Bucket-Name in Backblaze
      Key: key,
    });

    const uploadURL = await getSignedUrl(s3, command, { expiresIn: 60 });

    return new Response(
      JSON.stringify({ uploadURL, filePath: key }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    const err = e as Error;
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
