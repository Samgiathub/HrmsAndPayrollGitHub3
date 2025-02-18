using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsEmpSkillSetting
{
    public decimal EmpSkillId { get; set; }

    public decimal SkillRId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SkillId { get; set; }

    public decimal SkilllRateGiven { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? SkillName { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? SEmpId { get; set; }

    public string? EmpSFullName { get; set; }

    public decimal LoginId { get; set; }

    public decimal? SkillActualRate { get; set; }

    public decimal BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TotalActualRate { get; set; }

    public decimal? TotalGivenRate { get; set; }

    public decimal SkillRateEmployee { get; set; }

    public decimal SkillRateSuperior { get; set; }
}
