CREATE TABLE [dbo].[T0140_Travel_Settlement_Mode_Expense] (
    [Tran_ID]                   BIGINT         NOT NULL,
    [Cmp_ID]                    INT            NULL,
    [Int_ID]                    BIGINT         NULL,
    [Travel_Approval_Id]        BIGINT         NULL,
    [Travel_Set_Application_ID] BIGINT         NULL,
    [Travel_Mode]               INT            NULL,
    [From_Place]                VARCHAR (128)  NULL,
    [To_Place]                  VARCHAR (128)  NULL,
    [Mode_Name]                 NVARCHAR (300) NULL,
    [Mode_No]                   NVARCHAR (100) NULL,
    [City]                      VARCHAR (128)  NULL,
    [Check_Out_Date]            DATETIME       NULL,
    [No_Passenger]              NUMERIC (18)   NULL,
    [Booking_Date]              DATETIME       NULL,
    [Pick_Up_Address]           VARCHAR (500)  NULL,
    [Pick_Up_Time]              DATETIME       NULL,
    [Drop_Address]              VARCHAR (500)  NULL,
    [Bill_No]                   VARCHAR (50)   NULL,
    [Description]               VARCHAR (500)  NULL,
    [Visited_Flag]              BIT            CONSTRAINT [DF_T0140_Travel_Settlement_Mode_Expense_Visited_Flag] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0140_Travel_Settlement_Mode_Expense] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

