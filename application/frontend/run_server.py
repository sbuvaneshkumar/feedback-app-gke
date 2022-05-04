

from quiz import app

#  Add the following statement to import and start
# Stackdriver debug-agent
# The start(...) method takes an 'options' object that you 
# can use to configure the Stackdriver Debugger agent.
# You will need to pass through an object with an 
# allowExpressions Boolean property set to true.

# END TODO

app.run(debug=True, port=8080)