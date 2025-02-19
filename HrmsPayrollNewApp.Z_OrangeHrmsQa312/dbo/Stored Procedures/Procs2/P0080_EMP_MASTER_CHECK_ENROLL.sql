CREATE Procedure P0080_EMP_MASTER_CHECK_ENROLL 
(
	@Cmp_ID INT,
	@Enroll_No INT
)
AS
BEGIN
	select Enroll_No,* from T0080_EMP_MASTER where cmp_id=@Cmp_ID and Enroll_No=@Enroll_No
END