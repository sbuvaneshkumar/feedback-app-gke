

import os
project_id = 'concrete-envoy-213218'
bucket_name ='testy-bucks'

from google.cloud import storage

storage_client = storage.Client()
bucket = storage_client.get_bucket(bucket_name)

"""
Uploads a file to a given Cloud Storage bucket and returns the public url
to the new object.
"""
def upload_file(image_file, public):
    blob = bucket.blob(image_file.filename)

    blob.upload_from_string(
        image_file.read(),
        content_type=image_file.content_type)

    if public:
        blob.make_public()

    return blob.public_url
