CREATE TABLE [dbo].[T0080_Emp_Travel_Proof] (
    [Tracking_ID]       NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Emp_ID]            NUMERIC (18)  NOT NULL,
    [Cmp_ID]            NUMERIC (18)  NOT NULL,
    [Image_Name]        VARCHAR (50)  NOT NULL,
    [Image_Path]        VARCHAR (MAX) NOT NULL,
    [Travel_Proof_Type] INT           NOT NULL,
    [TravelApp_Code]    NUMERIC (18)  NULL,
    [Effective_Date]    DATETIME      NULL,
    [Travel_Mode]       VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([Tracking_ID] ASC) WITH (FILLFACTOR = 95)
);

