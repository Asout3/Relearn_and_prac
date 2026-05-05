// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*

Exercise 4 — On-Chain Todo List
Write a contract called TodoList that does the following:

Anyone can create a task with a title
Only the task creator can complete it
Only the task creator can delete it
Anyone can view a task by its ID
Anyone can see how many tasks exist

Requirements:

Use a struct for the task — it needs: title, creator address, and a completed bool
Use a mapping to store tasks by ID
Auto-increment task IDs starting from 1
Custom error if non-creator tries to complete or delete
Emit events for task created, completed, and deleted

*/

/*
so ya we are back the basic todo list i don't know man is it harder to do todolist on chian than other web2 programing language i don't know we gonna find out.
so how we gonna track like the memory of it so ya i kinda figured out this problem is kinda similar to the previous one which isl ike a whitelist but this one is strign and got some improvement so lets see i am gonna start a time and see how many hour or minute woud this took me to solve okay.
okay it has started.
*/

/*
so i saw some new ideaa so lets me see
okay i got some idea i try to do it but my way was like really bad then i have learned from ai that i can do struct mapping i can actually do mapping sturct that is really cool that is the lesson of the day.
let me explain the code
*/

// custom error
error YouAreNotOwnerOfTheTask();
error AlreadyCompeleted();


contract onChainTodo {
    // events
    event TaskCreated(string _title, uint256 _id);
    event TaskCompleted(uint256 _id);
    event TaskDeleted(uint256 _id);

    // struct that holds all the info about the task 
    struct TodoInfo {
        string title;
        address creatorAddress;
        bool isCompleted;
    }

    // mapping struct i did like map it an id points to a new struct so i can use todoInfo as a mapping
    mapping(uint256 => TodoInfo) public todoInfo;
    // ma id
    uint256 public id = 1;
    uint256 public taksCount = 0;

    // a function that creates new task
    // _title is the title of the taks 
    // then i set it up emit and log the id
    // then increment the id
    function createTask(string memory _title) public {
       todoInfo[id] = TodoInfo(
        _title,
        msg.sender,
        false
       );

       emit TaskCreated(todoInfo[id].title, id);
       id++;
       taksCount++;
    }

    // function to mark complete a task it takes id then do its job
    // ofcourse i can use modifer to do like check if it is the owner but i wanted this
    // its easy
    function markComplete(uint256 _id) public {
        if(todoInfo[_id].isCompleted == true) revert AlreadyCompeleted();
        if(todoInfo[_id].creatorAddress != msg.sender) revert YouAreNotOwnerOfTheTask();

        emit TaskCompleted(_id);

        todoInfo[_id].isCompleted = true; 
    }

    // delete taks it just delete it
    function deleteTask(uint256 _id) public {
        // i think it doesn't matter if the task is compeleted or not
        if(todoInfo[_id].creatorAddress != msg.sender) revert YouAreNotOwnerOfTheTask();

        emit TaskDeleted(_id);

        delete todoInfo[_id];

        taksCount--;
    }


    // getter function you can understand by theri name
    function getTask(uint256 _id) public view returns (TodoInfo memory) {

        return todoInfo[_id];
    }

    function getAmountOfTask() public view returns (uint256) {
        return taksCount;
    }

}