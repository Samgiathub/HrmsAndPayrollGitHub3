CREATE TABLE [dbo].[KPMS_T0100_Emp_Role_Assign] (
    [Emp_Role_Id] INT IDENTITY (1, 1) NOT NULL,
    [Role_Id]     INT NULL,
    [Emp_Id]      INT NULL,
    [IsActive]    BIT DEFAULT ((0)) NULL,
    [Cmp_Id]      INT NULL,
    CONSTRAINT [PK_KPMS_T0100_Emp_Role_Assign] PRIMARY KEY CLUSTERED ([Emp_Role_Id] ASC)
);

