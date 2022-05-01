

import logging
import sys
import time
import json

#  Load the pubsub, languageapi and spanner modules from the quiz.gcp package

from quiz.gcp import pubsub, languageapi, spanner

# END TODO

"""
Configure logging
"""
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
log = logging.getLogger()

"""
Receives pulled messages, analyzes and stores them
- Acknowledge the message
- Log receipt and contents
- convert json string
- call helper module to do sentiment analysis
- log sentiment score
- call helper module to persist to spanner
- log feedback saved
"""
def pubsub_callback(message):
    #  Acknowledge the message

    message.ack()

   

    log.info('Message received')

    #  Log the message

    log.info(message)

   

    data = json.loads(message.data)

    #  Use the languageapi module to analyze the sentiment

    score = languageapi.analyze(str(data['feedback']))

   

    #  Log the sentiment score

    log.info('Score: {}'.format(score))

   

    #  Assign the sentiment score to a new score property

    data['score'] = score

   

    #  Use the spanner module to save the feedback

    spanner.save_feedback(data)

    

    #  Log a message to say the feedback has been saved

    log.info('Feedback saved')    

   

"""
Pulls messages and loops forever while waiting
- initiate pull 
- loop once a minute, forever
"""
def main():
    log.info('Worker starting...')

    #  Register the callback

    pubsub.pull_feedback(pubsub_callback)

   

    while True:
        time.sleep(60)

if __name__ == '__main__':
    main()
