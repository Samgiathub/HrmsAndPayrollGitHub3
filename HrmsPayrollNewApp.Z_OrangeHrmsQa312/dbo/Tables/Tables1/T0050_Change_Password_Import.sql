CREATE TABLE [dbo].[T0050_Change_Password_Import] (
    [Sr_No]       NUMERIC (18)   NOT NULL,
    [Emp_Code]    VARCHAR (1000) NULL,
    [Cmp_ID]      NUMERIC (18)   NULL,
    [Password]    VARCHAR (1000) NULL,
    [Login_ID]    NUMERIC (18)   NULL,
    [Change_Date] DATETIME       NULL,
    [IP_Address]  VARCHAR (100)  NULL,
    PRIMARY KEY CLUSTERED ([Sr_No] ASC) WITH (FILLFACTOR = 80)
);

