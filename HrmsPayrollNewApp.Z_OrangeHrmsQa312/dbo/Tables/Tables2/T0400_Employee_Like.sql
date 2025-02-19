CREATE TABLE [dbo].[T0400_Employee_Like] (
    [Tran_Id]           NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Emp_Id]            NUMERIC (18) NOT NULL,
    [Cmp_Id]            NUMERIC (18) NOT NULL,
    [For_date]          DATETIME     NOT NULL,
    [Emp_Like_Id]       NUMERIC (18) NOT NULL,
    [Like_Date]         DATETIME     NOT NULL,
    [Like_Flag]         TINYINT      NOT NULL,
    [Notification_Flag] TINYINT      NOT NULL,
    CONSTRAINT [PK_T0400_Employee_Like] PRIMARY KEY CLUSTERED ([Tran_Id] ASC)
);

