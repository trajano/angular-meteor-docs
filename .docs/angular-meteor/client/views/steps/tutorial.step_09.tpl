
  <div class="row">
    <div class="col-md-12">
    <a href="https://github.com/Urigo/angular-meteor/edit/master/.docs/angular-meteor/client/views/steps/tutorial.step_09.tpl"
       class="btn btn-default btn-lg improve-button">
      <i class="glyphicon glyphicon-edit">&nbsp;</i>Improve this doc
    </a>
    <ul class="btn-group tutorial-nav">
      <a href="/tutorial/step_08"><li class="btn btn-primary"><i class="glyphicon glyphicon-step-backward"></i> Previous</li></a>
      <a href="http://socially-step09.meteor.com/"><li class="btn btn-primary"><i class="glyphicon glyphicon-play"></i> Live Demo</li></a>
      <a href="https://github.com/Urigo/meteor-angular-socially/compare/step_08...step_09"><li class="btn btn-primary"><i class="glyphicon glyphicon-search"></i> Code Diff</li></a>
      <a href="/tutorial/step_10"><li class="btn btn-primary">Next <i class="glyphicon glyphicon-step-forward"></i></li></a>
    </ul>

  </div>

  <div class="col-md-8">
    <h1>Step 9 - Privacy and publish-subscribe functions</h1>
  </div>
  <div class="video-tutorial col-md-4">
    <iframe width="300" height="169" src="//www.youtube.com/embed/wAHi7ilDHko?list=PLhCf3AUOg4PgQoY_A6xWDQ70yaNtPYtZd" frameborder="0" allowfullscreen></iframe>
  </div>

  <do-nothing class="col-md-12">
  <btf-markdown>

Right now our app has no privacy, every user can see all the parties on the screen.

So let's add a 'public' flag on parties - if a party is public we will let anyone see it, but if a party is private, only the owner can see it.

First we need to remove the 'autopublish' Meteor package.

autopublish is added to any new Meteor project. It pushes a full copy of the database to each client.
It helped us until now, but it's not so good for privacy...

Write this command in the console:

    meteor remove autopublish


Now run the app.   You can't see any parties.

So now we need to tell Meteor what parties should it publish to the clients.

To do that we will use Meteor's publish command.

Publish functions should go only in the server so the client won't have access to them.
So let's create a new file named parties.js inside the server folder.

Inside the file insert this code:

    Meteor.publish("parties", function () {
      return Parties.find({
        $or:[
          {$and:[
            {"public": true},
            {"public": {$exists: true}}
          ]},
          {$and:[
            {owner: this.userId},
            {owner: {$exists: true}}
          ]}
        ]});
    });

Let's see what is happening here.

First, we have the Meteor.publish - a function to define what to publish from the server to the client.

The first parameter is the name of the subscription. the client will subscribe to that name.

The second parameter is a function the defines what will be returned in the subscription.
That function will determine what data will be returned and the permissions needed.

In our case the first name parameter is "parties". So we will need to subscribe to the "parties" collection in the client.

We have 2 way of doing this:

