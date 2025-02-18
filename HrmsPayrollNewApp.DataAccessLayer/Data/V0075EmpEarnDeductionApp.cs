using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0075EmpEarnDeductionApp
{
    public string AdName { get; set; } = null!;

    public int AdTranId { get; set; }

    public int CmpId { get; set; }

    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public int AdId { get; set; }

    public int IncrementId { get; set; }

    public string EAdFlag { get; set; } = null!;

    public string EAdMode { get; set; } = null!;

    public decimal EAdPercentage { get; set; }

    public decimal EAdAmount { get; set; }

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

    public byte HideInReports { get; set; }
}
