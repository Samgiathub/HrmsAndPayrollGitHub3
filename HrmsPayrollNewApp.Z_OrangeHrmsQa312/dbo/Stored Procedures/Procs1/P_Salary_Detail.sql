-- created by rohit on 24112016
CREATE PROCEDURE [dbo].[P_Salary_Detail] 
@Cmp_ID as numeric(18,0),
@Emp_id as numeric(18,0),
@Sal_Type as tinyint = 0, -- This is use for 0 as Regular Salary and 1 for Settlement Salary as Else Part
@from_date as datetime,
@to_date as datetime

AS        
SET NOCOUNT ON  
begin

if @Sal_Type=0
	begin
		select	Ms.Emp_ID,Ms.Month_End_Date,SPE.Month as int_month,SPE.Year as int_year,I.branch_id,Ms.Cmp_ID,Ms.Sal_Tran_ID,
						case when isnull(ms.Net_Amount,0) > 0  THEN  cast(isnull(CMM.Curr_Symbol,'') as NVARCHAR) + CAST(' ' AS NVARCHAR) + cast(isnull(ms.Net_Amount,0) as NVARCHAR) ELSE cast(ms.Net_Amount AS NVARCHAR) end  as Net_Amount,
						case when isnull(MEB.Net_Amount,0) > 0  THEN  cast(isnull(CMM.Curr_Symbol,'') as NVARCHAR(10)) + ' ' + cast(isnull(MEB.Net_Amount,0) as NVARCHAR(10)) ELSE cast(MEB.Net_Amount as NVARCHAR)end  as Payment_Amount,
						--ms.Net_Amount as Net_Amount,
						--MEB.Net_Amount as Payment_Amount,
						case when isnull(ms.Net_Amount,0) - isnull(MEB.Net_Amount,0) > 0  THEN  cast(isnull(CMM.Curr_Symbol,'') as NVARCHAR(10)) + ' ' + cast(isnull(ms.Net_Amount,0) - isnull(MEB.Net_Amount,0) as NVARCHAR(10)) ELSE cast((isnull(ms.Net_Amount,0) - isnull(MEB.Net_Amount,0)) AS NVARCHAR) end  as Pending_amount,
						isnull(ms.Net_Amount,0) - isnull(MEB.Net_Amount,0) as net_Pending_amount,	
						cast(datename(month, Ms.Month_End_Date) as NVARCHAR(15)) + ' - '+ cast(year(ms.month_end_date) as NVARCHAR(5)) as Month_name,
						spe.Comments,
						isnull(CMM.Curr_Symbol,'') as Curr_Symbol,Ms.Month_St_Date
			FROM		T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join T0250_SALARY_PUBLISH_ESS SPE WITH (NOLOCK) on Ms.Emp_ID = SPE.Emp_ID and month(Ms.Month_End_Date) = SPE.Month and year(Ms.Month_End_Date) = SPE.Year and SPE.Is_Publish = 1 and SPE.Sal_Type='Salary'
						left join MONTHLY_EMP_BANK_PAYMENT MEB WITH (NOLOCK) on  Ms.Emp_ID = MEB.Emp_ID and month(Ms.Month_End_Date) = Month(MEB.for_date) and year(Ms.Month_End_Date) = Year(MEB.For_Date) and MEB.Process_Type='Salary'
						left JOIN T0095_INCREMENT I WITH (NOLOCK) ON Ms.Increment_ID = I.Increment_ID
						left JOIN T0040_CURRENCY_MASTER CMM WITH (NOLOCK) ON I.Curr_ID = CMM.Curr_ID
			where		ms.Cmp_ID=@cmp_id and Ms.Emp_ID =@emp_id 
						and  Ms.Month_End_Date >= @from_Date and Ms.Month_End_Date <=@To_date
			order by Ms.Month_St_Date desc
	end
else
	begin
		select	Ms.Emp_ID,Ms.S_Month_End_Date as Month_End_Date,SPE.Month as int_month,SPE.Year as int_year,I.branch_id,Ms.Cmp_ID,Ms.Sal_Tran_ID,	
					--case when isnull(ms.S_Net_Amount,0) > 0  THEN  cast(CMM.Curr_Symbol as NVARCHAR) + CAST(' ' AS NVARCHAR) + cast(isnull(ms.S_Net_Amount,0) as NVARCHAR) ELSE cast(ms.S_Net_Amount AS NVARCHAR) end  as Net_Amount,
					--isnull(ms.S_Net_Amount,0) as net_Pending_amount,
					ms.S_Net_Amount as Net_Amount,
					ms.S_Net_Amount as Payment_Amount,
					Ms.S_Eff_Date as Effective_Date,
					cast(datename(month, Ms.S_Month_End_Date) as NVARCHAR(15)) + ' - '+ cast(year(ms.S_Month_End_Date) as NVARCHAR(5)) as Month_name,
					cast(datename(month, Ms.S_Eff_Date) as NVARCHAR(15)) + ' - '+ cast(year(ms.S_Eff_Date) as NVARCHAR(5)) as Effective_Month,
					spe.Comments,CMM.Curr_Symbol,Ms.S_Month_St_Date as Month_St_Date
		FROM		T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
					inner join T0250_SALARY_PUBLISH_ESS SPE WITH (NOLOCK) on Ms.Emp_ID = SPE.Emp_ID and month(Ms.S_Month_End_Date) = SPE.Month  and year(Ms.S_Month_End_Date) = SPE.Year and SPE.Is_Publish = 1 and SPE.Sal_Type='Settlement'
					left JOIN T0095_INCREMENT I WITH (NOLOCK) ON Ms.Increment_ID = I.Increment_ID
					left JOIN T0040_CURRENCY_MASTER CMM WITH (NOLOCK) ON I.Curr_ID = CMM.Curr_ID
		where		ms.Cmp_ID=@cmp_id and Ms.Emp_ID =@emp_id and  Ms.S_Month_End_Date >= @from_Date 
					and Ms.S_Month_End_Date <=@To_date
		order by Month_St_Date desc
	end

return
end


