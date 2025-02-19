CREATE TABLE [dbo].[Salary_Period] (
    [Salary_Period_Id] NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [month]            NUMERIC (18) NOT NULL,
    [year]             NUMERIC (18) NOT NULL,
    [from_date]        DATETIME     NOT NULL,
    [end_date]         DATETIME     NOT NULL
);

