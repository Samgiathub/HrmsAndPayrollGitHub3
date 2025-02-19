CREATE TABLE [dbo].[T0095_Emp_IMEI_Details] (
    [Tran_ID]         NUMERIC (18)   NOT NULL,
    [Cmp_Id]          NUMERIC (18)   NOT NULL,
    [Emp_ID]          NUMERIC (18)   NOT NULL,
    [IMEI_No]         VARCHAR (50)   NOT NULL,
    [Is_Active]       TINYINT        CONSTRAINT [DF_T0095_Emp_IMEI_Details_Is_Active] DEFAULT ((1)) NOT NULL,
    [Registered_Date] DATETIME       NULL,
    [Registered_By]   NUMERIC (18)   NULL,
    [InActive_Date]   DATETIME       NULL,
    [InActive_By]     NUMERIC (18)   NULL,
    [SysDatetime]     DATETIME       NULL,
    [DeviceID]        NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0095_Emp_IMEI_Details] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

