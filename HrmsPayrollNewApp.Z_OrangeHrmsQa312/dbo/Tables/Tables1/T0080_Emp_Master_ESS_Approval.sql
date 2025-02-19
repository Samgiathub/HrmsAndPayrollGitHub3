CREATE TABLE [dbo].[T0080_Emp_Master_ESS_Approval] (
    [EAID]                    INT             IDENTITY (1, 1) NOT NULL,
    [Emp_id]                  INT             NULL,
    [Emp_Fav_Sport_id]        NVARCHAR (500)  NULL,
    [Emp_Fav_Sport_Name]      NVARCHAR (1000) NULL,
    [Emp_Hobby_id]            NVARCHAR (500)  NULL,
    [Emp_Hobby_Name]          NVARCHAR (1000) NULL,
    [Emp_Fav_Food]            NVARCHAR (100)  NULL,
    [Emp_Fav_Restro]          NVARCHAR (100)  NULL,
    [Emp_Fav_Trv_Destination] NVARCHAR (100)  NULL,
    [Emp_Fav_Festival]        NVARCHAR (100)  NULL,
    [Emp_Fav_SportPerson]     NVARCHAR (100)  NULL,
    [Emp_Fav_Singer]          NVARCHAR (100)  NULL,
    [CDTM]                    DATETIME        DEFAULT (getdate()) NULL,
    [UDTM]                    DATETIME        NULL,
    [LogDT]                   INT             NULL,
    [IsApproved]              INT             NULL,
    [Cmp_id]                  INT             NULL,
    PRIMARY KEY CLUSTERED ([EAID] ASC) WITH (FILLFACTOR = 95)
);

