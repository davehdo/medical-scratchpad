# Introduction
This is an open source version of what is widely known as a 'handoff' or 'signout' tool used by medical providers. Traditionally, 'handoff tools' are of limited utility because they require duplicate data entry. This, conversely, is designed to be a tool that manages the gamut of tasks that a provider must accomplish (including admitting, covering, discharging, and handing off). 

## How does this differ from an EMR?
This is complementary to an Electronic Medical Record (EMR). An EMR contains a collection of documents that are published and part of the offical medical record. Medical scratchpad is to the EMR what a storyboard is to a movie production--designed to allow providers to jot notes, formulate plans, make reminders, and then export the final drafts into the EMR. Medical providers already do this in spreadsheets or other electronic documents that they print out before rounds and handoffs. However these are less secure with limited accessibility. 

## It's a workspace and a bedside tool
* Each view is built around a specific use case. The bedside view is mobile-optimized and has just the fields needed to record what the patient says.

## A communication hub
* Team members can collaborate effectively and eliminate redundancy by using the live TO DO list
* Multidisciplinary teams can communicate thoughts better by sharing a live document rather than following paper trails (notes in the chart) that are updated once daily, and optimized for billing rather than medical reasoning.

## A workflow manager
* The covering view highlights each patient's to do list for easy prioritizing and batching
* The rounding view lets users quickly review interval events and generate a list of tasks to complete for the day

## Export progress notes
* Write less, do more

## Screenshots
![alt-text](https://raw.githubusercontent.com/davehdo/medical-scratchpad/master/public/Screenshot%202016-07-11%2019.12.48.png)
![alt-text](https://raw.githubusercontent.com/davehdo/medical-scratchpad/master/public/Screenshot%202016-07-11%2019.16.47.png)
![alt-text](https://raw.githubusercontent.com/davehdo/medical-scratchpad/master/public/Screenshot%202016-07-11%2019.17.51.png)
![alt-text](https://raw.githubusercontent.com/davehdo/medical-scratchpad/master/public/Screenshot%202016-07-11%2019.18.08.png)

# Specifications
## Server side
* Rails 4.2.4
* Mongodb

## Client side
* Angular
* Jquery
* Coffee
* Lodash
* Moment.js

## Styling
* Sass
* Bootstrap
* Fontawesome ```<i class="fa fa-camera-retro"></i>```


# Getting Started
1. Update config/mongoid.yml to point the database to the correct location. You could use a local mongodb installation or a cloud-based service like MongoLab

# How to add another field to the scaffold

1. Prepare the rails back-end for receiving, storing, and returning the new field

* In app/models/patient.rb, add a line
```
field :field_name, type: String
```

* In app/controllers/patients_controller.rb, scroll to the permit method and whitelist the field name
```
params.require(:patient).permit(:name, :field_name)
```

* In app/views/patients/index.json.jbuilder and app/views/patients/show.json.jbuilder
add the name of the field to the extract method
```
json.extract! @patient, :id, :name, :field_name
```

2. Update the front end form to display the field   

* In assets/javascripts/templates/patients/show.html, add the field to the template
```
{{ patient.field_name}}
```
* In assets/javascripts/templates/_form.html.erb, add a form object to edit the field

# Deploying to Heroku (and mLab for MongoDB)
1. Create a new app in Heroku
1. Provision a mLab Add-on
1. This should automatically add an environment variable in Heroku called MONGODB_URI that has all the information necessary to connect to the mongo database. The value should take the following format:
```
mongodb://username:password@host1:port1,host2:port2/database
```
1. Update mongoid.yml with the appropriate settings to connect to mLab
```
production:
    clients:
        default:
            uri: "<%= ENV['MONGODB_URI'] %>"

            options:
                max_retries: 30
                retry_interval: 1
                timeout: 15
                refresh_interval: 10
```

1.create database indexes
```
rake db:mongoid:create_indexes
```