1. Using the [$meteor.subscribe](/api/subscribe) service that also return a promise when the subscribing is done
2. using [AngularMeteorCollection's](/api/AngularMeteorCollection) subscribe function which is exactly the same but it's
here just for syntactic sugar doesn't return a promise.

Right now we don't need the promise so let's use the second way:

    $scope.parties = $meteor.collection(Parties).subscribe('parties');

It is the same as:
    $meteor.subscribe('parties');
    $scope.parties = $meteor.collection(Parties);
    
But it is a *good practise* to resolve a subscription in state's resolve function:

     .state('parties', {
        url: '/parties',
        templateUrl: 'client/parties/views/parties-list.ng.html',
        controller: 'PartiesListCtrl',
        resolve: {
          'subscribe': [
            '$meteor', function($meteor) {
              return $meteor.subscribe('parties');
            }
          ]
        }
     });

* Our publish function can also take parameters.  In that case, we would also need to pass the parameters from the client.
For more information about the $meteor.subscribe service [click here](http://angularjs.meteor.com/api/subscribe) or the subscribe function of [AngularMeteorCollection](/api/AngularMeteorCollection).


In the second parameter, our function uses the Mongo API to return the wanted documents (document are the JSON-style data structure of MongoDB).

So we create a query - start with the find method on the Parties collection.

Inside the find method we use the [$or](http://docs.mongodb.org/manual/reference/operator/query/or/), [$and](http://docs.mongodb.org/manual/reference/operator/query/and/) and [$exists](http://docs.mongodb.org/manual/reference/operator/query/exists/) Mongo operators to pull our wanted parties:

Either that the owner parameter exists and it's the current logged in user (which we have access to with the command this.userId), or that the party's public flag exists and it's set as true.


So now let's add the public flag to the parties and see how it affects the parties the client gets.

Let's add a checkbox to the new party form in parties-list.ng.html:

  </btf-markdown>

<pre><code><span class="hljs-tag">&lt;<span class="hljs-title">label</span>&gt;</span>Public<span class="hljs-tag">&lt;/<span class="hljs-title">label</span>&gt;</span>
<span class="hljs-tag">&lt;<span class="hljs-title">input</span> <span class="hljs-attribute">type</span>=<span class="hljs-value">"checkbox"</span> <span class="hljs-attribute">ng-model</span>=<span class="hljs-value">"newParty.public"</span>&gt;</span>
</code></pre>

    <btf-markdown>

Notice how easy it is to bind a checkbox to a model with AngularJS!

Let's add the same to the party-details.ng.html page:

        </btf-markdown>

<pre><code>&lt;<span class="hljs-keyword">label</span>&gt;<span class="hljs-keyword">Is</span> public&lt;/<span class="hljs-keyword">label</span>&gt;
&lt;input <span class="hljs-keyword">type</span>=<span class="hljs-string">"checkbox"</span> ng-model=<span class="hljs-string">"party.public"</span>&gt;
</code></pre>

        <btf-markdown>

Now let's run the app.

Log in with 2 different users in 2 different browsers.

In each of the users create a few public parties and a few private ones.

Now log out and see which user sees which parties.


In the next step, we will want to invite users to private parties. for that, we will need to get all the users, but only their emails without other data which will hurt their privacy.

So let's create another publish method for getting only the needed data on the user.

Notice the we don't need to create a new Meteor collection like we did with parties. **Meteor.users** is a pre-defined collection which is defined by the [meteor-accounts](http://docs.meteor.com/#accounts_api) package.

So let's start with defining our publish function.

Create a new file under the 'server' folder named users.js and place the following code in:

    Meteor.publish("users", function () {
      return Meteor.users.find({}, {fields: {emails: 1, profile: 1}});
    });

So here again we use the Mongo API to return all the users (find with an empty object) but we select to return only the emails and profile fields.

* Notice that each object (i.e. each user) will automatically contain its _id field.

The emails field holds all the user's email addresses, and the profile might hold more optional information like the user's name
(in our case, if the user logged in with the Facebook login, the accounts-facebook package puts the user's name from Facebook automatically into that field).

Now let's subscribe to that publish Method.  in the client->parties->controllers->partyDetails.js file add the following line inside the controller.
If you just add to the end you will get an uncaught reference $scope not defined:

    $scope.users = $meteor.collection(Meteor.users, false).subscribe('users');

* We bind to the Meteor.users collection
* Binding the result to $scope.users
* Notice that we passes false in the second parameter. that means that we don't want to update that collection from the client.
* Calling [AngularMeteorCollection's](/api/AngularMeteorCollection) subscribe function.

Also, let's add a subscription to the party in case we get straight to there and won't go through the parties router:

    $scope.party = $meteor.object(Parties, $stateParams.partyId).subscribe('parties');


Now let's add the list of users to the view to make sure it works.

Add this ng-repeat list to the end of parties-details.ng.html:

</btf-markdown>

<pre><code><span class="xml"><span class="hljs-tag">&lt;<span class="hljs-title">ul</span>&gt;</span>
  Users:
  <span class="hljs-tag">&lt;<span class="hljs-title">li</span> <span class="hljs-attribute">ng-repeat</span>=<span class="hljs-value">"user in users"</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-title">div</span>&gt;</span></span><span class="hljs-expression">{{ <span class="hljs-variable">user.emails</span>[0]<span class="hljs-variable">.address</span> }}</span><span class="xml"><span class="hljs-tag">&lt;/<span class="hljs-title">div</span>&gt;</span>
  <span class="hljs-tag">&lt;/<span class="hljs-title">li</span>&gt;</span>
<span class="hljs-tag">&lt;/<span class="hljs-title">ul</span>&gt;</span></span>
</code></pre>

<btf-markdown>

Run the app and see the list of all the users' emails that created a login and password and did not use a service to login.
Facebook, Google etc. users email is located in a sub-document called services. 

The Document structure for the Facebook and Google login service looks like this:

/* 1 */
{
    "_id" : "etKoiD8MxkQTjTQRY",
    "createdAt" : ISODate("2015-05-25T17:42:16.850-07:00"),
    "services" : {
        "facebook" : {
            "accessToken" : "CAAM10fSvIhABAKYNNnykDZAFZBOLwr9Qhj6kVq4MiMMO5VemAkJaiRvqSiYTkY3AqeBheYhzx7dumuruc07GRmPkmZC6S1ZAF0ZAZAXYzTjrA8cQlKkOZB0SwHBZAvZBMtQ4EaquvtUK0We7ZB4otbJBenrAF4uEZB9k5TfBrLGY8MdM7aP3Bvl4razrRZCIiPJZAuZB8ZCCZB6xeegzaiXVKMyUkRZC0mgHfkxRyZCVsZD",
            "expiresAt" : 1437770457288.0000000000000000,
            "id" : "10153317814289291",
            "email" : "email@email.com",
            "name" : "FirstName LastName",
            "first_name" : "FirstName",
            "last_name" : "LastName",
            "link" : "https://www.facebook.com/app_scoped_user_id/foo"
            "gender" : "male",
            "locale" : "en_US"
        },
        "resume" : {
            "loginTokens" : []
        }
    },
    "profile" : {
        "name" : "First Name LastName"
    }
}

/* 2 */
{
    "_id" : "337r4wwSRWe5B6CCw",
    "createdAt" : ISODate("2015-05-25T22:53:32.172-07:00"),
    "services" : {
        "google" : {
            "accessToken" : "ya29.fwHSzHvCYPh9Vz3UJcYEvMS9knV6LpTe-kQf3cx5567CL93EBVb-lXAaREU0vUQJvALTDesTiZDzTg",
            "idToken" : "eyJhbGciOiJSUzI1NiIsImtpZCI6IjcxNThkODVjODU3ZjM2OGJmM2E0NDhiMjI3MjBhM2E1NWIwNzM0NDcifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwic3ViIjoiMTA3NDk3Mzc2Nzg5Mjg1ODg1MTIyIiwiYXpwIjoiNDE4NjcxMDMwNzI3LXNpcDh2NHBkMWJiN2F2YjdhdGtydTAwNm1jbmJnZW5rLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiZW1haWwiOiJibGV2aW5zY21AZ21haWwuY29tIiwiYXRfaGFzaCI6IjZMZTYwSE0zMkNxMkQybkRpMlQ2ZnciLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXVkIjoiNDE4NjcxMDMwNzI3LXNpcDh2NHBkMWJiN2F2YjdhdGtydTAwNm1jbmJnZW5rLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaWF0IjoxNDMyNjIxMDkxLCJleHAiOjE0MzI2MjQ2OTF9.pYEDATkLdvC5DEcwOXrnZno2PHW_Y8y3XeIa7-pJemGi4QHAYKsnkRBP4cgVJ4kaTC9leSOFBrGjPNTbtfMTCp_jL_fcCkPbKyxHXwAK_k7fELmoScRZ7v7LV17GWUmdSsU-incnDYsCSBxvptcZkYQGJzqwsb74Yklh3SOfIho",
            "expiresAt" : 1432624691685.0000000000000000,
            "id" : "107497376789285885122",
            "email" : "email@email.com",
            "verified_email" : true,
            "name" : "FirstName LastName",
            "given_name" : "FirstName",
            "family_name" : "LastName",
            "picture" : "https://lh5.googleusercontent.com/-foo.jpeg
            "locale" : "en",
            "gender" : "male"
        },
        "resume" : {
            "loginTokens" : [ 
                {
                    "when" : ISODate("2015-05-25T23:18:11.788-07:00"),
                    "hashedToken" : "NaKS2Zeermw+bPlMLhaihsNu6jPaW5+ucFDF2BXT4WQ="
                }
            ]
        }
    },
    "profile" : {
        "name" : "First Name LastName"
    }
}

/* 3 */
{
    "_id" : "8qJt6dRSNDHBuqpXu",
    "createdAt" : ISODate("2015-05-26T00:29:05.109-07:00"),
    "services" : {
        "password" : {
            "bcrypt" : "$2a$10$oSykELjSzcoFWXZTwI5.lOl4BsB1EfcR8RbEm/KsS3zA4x5vlwne6"
        },
        "resume" : {
            "loginTokens" : [ 
                {
                    "when" : ISODate("2015-05-26T00:29:05.112-07:00"),
                    "hashedToken" : "6edmW0Wby2xheFxyiUOqDYYFZmOtYHg7VmtXUxEceHg="
                }
            ]
        }
    },
    "emails" : [ 
        {
            "address" : "email@email.com",
            "verified" : false
        }
    ]
}

Compare the services login structure in Document /* 1 */ and document /* 2 */ with Document /* 3 */ which is a created login. 
You can see why only created users will show up in our list of emails.



# Understanding Meteor's Publish-Subscribe

It is very important to understand Meteor's Publish-Subscribe mechanism so you don't get confused and use it to filter things in the view!

Meteor accumulates all the data from the different subscription of a collection in the client, so adding a different subscription in a different
view won't delete the data that is already in the client.

Please read more [here](http://www.meteorpedia.com/read/Understanding_Meteor_Publish_and_Subscribe).

# Summary

We've added the support of privacy to our parties app.

We also learned how to use the Meteor.publish command to control the data and permissions sent to the client
and how to subscribe to it with the $collection.bind 4th parameter.

In the next step we will learn how to filter the users list in the client side with AngularJS filters and create a custom filter for our own needs.

    </btf-markdown>
    </do-nothing>
<div class="col-md-12">
    <ul class="btn-group tutorial-nav">
      <a href="/tutorial/step_08"><li class="btn btn-primary"><i class="glyphicon glyphicon-step-backward"></i> Previous</li></a>
      <a href="http://socially-step09.meteor.com/"><li class="btn btn-primary"><i class="glyphicon glyphicon-play"></i> Live Demo</li></a>
      <a href="https://github.com/Urigo/meteor-angular-socially/compare/step_08...step_09"><li class="btn btn-primary"><i class="glyphicon glyphicon-search"></i> Code Diff</li></a>
      <a href="/tutorial/step_10"><li class="btn btn-primary">Next <i class="glyphicon glyphicon-step-forward"></i></li></a>
    </ul>
    </div>
  </div>

