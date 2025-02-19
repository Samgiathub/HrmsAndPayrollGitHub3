CREATE TABLE [dbo].[T0090_EMP_EMERGENCY_CONTACT_DETAIL_Clone] (
    [Emp_ID]         NUMERIC (18)  NOT NULL,
    [Row_ID]         NUMERIC (18)  NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Name]           VARCHAR (100) NOT NULL,
    [RelationShip]   VARCHAR (20)  NOT NULL,
    [Home_Tel_No]    VARCHAR (30)  NOT NULL,
    [Home_Mobile_No] VARCHAR (30)  NOT NULL,
    [Work_Tel_No]    VARCHAR (30)  NOT NULL,
    [System_Date]    DATETIME      NOT NULL,
    [Login_Id]       NUMERIC (18)  NOT NULL
);

