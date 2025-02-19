-- exec KPMS_prc_BindMonths 119
-- drop proc KPMS_prc_BindMonths
CREATE procedure [dbo].[KPMS_prc_BindMonths]
@rCmpId int
as
begin
	-- update KPMS_T0020_BatchYear_Detail set From_Date = '2021-04-01',To_Date = '2022-03-31',IsDefault = 1 where Batch_Detail_Id = 2
	declare @lResult varchar(max) = '<option value="0"> -- Select -- </option>'
	select @lResult = @lResult + '<option value="' + convert(varchar,Month(DATEADD(MONTH, x.number, From_Date))) + '">' + DATENAME(MONTH, DATEADD(MONTH, x.number, From_Date)) + '</option>'
	from master.dbo.spt_values x,KPMS_T0020_BatchYear_Detail	
	WHERE x.type = 'P' AND x.number <= DATEDIFF(MONTH, From_Date, To_Date)
	and IsActive = 1 and Cmp_Id = @rCmpId and IsDefault = 1

	select @lResult as Result
end