# Neo4j and SQL Queries Comparison
A Study In Neo4j. As part of a course assignment and using data from the Eurovision contests (Originally an Excel file), I built two databases in Neo4j and SQL. I thought of and wrote queries for both SQL and Neo4j and compared the two and their performances.

Contents of this repository:
  - Databases - Contains both the Neo4j and SQL databases
    - Empty Databases - The empty SQL database, cypher recipes for populating the graph database, SQL forms for creating the database tables
  - Queries - Includes the queries for the Neo4j and SQL databases
  - Scripts
      - ExcelToDatabase.py - A Python script to format the original Excel file for input in the SQL database
      - ExcelToGraph.py - A Python script that inserts the data from the Excel file to the Graph database. A lot of these functions were swapped in favour of the cypher script in the 'Empty Databases' folder
