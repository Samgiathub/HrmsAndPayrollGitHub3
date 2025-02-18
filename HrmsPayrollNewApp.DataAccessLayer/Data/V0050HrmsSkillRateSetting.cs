using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050HrmsSkillRateSetting
{
    public decimal SkillDId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? AvgSkillActualRate { get; set; }

    public decimal? AvgSkillRRateMin { get; set; }

    public decimal? AvgSkillRRateMax { get; set; }

    public decimal? SkillEvalDuration { get; set; }

    public DateTime? ForeDate { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public string? BranchCode { get; set; }

    public string? BranchName { get; set; }

    public string? GrdName { get; set; }
}
