
import json
import logging
import os
project_id = 'concrete-envoy-213218'

#  Load the Cloud Pub/Sub module 

from google.cloud import pubsub_v1

# END TODO

from flask import current_app

#  Create a Pub/Sub Publisher Client

publisher = pubsub_v1.PublisherClient()

# END TODO

#  Create a Pub/Sub Subscriber Client

sub_client = pubsub_v1.SubscriberClient()

# END TODO

#  Create a Topic Object to reference the feedback topic

topic_path = publisher.topic_path(project_id, 'feedback')

# END TODO

#  Create a Subscription object named worker-subscription

sub_path = sub_client.subscription_path(project_id, 'worker-subscription')

# END TODO

"""
Publishes feedback info 
- jsonify feedback object
- encode as bytestring
- publish message
- return result
"""
def publish_feedback(feedback):

#  Publish the feedback object to the feedback topic

    payload = json.dumps(feedback, indent=2, sort_keys=True)
    data = payload.encode('utf-8')
    future = publisher.publish(topic_path, data=data)
    return future.result()

# END TODO

"""pull_feedback

Starts pulling messages from subscription
- receive callback function from calling module
- initiate the pull providing the callback function
"""
def pull_feedback(callback):
    #  Subscriber to the worker-subscription,
    # invoking the callback

    sub_client.subscribe(sub_path, callback=callback)

   
