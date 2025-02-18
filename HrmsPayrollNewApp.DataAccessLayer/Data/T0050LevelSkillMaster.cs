using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050LevelSkillMaster
{
    public decimal? LvlsklId { get; set; }

    public decimal? CmpId { get; set; }

    public string? LevelName { get; set; }

    public string? LevelDesc { get; set; }

    public DateTime? RecordDate { get; set; }

    public decimal? CreatedBy { get; set; }
}
