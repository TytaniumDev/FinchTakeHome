# Coding Notes

I'm going to keep this document as notes, chronologically, as I go through
implementing this challenge.

# Day 1

## Adding repetition

### task.dart

I wasn't sure how to handle actually triggering the "reset" initially, but I saw
that `energy_manager.dart` has a `resetForNewDay` function, so I knew I could
proably copy the logic over to `task_manager.dart` as long as I knew when to
reset.

I added a list of DateTimes to a Task which can be used to represent days of the
week, which covers both daily repetition (all 7 days in list) or specific days
for weekly repetition. DateTime has constants like .monday and nice utilities to
compare the current DateTime to that constant to see if it's that day of the
week. I then added the appropriate `repeatDays` fields to the rest of the Task
class.

### task_service.dart

It looks like `getTasksForDay` is set up to do just what I need for repetition,
so I'll likely modify that or something that calls it. I also notice that `Day`
has a `dailyTasks` field that looks useful.

I modified `createTask` to allow for the service to create repeats on a Task
object. I need to do some additional modification here because when the user
creates a repeated task, the task shouldn't show up until the first day it
repeats on. I think I need to modify targetDate to not always be right now, or
the date given in the call.

-- It's at this point I got a bit stuck on figuring out how exactly `Day`s get
populated with tasks, and where I would add the logic for adding repeated tasks
to a given `Day`. It would be impossible to pre-populate all `Day`s with the
repeated tasks, and would be awful to clean up if the task was removed.

### Taking a step back

While looking at how a `Day` handles tasks, I became unsure if putting
`repeatDays` inside of the `Task` class was the right approach. A "Task" from
the Day's perspective can be completed, which indicates that a repeated Task
should be a bunch of individual Task objects, each attached to a different Day.
But from the Task editing perspective, editing the currently visible Task should
change the attributes of all future (and past?) instances of that repeated Task
as well.

I don't want to completely refactor how tasks are being allocated to days for
this project, so I have to think more on how this should work. When does a Day
pick up a repeated Task? It needs to be robust, I should be able to go far in
the future and past and have the repeated Tasks show up properly, without having
to clog up the database by assigning Tasks to Days at Task creation like it does
now.

Should I put this logic in a Controller? I don't think so, because I could
attach the logic to assign a Task to the next repeated Day in completeTask but
then we still have the problem of going further in the future or past, and also
if the user doesn't complete a Task on a given day it should still show up the
next week. So that's out because it doesn't trigger at the right spot.

I have to change something in the Task class, because I need to be able to keep
a record of what days a given repeated Task was completed on... Do I need to
make a completely new RepeatedTask class that can hold the days it's been
completed on? Or some other relationship with a Day?

I just noticed that Day has a completedTaskIds field, and Task also has an
isCompleted field... we don't need both. I think I just need to remove
"completed" logic from the Task and have it be the Day's responsibility.

I want to add the functionality to undo a task completion, so I'm going to
implement that to learn the codebase a bit more and hopefully come up with a
repeated tasks solution in the meantime.

I think I want to use TaskService's getTasksForDay, as it is what is called when
a Task is "reset" so it is probably well supported already.

#### Note: I feel like getTasksForDay shouldn't be using the DayService for anything. That logic feels like it belongs in a higher layer (the managers?)

I want to be able to get just repeated tasks in getTasksForDay and then see if
they repeat on the given day and add them to that day if they aren't already
there. But that would require another Task box or a different RepeatedTask class
possibly? Or, I could do the bad and inefficient thing and just grab all Tasks
every time we call getTasksForDay. Actually, it's unlikely the user would be
able to add SO MANY tasks that the db transaction to get all of them would cause
a noticeable slowdown. I'm going to go with the grab all approach and make a
note.

### task_service.dart

I ended up going with editing the getCurrentDayTasks to fill the day with any
repeat tasks. It grabs ALL tasks, which could be risky with lots of tasks in the
db, but I think it's safe for this application because all tasks are
user-entered so there can't be an absurdly large amount of them. It then filters
those tasks to any that ahve a repeat weekday that matches the given day's
weekday, and adds it to the task list for that day.

This change also necessitates deprecating the "isCompleted" field on the Task,
since it's no longer accurate with a repeating Task. The Day already has the
notion of a completed task for the day, so we're moving to using that instead.

### task_manager.dart

I feel like a lot of the logic in task_service.dart should live here instead? But for now I'm just going to make a note of it and move on. The task_service.dart code was already off-script a bit with its DayService access.

I just added the repeatDays param to some of the CRUD methods.


## UI

### task_form.dart

I need to add the ability to set a repeat on the task creation form popup.
The popup is already really tiny, so this will be a bit of an adventure.

I'm just going to copy the Weekly repeat widget from the Finch app. It's pretty compact so it'll work nicely in the constrained space of the current popup without completely redoing the UI to be a fullscreen or bottom sheet experience.

