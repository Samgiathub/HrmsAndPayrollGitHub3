using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TrainingSkillMaster
{
    public decimal SkillId { get; set; }

    public decimal? CmpId { get; set; }

    public string? SkillName { get; set; }

    public decimal? SkillSortId { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string? IpAddress { get; set; }
}
