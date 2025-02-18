using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0075EmpEarnDeductionAppDetail
{
    public int EmpApplicationId { get; set; }

    public long EmpTranId { get; set; }

    public string AdName { get; set; } = null!;

    public int AdTranId { get; set; }

    public int CmpId { get; set; }

    public int AdId { get; set; }

    public int IncrementId { get; set; }

    public DateTime? ForDate { get; set; }

    public string EAdFlag { get; set; } = null!;

    public string EAdMode { get; set; } = null!;

    public string? EAdPercentage { get; set; }

    public string? EAdAmount { get; set; }

    public decimal EAdMaxLimit { get; set; }

    public decimal AdLevel { get; set; }

    public decimal? AdNotEffectSalary { get; set; }

    public byte AdPartOfCtc { get; set; }

    public decimal AdActive { get; set; }

    public decimal? AdNotEffectOnPt { get; set; }

    public byte ForFnf { get; set; }

    public byte NotEffectOnMonthlyCtc { get; set; }

    public byte IsYearly { get; set; }

    public byte NotEffectOnBasicCalculation { get; set; }

    public string AdCalculateOn { get; set; } = null!;

    public decimal? EffectNetSalary { get; set; }

    public string? AdEffectMonth { get; set; }

    public string EAdFlag1 { get; set; } = null!;

    public byte AddInSalAmt { get; set; }

    public decimal? AdDefId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal EmpCode { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public int BranchId { get; set; }

    public int GrdId { get; set; }

    public decimal? AdEffectOnCtc { get; set; }

    public byte HideInReports { get; set; }
}
