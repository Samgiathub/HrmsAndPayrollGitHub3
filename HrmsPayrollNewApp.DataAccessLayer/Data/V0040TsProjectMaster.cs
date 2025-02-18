using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040TsProjectMaster
{
    public decimal ProjectId { get; set; }

    public string? ProjectName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? CmpId { get; set; }

    public int? OverheadCalculation { get; set; }
}
