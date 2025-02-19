CREATE TABLE [dbo].[T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL] (
    [Tran_ID]                         BIGINT         NOT NULL,
    [Cmp_ID]                          INT            NULL,
    [Travel_Approval_Other_Detail_ID] BIGINT         NULL,
    [Other_Tran_ID]                   BIGINT         NOT NULL,
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
    [System_Date]                     DATETIME       NULL,
    CONSTRAINT [PK_T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

