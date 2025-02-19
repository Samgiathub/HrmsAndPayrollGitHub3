CREATE TABLE [dbo].[T0110_Emp_NextIncrement_Details] (
    [Tran_Id]             INT          IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]              NUMERIC (18) NOT NULL,
    [Emp_ID]              NUMERIC (18) NOT NULL,
    [Next_Increment_Date] DATETIME     NOT NULL,
    [System_Date]         DATETIME     NOT NULL,
    [User_id]             NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0110_Emp_NextIncrement_Details] PRIMARY KEY CLUSTERED ([Tran_Id] ASC),
    CONSTRAINT [FK_T0110_Emp_NextIncrement_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

