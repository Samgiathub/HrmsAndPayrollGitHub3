CREATE TABLE [dbo].[T0080_Get_EMP_Data_join_left] (
    [RowId]                INT          IDENTITY (1, 1) NOT NULL,
    [CmpCode]              VARCHAR (50) NULL,
    [Emp_id]               NUMERIC (18) NULL,
    [firstname]            VARCHAR (50) NULL,
    [lastname]             VARCHAR (50) NULL,
    [emailaddress]         VARCHAR (50) NULL,
    [designation]          VARCHAR (50) NULL,
    [branchname]           VARCHAR (50) NULL,
    [employeecode]         NUMERIC (18) NULL,
    [buisness]             VARCHAR (50) NULL,
    [associtedphoneNumber] VARCHAR (50) NULL,
    [manageruser]          VARCHAR (50) NULL,
    [deactivation]         VARCHAR (50) NULL,
    [leftdate]             DATETIME     NULL,
    [status]               VARCHAR (50) NULL,
    [Created_Date]         DATETIME     NULL,
    [Modify_Date]          DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([RowId] ASC) WITH (FILLFACTOR = 95)
);

