-- =============================================
-- Author:		Niraj Parmar
-- Create date: 23/12/2021
-- Description:	To get Time Duration
-- =============================================
CREATE FUNCTION GET_DATETIME_DIFF(@date1 DATETIME, @date2 DATETIME)
RETURNS varchar(100)
AS
BEGIN
	-- DOES NOT ACCOUNT FOR LEAP YEARS
	DECLARE @result VARCHAR(100);
	DECLARE @years INT, @months INT, @days INT,
		@hours INT, @minutes INT, @seconds INT, @milliseconds INT;

	SELECT @days=DATEDIFF(dd, @date1, @date2)
	IF DATEADD(dd, -@days, @date2) < @date1 
	SELECT @days=@days-1
	SET @date2= DATEADD(dd, -@days, @date2)

	SELECT @hours=DATEDIFF(hh, @date1, @date2)
	IF DATEADD(hh, -@hours, @date2) < @date1 
	SELECT @hours=@hours-1
	SET @date2= DATEADD(hh, -@hours, @date2)

	SELECT @minutes=DATEDIFF(mi, @date1, @date2)
	IF DATEADD(mi, -@minutes, @date2) < @date1 
	SELECT @minutes=@minutes-1
	SET @date2= DATEADD(mi, -@minutes, @date2)

	SET @result = CONCAT(@days,' Days ', @hours, ' Hours ', @minutes, ' Minutes')

	--CONCAT(
	--FLOOR(DATEDIFF(DAY, TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date)), ' Days ',
	--FLOOR(DATEDIFF(HOUR, TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date) - (DATEDIFF(DAY, TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date) * 24)), ' Hours ',
	--FLOOR(DATEDIFF(MINUTE, TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date) - (DATEDIFF(HOUR, TA.Ticket_Gen_Date, T_Apr.Ticket_Apr_Date) * 60)), ' Minutes') As Total_Time_Taken,
	return @result
END

