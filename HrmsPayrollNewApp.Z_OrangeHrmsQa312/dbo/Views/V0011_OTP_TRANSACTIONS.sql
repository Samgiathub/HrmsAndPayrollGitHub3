


CREATE VIEW [dbo].[V0011_OTP_TRANSACTIONS]
AS
SELECT        Otp_ID, Otp_TypeID, Emp_ID, Cmp_ID, Otp_Code, Email, MobileNo, CreatedDate, ExpiredDate, IsVerified
FROM            dbo.T0011_OTP_TRANSACTIONS WITH (NOLOCK)