I'm making a new Stateful widget for the row of repeat days. The app doesn't appear to be using Material 3, so I think I'm going to use ToggleButtons to get a lot of the functionality for free, I think.

Nah, ToggleButtons isn't worth it. I'll just use some sort of Row.

I do need to add a slider thing to swap between no repeat, daily repeat, and weekly repeat. I'll use a cupertino sliding segment control because it looks the closest, but in a real app I'd probably just hand implement it to match the design system better.

All of these need to be extensions of FormField to get the auto saving functionality and to integrate well into the current task form.

I'd like to improve the WeekdayButton and DayRepeatFormField widgets, they don't really match the style of the rest of the app. I think I'd need to go with a non-ToggleButtons approach.

I managed to get the task creation working and manually validated that the day repetition code works! I just need to fix the task_list.dart to use the Day's version of a completed task instead of the Task's deprecated version of it.

#### Stopping on the first day, time elapsed: 3 hours 43 mins

# Day 2

I'm going to start with trying to fix the task_list.dart's version of a "complete task" to have the Day be the source of truth.
That's actually more complicated than I thought, the task list only relies on the TaskManager (correctly) so I kinda need to have the task itself be the source of truth.

I checked the Finch app to see how repeats are handled, and if looks like if a task is completed, editing the task doesn't change the past completed ones, but it does change the future ones. It's like once a task is completed, it locks it in to that day forever.

## Repeating Tasks

### task_list.dart, day.dart, day_manager.dart

I added a list of the completed task ids to the day manager so we can rebuild the UI based on that info. I then also added a select listener in task_list that grabs JUST the completed task ids, and then passed the completed state to the task card.

I don't super love this because it adds some business logic (kinda?) to the UI, in that the TaskList now has knowledge that a "completed task id" means that the task is "completed". It's not that much of a stretch, so I'm fine with it for now.

## Promoting recurring tasks

### task_controller.dart
I'm going to use the rainbow stones as the way to entice the user to make recurring goals. Filling the day's energy is relatively trivial and would happen normally, and has a ceiling to the amount of reward the user will feel.
I'm assuming rainbow stones act like they do in the Finch app and are used as a sort of extra currency you can use to improve your experience in the app. There's a business cost and diminishing returns if we're too generous with them, so I'm going to just add 2 stones for every repeated task a user completes. That value could be adjusted, it's hard to tell without knowing how much we value the daily sign on (+5 stones). I could see upping the value to 5 stones or something like that.

Nevermind, I see that productivity tasks award 10 stones for completion, so I think 5 stones per repeated task completion is a fine balance. That way we keep with nice multiples of 5 as well.
I made this change in the home_controller.dart, and I found more confusing architectural decisions? Or just bugs? The home controller has a complete task function that doesn't appear to be called, but that's where the stone rewards are happening.

I'm going to make the TaskList use the homeController instead of the taskController? Or I'll add the homeController functionality to the TaskController, which actually does seem better. The gaining of stones etc shouldn't be based on if the user is "on the home screen" or not.
Yeah, the home controller version of the completeTask is never used, I'm just going to delete it and move the relevant stuff to task controller.

Right now I'm removing stones/pet energy/etc when undoing a task, but it should really just be setting the next completion of that task to give 0 of that resource. There are better ways to do this, but I'm not going to spend the time to figure it out currently as it's not a main objective.

### Bug Fix

Fixed a bug in energy_indicator.dart, it was using the dayManager's total energy field instead of the pet's current energy field for displaying the total energy, so it would often overflow/underflow. 
Again, an indication that architecturaly the concept of a "Day" may be too large or it needs to have more referential relationships to other data and not maintain its own version of stuff, like tasks and pet data.

### UI improvements

Now that the logic for the stones for repeated tasks is working, I'll update the UI to let the user know it's a benefit. It'll be added to the task creation screen.

Relatively straightforward to add the text with a nice textspan for the rainbow stones icon.

I think this is all done now! Just need to write tests and a summary of what changes I made.

#### Day 2 time: 1 hour 41 mins

# Total time: 5.4 hours

# Day 2 Part 2 - Tests

Spending some time writing/fixing tests before introducing AI to do some larger changes. A few of the tests failed because they had timing race conditions, so I fixed those by checking for a timestamp >= the current time rather than a strict >. A larger check would be needed, I'm sure there are usages in other tests and I didn't do a full search for the issue.

I'm writing tests for the task_service now that getTasksForDay injects repeated tasks into the day at that point rather than before.

I am still missing tests for some new functions I wrote, but I'm out of the recommended time and the tests are trivial to write, as they're just for the uncomplete/subtract functions I added for undoing task completion.

-- Time spent writing and updating tests: 30min

#### Day 2 part 2 time: 30 mins

# Total time with tests: 5.9 hours