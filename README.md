## Script Writing

Every time our system makes a call to an ad server it logs what adverts are returned (which is what the interview.log file contains).  
When the adserver responds, it provides a list of asset IDs that are to be stitched into the user’s live stream:

```
20160420084726:-
20160420085418:[111783178, 111557953, 111646835, 111413356, 111412662, 105618372, 111413557]
20160420085418:[111413432, 111633904, 111783198, 111792767, 111557948, 111413225, 111413281]
20160420085418:[111413432, 111633904, 111783198, 111792767, 111557948, 111413225, 111413281]
20160420085522:[111344871, 111394583, 111295547, 111379566, 111352520]
20160420090022:[111344871, 111394583, 111295547, 111379566, 111352520]
```

The format of the input log is:

`timestamp:ads`

Where:

- timestamp is in the format YYYYMMDDhhmmss
- ads is a comma separated list of ad asset IDs surrounded by square brackets, or - if no ads were returned

The first part of the task is to write a script that outputs, for each ten minute slice of the day:

* The count of IDs that were returned
* The count of unique IDs that were returned
* The script should support a command line parameter to select whether unique or total IDs should be given.

Example output using the above log excerpt (in total mode):

```
20160420084:0
20160420085:26
20160420090:5
```
  
And in unique count mode it would give:

```
20160420084:0
20160420085:19
20160420090:5
```
