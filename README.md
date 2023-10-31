# SQL Practice

<pre>
Some SQL Exercises
  
Each Database folder contains these folders
  _scripts      #Contains scripts for setting up the db and filling it with base data.
  Exercises     #Contains sql files with comments describing the excercise.
  Solutions     #Contains the solution to said exercise files.
Optional
  _extra        #Extra information that can be handy. (I couldn't be arsed transforming it to an exercise)

  
.
│
└───<a href="./Northwind">Northwind</a>
    │
    ├───<a href="./Northwind/Exercises">Exercises</a>
    │
    ├───<a href="./Northwind/Solutions">Solutions</a>
    │
    ├───<a href="./Northwind/_extra">_extra</a>
    │
    └───<a href="./Northwind/_scripts">_scripts</a>

</pre>

##  Prerequisites
1. Have MS SQL Management Studio (SSMS)


## 'Manual'
1. Fork or download this repo.
2. Choose a database you want to work in.
3. Navigate to _scipts
4. Double click on the sql file Create_{db_name}.sql or drag it in SSMS.
5. if the directory contains a .csv file you need to set the variable @InitialPath in the sql script file.

| <img src="https://i.imgur.com/8HmLtlF.gif">   | 
| :--- | 
| I got these create/insert scripts from school but they are shit performance wise. (u press execute and takes 2 mins to insert 300+- rows) <br /> To combat this I've transformed it so it makes use of bulk inserts, yes I know that bulk inserts ignore constraints but you dont really need them at initialization with proper data. |

       
6. Press F5 or press the execute button.
 <img src="https://i.imgur.com/51RlWrf.jpg">
  
7. Navigate to Exercises and pick a file you want to solve.\
       Note: dont forget to switch databases by either using the 'use' command or by using the dropdown list.
<img src="https://i.imgur.com/WhihZs4.jpg">
  

## Me
<img src="https://i.imgur.com/qXyjT2u.jpg" width="400">
