CREATE TABLE [dbo].[T0000_SMS_Logs] (
    [SMS_Tran_Id] NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Emp_Id]      NUMERIC (18)  NOT NULL,
    [SMS_Text]    VARCHAR (160) NOT NULL,
    [Type]        VARCHAR (30)  NOT NULL,
    [Mobile_No]   NUMERIC (18)  NOT NULL,
    [System_Date] DATETIME      NOT NULL,
    CONSTRAINT [PK_T0000_SMS_Logs] PRIMARY KEY CLUSTERED ([SMS_Tran_Id] ASC)
);

