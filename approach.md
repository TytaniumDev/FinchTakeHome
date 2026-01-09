# Approach

Completed in 5.9 hours.
[Code comparison](https://github.com/TytaniumDev/FinchTakeHome/compare/2bc64e6..d6bed6b)

## Notes

My detailed thoughts are in coding_notes.md.
No AI was used for the initial coding portion, other than whatever VSCode uses for autocomplete now. Using AI would've sped this up significantly and allowed me to refactor more of the code, but I left this as a constraint for myself. I'll use AI to do some extra credit work afterward.

## Overall approach

My goal with my implementation was to leave things as untouched as possible, since this was a large-ish codebase with complexity that I likely wouldn't be aware of initially.

I wanted to focus my efforts on matching exactly the requirements, in a sort of MVP fashion due to the time constraints, and the fact that it's a take home exercise and not a real app.

Because of both of these elements, I made tradeoffs in my implementation that I'll try to call out in each section. I'll also try to call out what I'd change now having more knowledge of the codebase.

## Implementing the Requirements

### Recurring Tasks

I ended up adding a `repeatDayIndices` List to the `Task` class. This is intended to consist of something between `[]` and `[1,2,3,4,5,6,7]` where the ints are the constant weekday values from `DateTime`. 

I went with adding a field to the Task because I was treating a Task as an object that is created via the Task creation UI and is editable over time. A single Task can be added to multiple days, and the Day will track if that task id has been completed on that day.

The downside of this approach was that it made the `isCompleted` field on the Task essentially unusable. I was only comfortable with doing this (and deprecating `isCompleted`) because the `Day` already had a list of completed Task ids, so I figured I could use that to track Task completion per Day instead, which fit better with my mental model.

Along with this change, I had to figure out how to actually get the Day to know it had these repeating Tasks. I spent a lot of time here, and made the following requirements for myself:

* Preassigning all Tasks to all future Days at Task creation time is not a valid solution because it would have to assign out to infinity.
* Adding a complex Task creation management system that would create Tasks for days after X period of time or X task completions would leave holes in the implementation, especially because there can be an infinite amount of time between app launches.

Because of this, I knew I wanted to do some just-in-time assignment of Tasks to a Day. I ended up modifying `getCurrentDayTasks` in `TaskService` because the function already existed and fit exactly what I wanted to do - inject tasks for a given day. 
I didn't love this, because it didn't feel like something a `Service` class should be doing, architecturally. I felt like it should probably live in the `Manager` layer, but this function was already calling `DayService` so I made the call to just add on to reduce complexity for this exercise.

*I had more time, doing the refactor to fix `getCurrentDayTasks` would be at the top of my list.*

For the UI portion, I just added a nice CupertinoSlider and ToggleButtons to handle adding the repeating days to a Task at creation time. If I had more time, I'd build a custom solution instead of using the CupertinoSlider, and I'd move away from ToggleButtons and to a custom solution as well, both to gain flexibility in theming to get a more consistent look and feel to the rest of the app.

#### Different approach

If I didn't have the self-imposed constraint of leaving as much of the code as-is as possible, I think I would've created a `RecurringTask` class that either shares a base class with `Task` or something like that. That way we could've kept the existing Task logic but then also handle RecurringTasks in their own way without trying to shove it in with a normal Task.

But really, as I cover in the *Other significant notes* section, I think the proper fix is to just detangle what a Day means in the app.

### Promoting users to create recurring tasks

I interpreted this requirement as a bit more of a product/UX challenge than a pure engineering one.

Assuming that was the case, I decided to entice the user to create recurring tasks by giving some additional bonus to a recurring task. I saw my options as follows:

1. Entice recurring task *CREATION*
2. Reward *recurring task completion*, like a streak
3. Reward completing any task that is recurring

I wanted the users to actually do the tasks they create, not just create a bunch to get rewards and then never complete them, which ruled out option 1.

Options 2 and 3 were close, but I felt like a flat completion reward had a better chance of getting the user to complete the tasks, even if they have an off day every once in a while. I was wary of the streak because of the negative feelings that can occur when you break it.


## Other significant notes

### Architecture

I really like the app architecture at a high level, but there's some weirdness around `Day`s. I think the relationships between a `Day` and the other data objects isn't quite clear.

Right now a `Day` has a list of Task objects it owns, but then a list of IDs of tasks that are completed on that day. This is inconsistent, I'd prefer it always be ID referenced.
Having a Day literally contain Tasks makes the Task box a confusing entity. Why are we storing tasks on their own when the Day contains them as well? I'm assuming this is duplicating data in the db, but I didn't look into it.

### Testing

I wrote and update a few tests, but I'd have more test coverage if this were a real production app. I didn't put a lot of time or effort into creating the tests, because I wanted to focus on the actual implementation.

I'd be happy to explain my testing strategy if you'd like, but I don't think there's much unique there. I'd want to cover the possible use cases from all sides, and include some higher level integration type tests.
