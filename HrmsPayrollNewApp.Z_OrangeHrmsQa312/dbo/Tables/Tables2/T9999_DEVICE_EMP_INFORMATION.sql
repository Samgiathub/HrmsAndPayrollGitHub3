CREATE TABLE [dbo].[T9999_DEVICE_EMP_INFORMATION] (
    [Data_Tran_ID]    NUMERIC (18) NOT NULL,
    [IP_Address]      VARCHAR (50) NOT NULL,
    [Enroll_No]       NUMERIC (18) NOT NULL,
    [Finger_ID]       NUMERIC (18) NOT NULL,
    [Finger_Template] IMAGE        NOT NULL,
    [PWD]             VARCHAR (10) NOT NULL,
    [Priviledge]      NUMERIC (3)  NOT NULL,
    [Name]            VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_T9999_DEVICE_EMP_INFORMATION] PRIMARY KEY CLUSTERED ([Data_Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

