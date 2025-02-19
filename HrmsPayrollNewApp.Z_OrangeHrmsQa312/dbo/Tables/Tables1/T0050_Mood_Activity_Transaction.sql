CREATE TABLE [dbo].[T0050_Mood_Activity_Transaction] (
    [Mood_Activity_Id] INT           IDENTITY (1, 1) NOT NULL,
    [Emp_Id]           NUMERIC (18)  NULL,
    [Cmp_Id]           NUMERIC (18)  NULL,
    [Activity]         NUMERIC (18)  NULL,
    [Mood_Details]     VARCHAR (100) NULL,
    [System_Date]      DATETIME      NULL
);

