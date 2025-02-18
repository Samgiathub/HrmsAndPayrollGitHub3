using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpSkillSetting
{
    public decimal SkillRId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal EmpSkillId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SkillId { get; set; }

    public decimal SkilllRateGiven { get; set; }

    public string? SkillName { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? SkillActualRate { get; set; }
}
