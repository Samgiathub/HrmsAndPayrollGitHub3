CREATE TABLE [dbo].[T0150_EMP_Gate_Pass_INOUT_RECORD_Before_Delete] (
    [Tran_Id]        NUMERIC (18) NOT NULL,
    [cmp_Id]         NUMERIC (18) NOT NULL,
    [emp_id]         NUMERIC (18) NOT NULL,
    [For_date]       DATETIME     NOT NULL,
    [Out_Time]       DATETIME     NULL,
    [In_Time]        DATETIME     NULL,
    [Hours]          VARCHAR (10) NOT NULL,
    [Reason_id]      NUMERIC (18) NOT NULL,
    [Exempted]       TINYINT      NOT NULL,
    [IP_Address]     VARCHAR (50) NOT NULL,
    [Is_Approved]    TINYINT      NOT NULL,
    [Is_Default]     TINYINT      NOT NULL,
    [Shift_St_Time]  VARCHAR (10) NULL,
    [Shift_End_Time] VARCHAR (10) NULL,
    [App_ID]         NUMERIC (18) NULL,
    [System_date]    DATETIME     NULL,
    [User_ID]        INT          NULL
);

