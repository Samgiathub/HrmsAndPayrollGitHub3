using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110EmpEarnDeductionRevised
{
    public decimal BranchId { get; set; }

    public decimal AdId { get; set; }

    public DateTime ForDate { get; set; }

    public string AdName { get; set; } = null!;

    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EAdFlag { get; set; } = null!;

    public string EAdMode { get; set; } = null!;

    public decimal? EAdPercentage { get; set; }

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

    public decimal? AdDefId { get; set; }

    public string EntryType { get; set; } = null!;

    public string EAdFlag1 { get; set; } = null!;

    public byte AddInSalAmt { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public byte HideInReports { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? CatId { get; set; }
}
