CREATE TABLE [dbo].[T0130_Travel_Approval_Other_Mode_Detail] (
    [Tran_ID]                         BIGINT         NOT NULL,
    [Cmp_ID]                          INT            NULL,
    [Travel_Approval_Other_Detail_ID] BIGINT         NULL,
    [Travel_Approval_ID]              BIGINT         NULL,
    [Travel_Mode]                     INT            NULL,
    [From_Place]                      VARCHAR (128)  NULL,
    [To_Place]                        VARCHAR (128)  NULL,
    [Mode_Name]                       NVARCHAR (300) NULL,
    [Mode_No]                         NVARCHAR (100) NULL,
    [City]                            VARCHAR (128)  NULL,
    [Check_Out_Date]                  DATETIME       NULL,
    [No_Passenger]                    NUMERIC (18)   NULL,
    [Booking_Date]                    DATETIME       NULL,
    [Pick_Up_Address]                 VARCHAR (500)  NULL,
    [Pick_Up_Time]                    DATETIME       NULL,
    [Drop_Address]                    VARCHAR (500)  NULL,
    [Bill_No]                         VARCHAR (50)   NULL,
    [Description]                     VARCHAR (500)  NULL,
    CONSTRAINT [PK_T0130_Travel_Approval_Other_Mode_Detail] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

