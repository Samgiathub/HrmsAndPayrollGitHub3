using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsEmpSkillDetail
{
    public int? SkillRateCount { get; set; }

    public decimal? TotalRate { get; set; }

    public decimal? SkillRateGiven { get; set; }

    public decimal SkillId { get; set; }

    public decimal EmpId { get; set; }

    public string? SkillName { get; set; }

    public decimal CmpId { get; set; }
}
