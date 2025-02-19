CREATE TABLE [dbo].[T0110_VEHICLE_REGISTRATION_DETAILS] (
    [Vehicle_Registration_ID] INT            IDENTITY (1, 1) NOT NULL,
    [Vehicle_App_ID]          INT            NOT NULL,
    [Cmp_ID]                  NUMERIC (18)   NOT NULL,
    [Emp_ID]                  NUMERIC (18)   NOT NULL,
    [Vehicle_ID]              INT            NOT NULL,
    [Engine_No]               VARCHAR (50)   NOT NULL,
    [Chasis_No]               VARCHAR (50)   NOT NULL,
    [Road_Tax]                FLOAT (53)     NOT NULL,
    [Registration_Charges]    FLOAT (53)     NOT NULL,
    [Insurance_Charges]       FLOAT (53)     NOT NULL,
    [Invoice_No]              VARCHAR (50)   NOT NULL,
    [Invoice_Amount]          FLOAT (53)     NULL,
    [Vehicle_Docs]            VARCHAR (MAX)  NOT NULL,
    [Transaction_By]          INT            NOT NULL,
    [Transaction_Date]        DATETIME       NOT NULL,
    [Invoice_Date]            DATETIME       NULL,
    [Payment_Ack_Details]     VARCHAR (1000) NULL,
    CONSTRAINT [PK_T0110_VEHICLE_REGISTRATION_DETAILS] PRIMARY KEY CLUSTERED ([Vehicle_Registration_ID] ASC),
    CONSTRAINT [FK_T0110_VEHICLE_REGISTRATION_DETAILS_T0040_VEHICLE_TYPE_MASTER] FOREIGN KEY ([Vehicle_ID]) REFERENCES [dbo].[T0040_VEHICLE_TYPE_MASTER] ([Vehicle_ID]),
    CONSTRAINT [FK_T0110_VEHICLE_REGISTRATION_DETAILS_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0110_VEHICLE_REGISTRATION_DETAILS_T0100_VEHICLE_APPLICATION] FOREIGN KEY ([Vehicle_App_ID]) REFERENCES [dbo].[T0100_VEHICLE_APPLICATION] ([Vehicle_App_ID])
);

