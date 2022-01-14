<img src="https://user-images.githubusercontent.com/79303/149438778-ab0e7337-cf3a-4db8-8c03-0f04ccd83179.jpg" width="90%"/>

# Halfpipe - a Pipedrive client that doesn't do half of what you want

If you're scouring [RubyGems.org](https://rubygems.org) for a general-purpose
client to the [Pipedrive](https://www.pipedrive.com)
[API](https://developers.pipedrive.com/docs/api/v1), this is probably not the
gem for you ([here's why](#why-doesnt-this-gem-do-what-i-want)). Here's what it
does and how to use it anyway.

Halfpipe's API is split between compound actions (read: features we needed
ourselves) and an assortment of wrapped HTTP endpoints (aka stuff we needed in
order to implement those actions). Most methods return
[Structs](https://ruby-doc.org/core-3.0.0/Struct.html) encapsulating the minimum
number of attributes needed to accomplish these actions.

If Halfpipe doesn't do what you're looking for, you might consider just using
its [Http](#halfpipehttp) methods, since they at least handle HTTP request
authentication, pagination, and rate limiting for you.

# Setup

Add this to your Gemfile and kickflip it:

```ruby
gem "halfpipe"
```

For configuration, the gem needs your Pipedrive subdomain and [API
Token](https://pipedrive.readme.io/docs/how-to-find-the-api-token). If your
subdomain is `"alwaysbeselling"` and your API token is stored in an environment
variable named `PIPEDRIVE_API_TOKEN`, you can configure Halfpipe like this:

```ruby
Halfpipe.config(
  subdomain: "alwaysbeselling"
  api_token: ENV["PIPEDRIVE_API_TOKEN"]
)
```

# Primary API

## Halfpipe.create_deal_for_person

Test Double [has a contact form](https://testdouble.com/contact) that takes a
handful of inputs and uses it to create a deal in Pipedrive so we can stay
organized. To do this seemingly simple thing requires numerous interactions with
the Pipedrive API: find-or-create the
[person](https://developers.pipedrive.com/docs/api/v1/Persons), find the first
[stage](https://developers.pipedrive.com/docs/api/v1/Stages) of the intended
[pipeline](https://developers.pipedrive.com/docs/api/v1/Pipelines), find any
custom [deal fields](https://developers.pipedrive.com/docs/api/v1/DealFields)
that we want to set, create the
[deal](https://developers.pipedrive.com/docs/api/v1/Deals), and then (finally!)
attach a [note](https://developers.pipedrive.com/docs/api/v1/Notes) to the deal.

To accomplish this, here's what Halfpipe offers:

```ruby
Halfpipe.create_deal_for_person(
  name: "Person Face",
  email: "person.face@example.com",
  deal_title: "Person Face lead via Halfpipe",
  custom_deal_fields: {
    "How they heard about us" => "A GitHub README",
    "Inbound CTA" => "halfpipe-github-readme"
  },
  note_content: "Greetings!",
  pipeline_name: "Halfpipe Leads"
)
```

**[Heads up:** any `custom_deal_fields` you send need to be an exact textual
match for a [field](https://support.pipedrive.com/en/article/custom-fields)
configured in your Pipedrive instance or, failing that, boil down to the same
string when stripped of extraneous whitespace and punctuation (e.g.
`how_they_heard_about_us` and `inbound_cta` above).**]**

# Supporting API

Halfpipe is unapologetically *not* a complete wrapper for Pipedrive's API
and instead only provides methods that we had to write in support of this gem's
[Primary API](#primary-api), so YMMV (but this is open source, so it's already
YMMV).

## Halfpipe::Api::Persons

### Halfpipe::Api::Persons.find_by_email(email)

This method will return the first person in Pipedrive with an e-mail that's an
exact match for what you provide:

```ruby
> person = Halfpipe::Api::Persons.find_by_email("person.face@example.com")
=> #<struct Halfpipe::Person
 id=9,
 name="Person Face",
 email="person.face@example.com",
 organization_id=2>
```

### Halfpipe::Api::Persons.create(name:, email:)

This method will create a new person with the provided name & e-mail address,
returning a `Struct` that includes the resulting ID:

```ruby
> person = Halfpipe::Api::Persons.create(
  name: "A person",
  email: "person.face@example.com"
)
=> #<struct Halfpipe::Person
 id=10,
 name="A person",
 email="person.face@example.com",
 organization_id=nil>
```

## Halfpipe::Api::Deals

### Halfpipe::Api::Deals.create(title:, stage_id: nil, person_id: nil, organization_id: nil, custom_fields: {})

This method creates a new deal with the properties you pass it. Only `title` and
either `person_id` or `organization_id` is required:

```ruby
> deal = Halfpipe::Api::Deals.create(title: "A deal!", organization_id: 1)
=> #<struct Halfpipe::Deal
 id=31,
 title="A deal!",
 stage_id=1,
 person_id=nil,
 organization_id=1>
```

## Halfpipe::Api::DealFields

### Halfpipe::Api::DealFields.get

This method retrieves all the custom fields you've defined for deals in your
Pipedrive instance. Why was this necessary for the gem? We need to fetch
these `DealField` entities and map the string name of any custom fields to the
hash key assigned by Pipedrive.

```ruby
> deal_fields = Halfpipe::Api::DealFields.get
=> [#<struct Halfpipe::DealField key="title", name="Title", symbol="title">,
 #<struct Halfpipe::DealField key="creator_user_id", name="Creator", symbol="creator">,
 #<struct Halfpipe::DealField key="user_id", name="Owner", symbol="owner">,
 #<struct Halfpipe::DealField key="value", name="Value", symbol="value">,
 #… etc…
]
```

## Halfpipe::Api::Stages

### Halfpipe::Api::Stages.find_first_stage_by_pipeline_name(pipeline_name)

This method will return the first stage in the first Pipedrive with the given
`pipeline_name`.

```ruby
> stage = Halfpipe::Api::Stages.find_first_stage_by_pipeline_name("Pipeline")
=> #<struct Halfpipe::Stage
 id=1,
 pipeline_id=1,
 name="Qualified">
```

## Halfpipe::Api::Notes

### Halfpipe::Api::Notes.create(content:, deal_id: nil, person_id: nil, organization_id: nil)

This method creates notes and attaches them to the provided deal, person, and/or
organization (at least one is required).

```ruby
> note = Halfpipe::Api::Notes.create(person_id: 1, content: "Greetings!")
=> #<struct Halfpipe::Note
 id=11,
 content="Greetings!",
 deal_id=nil,
 person_id=1,
 organization_id=nil>
```

## Halfpipe::Http

### Halfpipe::Http.get(path, params: {}, start: 0)

This method will send a `GET` request on your behalf, appending the required
`api_token` query parameter along with whatever other params you send.
Additionally, it will paginate throughout _all_ the results that your query
might return. Until the job is done, it'll even wait whatever retry amount the
API's `x-ratelimit-reset` header tells it to wait!

You can use this method to fetch stuff that isn't supported by the rest of the
API. You'll just get hashes back instead of custom `Struct` instances:

```ruby
> pipelines = Halfpipe::Http.get("/pipelines")
=> [{"id"=>1,
  "name"=>"Pipeline",
  "url_title"=>"default",
  "order_nr"=>1,
  "active"=>true,
  "deal_probability"=>false,
  "add_time"=>"2022-01-04 12:35:34",
  "update_time"=>nil,
  "selected"=>true},
 {"id"=>2,
  "name"=>"Test Double Leads",
  "url_title"=>"Test-Double-Leads",
  "order_nr"=>2,
  "active"=>true,
  "deal_probability"=>true,
  "add_time"=>"2022-01-07 16:14:08",
  "update_time"=>"2022-01-07 16:14:08",
  "selected"=>false}]
```

### Halfpipe::Http.post(path, params: {})

This method is a straightforward wrapper of
[Net::HTTP.post_form](https://ruby-doc.org/stdlib-3.0.0/libdoc/net/http/rdoc/Net/HTTP.html#method-c-post_form):

```ruby
> organization = Halfpipe::Http.post("/organizations", params: {name: "An org"})
=> {"id"=>3,
 "company_id"=>10804948,
 "owner_id"=>
  {"id"=>853119,
   "name"=>"Justin Searls",
   # etc.
  },
 "name"=>"An org",
 "open_deals_count"=>0,
 "related_open_deals_count"=>0,
 "closed_deals_count"=>0,
 # etc.
}
```

### Halfpipe::Http.delete(path, params: {})

Fair warning: the gem only uses this method to clean up test data:

```ruby
> Halfpipe::Http.delete("/notes/#{id}")
=> # The Net::Http::Response
```

## Why doesn't this gem do what I want?

Pipedrive—and
[CRM](https://en.wikipedia.org/wiki/Customer_relationship_management) tools
generally—are devilishly simple. At their most basic, they only require a
half-dozen models ("Person", "Lead", "Deal", etc.) and their core functionality
can easily be expressed with familiar CRUD actions ("create a new deal", "change
the status of this deal")… what's so hard about that?

Here's the tricky part: lying just beneath the surface of every CRM tool, there
is an entire [key-value
database](https://en.wikipedia.org/wiki/Key–value_database), and the users
(usually salespeople) are its
[DBAs](https://en.wikipedia.org/wiki/Database_administrator). Each of a CRM's
seemingly-simple models might have infinitely many custom fields defined by the
user—sometimes more than one with the same name! Each field can be one of any
number of types, including compound types composed of other fields! And, of
course, each record can be linked to one or more of any other type of record,
and there's nothing to stop a custom field from defining additional
associations!

As if that weren't enough, a CRM needs to serve as an authoritative source of
record for a company's prospects, customers, and contacts despite the fact that
its interactions with those people occur in countless other systems far beyond
the CRM tool's purview. As a result, most CRMs optimize for two user experiences
that are relevant to think about for anyone hoping to integrate with them:

1. Low-friction data ingestion across numerous points of ingress: phone, e-mail,
   web, newsletter, ad networks, partner sites, etc.
2. Sophisticated sanitization, de-duplication, and merging of the data chaos
   that inevitably results from Step 1

So, if you're building a general-purpose API client or an application that
aspires to provide a comprehensive view of a CRM's data, you need to prepare for
every eventuality. To recap: every record has infinitely many nested attributes
with names you can't easily know (and which may not be unique), each field
having types defined by the user, and which could be associated with every other
record multiple times over. And you have to be careful how you store things,
since yesterday's ID for any given could be an entirely different ID tomorrow if
someone clicked "Merge" in a way you didn't expect.

And that's why this gem doesn't get fancy. It just provides a handful of actions
we find useful against Pipedrive CRM and then bails out. 🛹

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.
