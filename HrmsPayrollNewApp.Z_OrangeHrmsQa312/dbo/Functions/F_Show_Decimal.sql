

-- Created By rohit on 29102015 for Show Decimal In Allowance.
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---

CREATE FUNCTION [dbo].[F_Show_Decimal]  
(  
 @Value Numeric(18,5),
 @cmp_id Numeric(18,0)  
)  
RETURNS varchar(100)  
AS  
BEGIN  

declare @Decimal numeric(18,0)
select @Decimal = isnull(Setting_value,2) from t0040_setting WITH (NOLOCK) where Cmp_ID = @cmp_id and Setting_Name='How many Decimal In Allowance'


Declare @T as varchar(100)  
if @Decimal = 0
begin 
	Set @T = PARSENAME(@Value,2)
end
else
begin
Set @T = PARSENAME(@Value,2)  
    + '.'  
    + left(PARSENAME(@Value,1),@Decimal)
end
  
return @T  
  
END 
