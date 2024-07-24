# Library Management System Using T-SQL

This project implements a comprehensive library management system using T-SQL. The system is designed to help librarians manage their catalog of items, members, and loans effectively. The implementation includes a detailed database model and various stored procedures, functions, and triggers to ensure the efficient operation of the library system.

## Features

- **Catalog Management**: Search and manage the library's catalog of items, including books, journals, DVDs, and other media.
- **Member Management**: Add, update, and manage library members' information.
- **Loan Management**: Record and manage the loan of items to members, including due dates and return dates.
- **Fine Management**: Automatically calculate and manage overdue fines for late returns.
- **Reservation System**: Allow members to reserve items and manage reservations.

## Database Design

The database model consists of several tables, each designed to store specific information:

- **Address Table**: Stores address details of members.
- **Author Table**: Stores information about authors.
- **Category Table**: Stores categories for classification of items.
- **ItemType Table**: Stores types of items (books, journals, DVDs, etc.).
- **Item Table**: Stores information about library items.
- **Publisher Table**: Stores information about publishers.
- **ItemStatus Table**: Stores statuses of items (available, on loan, etc.).
- **ItemCopy Table**: Stores specific copies of items.
- **MemberStatus Table**: Stores statuses of members.
- **Member Table**: Stores member information.
- **Loan Table**: Records details of item loans.
- **Fine Table**: Manages overdue fines.
- **ItemAuthor Table**: Associates items with authors.
- **Login Table**: Stores login credentials of members.
- **PaymentMethod Table**: Stores payment methods.
- **Repayment Table**: Records repayments of fines.
- **ReservationStatus Table**: Stores statuses of reservations.
- **Reservation Table**: Manages reservations.

## Stored Procedures and Functions

The project includes several stored procedures and functions to facilitate various operations:

- **uspSearchItems**: Procedure to search the catalog for items by title.
- **uf_LoanItemWithDuedate**: Function to list items with due dates within the next five days.
- **uspAddNewMember**: Procedure to add a new member to the library database.
- **uspUpdateExistingMember**: Procedure to update existing member information.
- **LoanHistoryView**: View to display the loan history of items.
- **UpdateItemStatus**: Trigger to automatically update the status of items when they are returned.
- **uf_GetTotalNumberOfLoanByDate**: Function to get the total number of loans on a particular date.
- **uspCalculateFineDaily**: Procedure to calculate overdue fines for late returns.
- **GetInactiveMember**: Trigger to manage inactive members.
- **uf_LostRemovedItem**: Function to list items that are lost or removed.
- **uspAddNewPayment**: Procedure to add a repayment.
- **uspAddNewLoan**: Procedure to add a loan.

## Installation and Setup

1. **Clone the Repository**:
    ```sh
    git clone <repository-url>
    cd <repository-directory>
    ```

2. **Set Up the Database**:
    - Use the provided T-SQL script `Library Management system using T-SQL.sql` to create the database and tables.
    - Run the script in your SQL Server Management Studio to set up the database schema and initial data.

3. **Populate the Database**:
    - Insert initial data into the tables using the provided insert statements.

4. **Execute Stored Procedures and Functions**:
    - Use the stored procedures and functions to manage the library operations as described.

## Usage

The library management system supports the following operations:

- **Search Catalog**: Search for items in the catalog by title.
- **Manage Members**: Add and update member information.
- **Loan Management**: Record item loans and returns.
- **Manage Fines**: Automatically calculate and manage overdue fines.
- **Reservations**: Allow members to reserve items and manage reservations.

## Data Privacy and Security

The system ensures data privacy and security through the following measures:

- **Authentication and Authorization**: Restricted access to the database through SQL Server Authentication.
- **Role-based Access Control**: Assign specific privileges to users based on their roles.
- **Data Encryption**: Encrypt sensitive data, such as passwords, using SHA2_512 encryption.

## Conclusion

This project demonstrates the design and implementation of a library management system using T-SQL. The system is designed to be flexible and scalable, meeting the needs of both educational and private libraries. The use of stored procedures, functions, and triggers ensures efficient and secure operations, making it a valuable tool for librarians.

For more detailed information, please refer to the project report included in the repository.
