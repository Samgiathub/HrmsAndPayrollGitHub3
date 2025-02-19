CREATE TABLE [dbo].[T0051_WebService_FingerPrint_Details] (
    [FingerPrint_ID]      NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Emp_ID]              NUMERIC (18)  NULL,
    [Emp_Full_Name]       VARCHAR (200) NULL,
    [Cmp_ID]              NUMERIC (18)  NULL,
    [FingerPrintfileName] VARCHAR (200) NULL,
    [FingerNumber]        INT           NULL,
    [SysDateTime]         DATETIME      NULL
);

