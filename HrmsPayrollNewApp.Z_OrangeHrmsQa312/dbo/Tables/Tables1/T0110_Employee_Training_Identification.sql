CREATE TABLE [dbo].[T0110_Employee_Training_Identification] (
    [Emp_Training_ID] NUMERIC (18) NOT NULL,
    [Emp_ID]          NUMERIC (18) NOT NULL,
    [Cmp_ID]          NUMERIC (18) NOT NULL,
    [Training_ID]     NUMERIC (18) NOT NULL,
    [Training_Year]   VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_T0110_Employee_Traininig_Requirement] PRIMARY KEY CLUSTERED ([Emp_Training_ID] ASC)
);

