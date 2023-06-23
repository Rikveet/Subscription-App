# Subscription app

A flutter project to help manage attendees/subscribers for your service.

## Features

- Realtime db to show updated and new added attendees instantly.
- Searchable tables.
- Export the list of attendees to csv.
- Ability to add notes to the attendee.
- Realtime db to manage employees/managers.
- Ability to allow multiple employees/managers.
- Ability to only allow authorized users to register.
- Ability to have 3 tier roles **Admin**, **Editor** and **Viewer**.
  - Viewer: An authorized user with no roles. For people who only need to view the List of attendees.
  - Editor: An authorized user with role Editor. For people who need to add/update/remove attendees.
  - Admin: An authorized user with role Admin. Only this role can authorize/update/remove employee list.

## TODO
- [ ] Implement change password functionality.
- [ ] Implement password reset functionality.
- [ ] Create Row level security for field validation on **INSERT** to ***attendee*** and ***authorized_user***.
- [x] Complete field validation for inputs in the flutter app.
- [ ] Implement sorting functionality for attendees and authorized users table view.
- [ ] Implement ***reminders*** db to allow editors to generate reminders using attendee emails.
- [ ] Implement export to csv for attendees table.
- [ ] Implement google api to update google sheets upon **INSERT** to ***attendee*** db.

## How to implement for your own app

- This application uses Supabase as backend service.
- To connect to your db create a .env file in the root folder and add **SUPABASE_URL**="your supabase db url", **SUPABASE_KEY**="your supabase anon_key".
- This application requires two tables ***attendee*** and ***authorized_user***
- Schema of ***attendee*** table
![image](https://github.com/Rikveet/Subscription-App/assets/62815232/36ed33a4-c184-4dfc-9630-72beff1cc15e)
- Schema of ***authorized_user***
![image](https://github.com/Rikveet/Subscription-App/assets/62815232/9eb85e84-8728-48b3-a03c-dd8eb97b2a72)
- You can generate the ***attendee*** table with the following code. You can run the snippets in the sql editor section.
  ```SQL
    create table
      public.attendee (
        id bigint generated by default as identity not null,
        created_at timestamp with time zone null default now(),
        firstName text not null,
        email text not null,
        phoneNumber bigint null,
        lastName text not null,
        city text not null,
        constraint attendee_pkey primary key (id),
        constraint attendee_email_key unique (email)
      ) tablespace pg_default;
  ```
- Next we would require for row level security to make sure db is secure from anon requests
  - Following snippet checks if requesting user is an editor
    ```SQL
    (EXISTS ( 
    SELECT 1 
    FROM authorized_user authorized_user_1 
    WHERE ( (authorized_user_1.email = auth.email()) AND ('EDITOR'::user_permission = ANY (authorized_user_1.permissions)))
    ))
    ```
  - Make sure the targeted role is authenticated. This will ensure that anon person with url and key to db cannot view/update/add/delete the data.
  - Use this snippet to generate a boolean response for following requests **INSERT**, **DELETE**, **UPDATE**
  - For **SELECT** you can write true if you want all authenticated accounts to be able to view the ***attendee*** table. It is true for this code version as it allows access to people who only need to view the attendee list.
- You can generate the ***authorized_user*** table with the following code, this will also generate the required type ***user_permission***.
- ***user_permission***
  ```SQL
    CREATE TYPE user_permission AS ENUM('ADMIN', 'EDITOR');
  ```
- ***authorized_user***
  ```SQL
    create table
      public.authorized_user (
        id bigint generated by default as identity not null,
        created_at timestamp with time zone null default now(),
        name text not null,
        email text not null,
        permissions array not null default '{}'::user_permission[],
        constraint authorized_users_pkey primary key (id),
        constraint authorized_user_email_key unique (email)
      ) tablespace pg_default;
  ```
- As only admins can make changes to the ***authorized_user*** db. We need to setup row level policies.
  - Following snippet checks if requesting user is an admin
    ```SQL
    (EXISTS ( 
    SELECT 1 
    FROM authorized_user authorized_user_1 
    WHERE ( (authorized_user_1.email = auth.email()) AND ('ADMIN'::user_permission = ANY (authorized_user_1.permissions)))
    ))
    ```
  - Make sure the targeted role is authenticated. This will ensure that anon person with url and key to db cannot view/update/add/delete the data.
  - Use this snippet to generate a boolean response for following requests **INSERT**, **DELETE**, **UPDATE**
  - For **SELECT** you can write true if you want all authenticated accounts to be able to view the ***authorized_user*** table. It is true for this code version as it will be easier to find out who the admin is for employees.
- Finally we need to setup a trigger to check if registering user is authorized to register.
  - First we need to generate a function that returns a trigger.
  - Head over to database section of your dashboard.
  - Functions -> Create a new function.
    - Name: is_authorized_user
    - Return type: trigger
    - Definition: 
      ```SQL
        begin
          IF (select exists(select 1 from public.authorized_user where email like NEW.email)) THEN
              RETURN NEW;
          END IF;

          raise exception 'Not authorized';
        end;
      ```
   - Triggers -> Create a new trigger.
    - Name: is_authorized_user
    - Table: authorized_user
    - Event: insert
    - Trigger type: before event
    - Function to trigger: is_authorized_user
