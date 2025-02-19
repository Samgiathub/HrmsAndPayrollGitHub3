CREATE TABLE [dbo].[T0120_HRMS_Induction_Details] (
    [Induction_ID]      INT           NOT NULL,
    [Cmp_ID]            INT           NOT NULL,
    [Emp_ID]            VARCHAR (MAX) NOT NULL,
    [Schedule_Date]     DATETIME      NOT NULL,
    [From_Time]         DATETIME      NULL,
    [To_Time]           DATETIME      NULL,
    [Dept_Id]           INT           NOT NULL,
    [Contact_Person_ID] VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_T0120_HRMS_Induction_Details] PRIMARY KEY CLUSTERED ([Induction_ID] ASC) WITH (FILLFACTOR = 95)
);

